import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/api_error.dart';
import '../../api/vendors_api.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/vendor.dart';

const _statusValues = [
  'contacted',
  'negotiating',
  'confirmed',
  'paid',
  'cancelled',
];

String _statusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'negotiating':
      return l10n.vendorsStatusNegotiating;
    case 'confirmed':
      return l10n.vendorsStatusConfirmed;
    case 'paid':
      return l10n.vendorsStatusPaid;
    case 'cancelled':
      return l10n.vendorsStatusCancelled;
    default:
      return l10n.vendorsStatusContacted;
  }
}

Color _statusColor(BuildContext context, String status) {
  switch (status) {
    case 'negotiating':
      return Colors.orange;
    case 'confirmed':
      return Colors.blue;
    case 'paid':
      return Colors.green;
    case 'cancelled':
      return Theme.of(context).colorScheme.error;
    default:
      return Theme.of(context).colorScheme.outline;
  }
}

class VendorsTab extends StatefulWidget {
  const VendorsTab({super.key, required this.eventId});

  final int eventId;

  @override
  State<VendorsTab> createState() => _VendorsTabState();
}

class _VendorsTabState extends State<VendorsTab> {
  late Future<List<Vendor>> _future;
  List<Vendor>? _vendors;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<VendorsApi>().list(widget.eventId);
    _future.then((vendors) {
      if (mounted) setState(() => _vendors = vendors);
    }).catchError((_) {});
  }

  Future<void> _changeStatus(Vendor vendor, String status) async {
    if (status == vendor.status) return;
    try {
      final updated = await context.read<VendorsApi>().update(
            widget.eventId,
            vendor.id,
            name: vendor.name,
            category: vendor.category,
            contactName: vendor.contactName,
            phone: vendor.phone,
            email: vendor.email,
            price: vendor.price,
            status: status,
            notes: vendor.notes,
          );
      if (!mounted) return;
      setState(() {
        _vendors =
            _vendors!.map((v) => v.id == updated.id ? updated : v).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeApiError(context, e))));
    }
  }

  Future<void> _delete(Vendor vendor) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.vendorsDeleteVendorTitle),
        content: Text(l10n.vendorsConfirmDelete(vendor.name)),
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
      await context.read<VendorsApi>().delete(widget.eventId, vendor.id);
      if (!mounted) return;
      setState(
          () => _vendors = _vendors!.where((v) => v.id != vendor.id).toList());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeApiError(context, e))));
    }
  }

  Future<void> _openAddDialog() async {
    final created = await showDialog<Vendor>(
      context: context,
      builder: (_) => _AddVendorDialog(eventId: widget.eventId),
    );
    if (created == null || !mounted) return;
    setState(() => _vendors = [...?_vendors, created]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_vendors == null) {
      return FutureBuilder<List<Vendor>>(
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

    final vendors = _vendors!;
    final confirmedCount = vendors.where((v) => v.status == 'confirmed').length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.vendorsSummary(vendors.length, confirmedCount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              FilledButton.icon(
                onPressed: _openAddDialog,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.vendorsAddVendor),
              ),
            ],
          ),
        ),
        Expanded(
          child: vendors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 12),
                      Text(l10n.vendorsEmptyState),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: vendors.length,
                  itemBuilder: (context, index) =>
                      _buildCard(l10n, vendors[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildCard(AppLocalizations l10n, Vendor vendor) {
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
                  child: Text(
                    vendor.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: l10n.vendorsDeleteTooltip,
                  onPressed: () => _delete(vendor),
                ),
              ],
            ),
            if (vendor.category != null && vendor.category!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Chip(
                  label: Text(vendor.category!),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            if (vendor.contactName != null || vendor.phone != null || vendor.price != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vendor.contactName != null && vendor.contactName!.isNotEmpty)
                      Text(vendor.contactName!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    if (vendor.phone != null && vendor.phone!.isNotEmpty)
                      Text(vendor.phone!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    if (vendor.price != null)
                      Text('\$${vendor.price!.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            PopupMenuButton<String>(
              initialValue: vendor.status,
              onSelected: (status) => _changeStatus(vendor, status),
              itemBuilder: (context) => [
                for (final status in _statusValues)
                  PopupMenuItem(
                    value: status,
                    child: Text(_statusLabel(l10n, status)),
                  ),
              ],
              child: Chip(
                label: Text(_statusLabel(l10n, vendor.status)),
                avatar: Icon(Icons.arrow_drop_down,
                    color: _statusColor(context, vendor.status)),
                backgroundColor:
                    _statusColor(context, vendor.status).withValues(alpha: 0.12),
                labelStyle:
                    TextStyle(color: _statusColor(context, vendor.status)),
                side: BorderSide(color: _statusColor(context, vendor.status)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddVendorDialog extends StatefulWidget {
  const _AddVendorDialog({required this.eventId});

  final int eventId;

  @override
  State<_AddVendorDialog> createState() => _AddVendorDialogState();
}

class _AddVendorDialogState extends State<_AddVendorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  String _status = 'contacted';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _contactNameController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final api = context.read<VendorsApi>();
      final category = _categoryController.text.trim();
      final contactName = _contactNameController.text.trim();
      final phone = _phoneController.text.trim();
      final priceText = _priceController.text.trim();
      final price = priceText.isEmpty ? null : double.tryParse(priceText);

      var vendor = await api.create(
        widget.eventId,
        name: _nameController.text.trim(),
        category: category.isEmpty ? null : category,
        contactName: contactName.isEmpty ? null : contactName,
        phone: phone.isEmpty ? null : phone,
        price: price,
      );

      if (_status != vendor.status) {
        vendor = await api.update(
          widget.eventId,
          vendor.id,
          name: vendor.name,
          category: vendor.category,
          contactName: vendor.contactName,
          phone: vendor.phone,
          price: vendor.price,
          status: _status,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(vendor);
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
      title: Text(l10n.vendorsAddDialogTitle),
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
                decoration: InputDecoration(labelText: l10n.vendorsNameLabel),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.vendorsNameRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration:
                    InputDecoration(labelText: l10n.vendorsCategoryLabel),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactNameController,
                decoration:
                    InputDecoration(labelText: l10n.vendorsContactNameLabel),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.vendorsPhoneLabel),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.vendorsPriceLabel),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: InputDecoration(labelText: l10n.vendorsStatusLabel),
                items: [
                  for (final status in _statusValues)
                    DropdownMenuItem(
                      value: status,
                      child: Text(_statusLabel(l10n, status)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
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
