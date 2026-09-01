import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/api_error.dart';
import '../../api/guests_api.dart';
import '../../api/tables_api.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/guest.dart';
import '../../models/table_model.dart';

/// The seat physically next to [seatNumber] at a table of this [shape] and
/// [capacity] — where a plus-one guest's companion sits. Mirrors the web
/// app's seatAdjacency.js / the backend's NextSeatNumber exactly: round
/// tables wrap around, rectangular tables only pair seats within the same
/// row (front half vs. back half) and never wrap.
int? _companionSeat(String shape, int capacity, int seatNumber) {
  if (capacity < 2) return null;
  if (shape == 'round') {
    return seatNumber >= capacity ? 1 : seatNumber + 1;
  }
  final topRowCount = (capacity / 2).ceil();
  if (seatNumber == topRowCount || seatNumber == capacity) return null;
  return seatNumber + 1;
}

String _shapeLabel(AppLocalizations l10n, String shape) =>
    shape == 'round' ? l10n.seatingShapeRound : l10n.seatingShapeRectangle;

class SeatingTab extends StatefulWidget {
  const SeatingTab({super.key, required this.eventId});

  final int eventId;

  @override
  State<SeatingTab> createState() => _SeatingTabState();
}

class _SeatingTabState extends State<SeatingTab> {
  late Future<void> _future;
  List<EventTable>? _tables;
  List<Guest>? _guests;
  int? _selectedGuestId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _fetchAll();
  }

  Future<void> _fetchAll() async {
    final tablesApi = context.read<TablesApi>();
    final guestsApi = context.read<GuestsApi>();
    final results = await Future.wait([
      tablesApi.list(widget.eventId),
      guestsApi.list(widget.eventId),
    ]);
    if (!mounted) return;
    setState(() {
      _tables = results[0] as List<EventTable>;
      _guests = results[1] as List<Guest>;
    });
  }

  void _toggleSelect(int guestId) {
    setState(() => _selectedGuestId = _selectedGuestId == guestId ? null : guestId);
  }

  String? get _selectedGuestName {
    if (_selectedGuestId == null) return null;
    for (final g in _guests!) {
      if (g.id == _selectedGuestId) return g.name;
    }
    return null;
  }

  Future<void> _assign(int guestId, int? tableId, int? seatNumber) async {
    try {
      final updated = await context.read<GuestsApi>().assignTable(
            widget.eventId,
            guestId,
            tableId: tableId,
            seatNumber: seatNumber,
          );
      if (!mounted) return;
      setState(() {
        _guests = _guests!.map((g) => g.id == updated.id ? updated : g).toList();
        if (guestId == _selectedGuestId) _selectedGuestId = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeApiError(context, e))));
    }
  }

  Future<void> _onSeatTap(EventTable table, int seat, Guest? occupant) async {
    final l10n = AppLocalizations.of(context);
    if (occupant != null) {
      final action = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(occupant.name),
          content: Text(l10n.seatingOccupantDialogSubtitle(table.label, seat)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('reassign'),
              child: Text(l10n.seatingReassign),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop('unassign'),
              child: Text(l10n.seatingUnassign),
            ),
          ],
        ),
      );
      if (action == 'unassign') {
        await _assign(occupant.id, null, null);
      } else if (action == 'reassign') {
        setState(() => _selectedGuestId = occupant.id);
      }
      return;
    }

    if (_selectedGuestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.seatingTapGuestFirst)),
      );
      return;
    }
    await _assign(_selectedGuestId!, table.id, seat);
  }

  Future<void> _openAddTableDialog() async {
    final created = await showDialog<EventTable>(
      context: context,
      builder: (_) => _AddTableDialog(eventId: widget.eventId),
    );
    if (created == null || !mounted) return;
    setState(() => _tables = [...?_tables, created]);
  }

  Future<void> _deleteTable(EventTable table) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.seatingDeleteTableTitle),
        content: Text(l10n.seatingConfirmDeleteTable(table.label)),
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
      await context.read<TablesApi>().delete(widget.eventId, table.id);
      if (!mounted) return;
      setState(() {
        _tables = _tables!.where((t) => t.id != table.id).toList();
        _guests = _guests!
            .map((g) => g.tableId == table.id ? g.unseated() : g)
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeApiError(context, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_tables == null || _guests == null) {
      return FutureBuilder<void>(
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

    final tables = _tables!;
    final guests = _guests!;
    final unassigned = guests.where((g) => g.tableId == null).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.seatingSummary(tables.length, unassigned.length),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              FilledButton.icon(
                onPressed: _openAddTableDialog,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.seatingAddTable),
              ),
            ],
          ),
        ),
        if (_selectedGuestName != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Material(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(l10n.seatingSelectedBanner(_selectedGuestName!)),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedGuestId = null),
                      child: Text(l10n.commonCancel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              if (tables.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(Icons.event_seat_outlined,
                          size: 48, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 12),
                      Text(l10n.seatingNoTablesYet, textAlign: TextAlign.center),
                    ],
                  ),
                )
              else
                for (final table in tables)
                  _buildTableCard(l10n, table, guests),
              const SizedBox(height: 8),
              _buildUnassignedCard(l10n, unassigned),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableCard(
      AppLocalizations l10n, EventTable table, List<Guest> allGuests) {
    final atTable = allGuests.where((g) => g.tableId == table.id).toList();
    final occupiedCount =
        atTable.fold<int>(0, (sum, g) => sum + (g.plusOne ? 2 : 1));
    final bySeat = <int, Guest>{
      for (final g in atTable)
        if (g.seatNumber != null) g.seatNumber!: g,
    };
    final reservedBy = <int, Guest>{};
    for (final g in atTable) {
      if (g.plusOne && g.seatNumber != null) {
        final companion = _companionSeat(table.shape, table.capacity, g.seatNumber!);
        if (companion != null && !bySeat.containsKey(companion)) {
          reservedBy[companion] = g;
        }
      }
    }
    final unseatedHere = atTable.where((g) => g.seatNumber == null).length;

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
                        table.label,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Chip(
                        label: Text(_shapeLabel(l10n, table.shape)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: l10n.seatingDeleteTableTooltip,
                  onPressed: () => _deleteTable(table),
                ),
              ],
            ),
            Text(
              l10n.seatingSeatedCount(occupiedCount, table.capacity) +
                  (unseatedHere > 0
                      ? l10n.seatingWithoutSeatNumberSuffix(unseatedHere)
                      : ''),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var seat = 1; seat <= table.capacity; seat++)
                  _buildSeatTile(l10n, table, seat, bySeat[seat], reservedBy[seat]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatTile(
    AppLocalizations l10n,
    EventTable table,
    int seat,
    Guest? occupant,
    Guest? reservedByGuest,
  ) {
    final theme = Theme.of(context);
    final isSelectedOccupant = occupant != null && occupant.id == _selectedGuestId;

    Color background;
    Color borderColor;
    String line2;
    if (occupant != null) {
      background = theme.colorScheme.primaryContainer;
      borderColor = isSelectedOccupant ? Colors.orange : Colors.transparent;
      line2 = occupant.name + (occupant.plusOne ? ' +1' : '');
    } else if (reservedByGuest != null) {
      background = theme.colorScheme.surfaceContainerHighest;
      borderColor = Colors.transparent;
      line2 = l10n.seatingSeatReserved(reservedByGuest.name);
    } else {
      background = Colors.transparent;
      borderColor = theme.colorScheme.outlineVariant;
      line2 = l10n.seatingSeatFree;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _onSeatTap(table, seat, occupant),
      child: Container(
        width: 136,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: borderColor, width: isSelectedOccupant ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.seatingSeatLabel(seat), style: theme.textTheme.labelSmall),
            Text(
              line2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnassignedCard(AppLocalizations l10n, List<Guest> unassigned) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.seatingUnassignedTitle(unassigned.length),
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (unassigned.isEmpty)
              Text(
                l10n.seatingEveryoneSeated,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final guest in unassigned)
                    ChoiceChip(
                      label: Text(guest.name + (guest.plusOne ? ' +1' : '')),
                      selected: guest.id == _selectedGuestId,
                      onSelected: (_) => _toggleSelect(guest.id),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AddTableDialog extends StatefulWidget {
  const _AddTableDialog({required this.eventId});

  final int eventId;

  @override
  State<_AddTableDialog> createState() => _AddTableDialogState();
}

class _AddTableDialogState extends State<_AddTableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _capacityController = TextEditingController(text: '8');
  String _shape = 'round';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _labelController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final capacity = int.parse(_capacityController.text.trim());
      final table = await context.read<TablesApi>().create(
            widget.eventId,
            label: _labelController.text.trim(),
            capacity: capacity,
            shape: _shape,
          );
      if (!mounted) return;
      Navigator.of(context).pop(table);
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
      title: Text(l10n.seatingAddDialogTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _labelController,
                autofocus: true,
                decoration:
                    InputDecoration(labelText: l10n.seatingTableNameLabel),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.seatingTableNameRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: l10n.seatingCapacityLabel),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n < 1) return l10n.seatingCapacityRequired;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _shape,
                decoration: InputDecoration(labelText: l10n.seatingShapeLabel),
                items: [
                  DropdownMenuItem(
                      value: 'round', child: Text(l10n.seatingShapeRound)),
                  DropdownMenuItem(
                      value: 'rectangle',
                      child: Text(l10n.seatingShapeRectangle)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _shape = value);
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
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
