import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/api_error.dart';
import '../../api/guests_api.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/guest.dart';

const _rsvpValues = ['pending', 'invited', 'confirmed', 'declined'];

String _rsvpLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'invited':
      return l10n.guestsRsvpInvited;
    case 'confirmed':
      return l10n.guestsRsvpConfirmed;
    case 'declined':
      return l10n.guestsRsvpDeclined;
    default:
      return l10n.guestsRsvpPending;
  }
}

Color _rsvpColor(BuildContext context, String status) {
  switch (status) {
    case 'invited':
      return Colors.blue;
    case 'confirmed':
      return Colors.green;
    case 'declined':
      return Theme.of(context).colorScheme.error;
    default:
      return Theme.of(context).colorScheme.outline;
  }
}

class GuestsTab extends StatefulWidget {
  const GuestsTab({super.key, required this.eventId});

  final int eventId;

  @override
  State<GuestsTab> createState() => _GuestsTabState();
}

class _GuestsTabState extends State<GuestsTab> {
  late Future<List<Guest>> _future;
  List<Guest>? _guests;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<GuestsApi>().list(widget.eventId);
    _future.then((guests) {
      if (mounted) setState(() => _guests = guests);
    }).catchError((_) {});
  }

  Future<void> _updateGuest(
    Guest guest, {
    String? rsvpStatus,
    bool? plusOne,
  }) async {
    try {
      final updated = await context.read<GuestsApi>().update(
            widget.eventId,
            guest.id,
            name: guest.name,
            phone: guest.phone,
            email: guest.email,
            rsvpStatus: rsvpStatus ?? guest.rsvpStatus,
            plusOne: plusOne ?? guest.plusOne,
            notes: guest.notes,
          );
      if (!mounted) return;
      setState(() {
        _guests = _guests!.map((g) => g.id == updated.id ? updated : g).toList();
      });
      if (guest.tableId != null && updated.tableId == null) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.guestsPlusOneUnseatedNotice(updated.name))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeApiError(context, e))));
    }
  }

  Future<void> _delete(Guest guest) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.guestsDeleteGuestTitle),
        content: Text(l10n.guestsConfirmDelete(guest.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    try {
      await context.read<GuestsApi>().delete(widget.eventId, guest.id);
      if (!mounted) return;
      setState(() => _guests = _guests!.where((g) => g.id != guest.id).toList());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeApiError(context, e))));
    }
  }

  Future<void> _openAddDialog() async {
    final created = await showDialog<Guest>(
      context: context,
      builder: (_) => _AddGuestDialog(eventId: widget.eventId),
    );
    if (created == null || !mounted) return;
    setState(() => _guests = [...?_guests, created]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_guests == null) {
      return FutureBuilder<List<Guest>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(describeApiError(context, snapshot.error!)),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => setState(_load),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );
    }

    final guests = _guests!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.guestsSummary(guests.length),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              FilledButton.icon(
                onPressed: _openAddDialog,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.guestsAddGuest),
              ),
            ],
          ),
        ),
        Expanded(
          child: guests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 12),
                      Text(l10n.guestsEmptyState),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: guests.length,
                  itemBuilder: (context, index) =>
                      _buildCard(l10n, guests[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildCard(AppLocalizations l10n, Guest guest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        guest.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (guest.plusOne)
                        const Chip(
                          label: Text('+1'),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: l10n.guestsDeleteTooltip,
                  onPressed: () => _delete(guest),
                ),
              ],
            ),
            if (guest.phone != null || guest.email != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (guest.phone != null && guest.phone!.isNotEmpty)
                      Text(guest.phone!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    if (guest.email != null && guest.email!.isNotEmpty)
                      Text(guest.email!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                PopupMenuButton<String>(
                  initialValue: guest.rsvpStatus,
                  onSelected: (status) =>
                      _updateGuest(guest, rsvpStatus: status),
                  itemBuilder: (context) => [
                    for (final status in _rsvpValues)
                      PopupMenuItem(
                        value: status,
                        child: Text(_rsvpLabel(l10n, status)),
                      ),
                  ],
                  child: Chip(
                    label: Text(_rsvpLabel(l10n, guest.rsvpStatus)),
                    avatar: Icon(Icons.arrow_drop_down,
                        color: _rsvpColor(context, guest.rsvpStatus)),
                    backgroundColor: _rsvpColor(context, guest.rsvpStatus)
                        .withValues(alpha: 0.12),
                    labelStyle:
                        TextStyle(color: _rsvpColor(context, guest.rsvpStatus)),
                    side: BorderSide(color: _rsvpColor(context, guest.rsvpStatus)),
                  ),
                ),
                const Spacer(),
                Text(l10n.guestsPlusOneLabel),
                Switch(
                  value: guest.plusOne,
                  onChanged: (value) => _updateGuest(guest, plusOne: value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddGuestDialog extends StatefulWidget {
  const _AddGuestDialog({required this.eventId});

  final int eventId;

  @override
  State<_AddGuestDialog> createState() => _AddGuestDialogState();
}

class _AddGuestDialogState extends State<_AddGuestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _rsvpStatus = 'pending';
  bool _plusOne = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final api = context.read<GuestsApi>();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();

      var guest = await api.create(
        widget.eventId,
        name: _nameController.text.trim(),
        phone: phone.isEmpty ? null : phone,
        email: email.isEmpty ? null : email,
        plusOne: _plusOne,
      );

      if (_rsvpStatus != guest.rsvpStatus) {
        guest = await api.update(
          widget.eventId,
          guest.id,
          name: guest.name,
          phone: guest.phone,
          email: guest.email,
          rsvpStatus: _rsvpStatus,
          plusOne: guest.plusOne,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(guest);
    } catch (e) {
      setState(() => _error = describeApiError(context, e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.guestsAddDialogTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.guestsNameLabel),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.guestsNameRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.guestsPhoneLabel),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l10n.guestsEmailLabel),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _rsvpStatus,
                decoration:
                    InputDecoration(labelText: l10n.guestsRsvpStatusLabel),
                items: [
                  for (final status in _rsvpValues)
                    DropdownMenuItem(
                      value: status,
                      child: Text(_rsvpLabel(l10n, status)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _rsvpStatus = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.guestsPlusOneLabel),
                value: _plusOne,
                onChanged: (value) => setState(() => _plusOne = value),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.commonAdd),
        ),
      ],
    );
  }
}
