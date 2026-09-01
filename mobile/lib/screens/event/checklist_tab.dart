import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/api_error.dart';
import '../../api/checklist_api.dart';
import '../../l10n/format_date.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/checklist_item.dart';

const _statusOrder = ['todo', 'in_progress', 'done'];

String _statusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'in_progress':
      return l10n.checklistStatusInProgress;
    case 'done':
      return l10n.checklistStatusDone;
    default:
      return l10n.checklistStatusTodo;
  }
}

String _nextStatus(String status) {
  final i = _statusOrder.indexOf(status);
  return _statusOrder[(i + 1) % _statusOrder.length];
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'in_progress':
      return Icons.autorenew;
    case 'done':
      return Icons.check_circle;
    default:
      return Icons.radio_button_unchecked;
  }
}

Color _statusColor(BuildContext context, String status) {
  switch (status) {
    case 'in_progress':
      return Colors.orange;
    case 'done':
      return Colors.green;
    default:
      return Theme.of(context).colorScheme.outline;
  }
}

/// Date format used only for the wire format sent to the API — distinct
/// from the localized date shown to the user via [formatDate].
String _formatDateForApi(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class ChecklistTab extends StatefulWidget {
  const ChecklistTab({super.key, required this.eventId});

  final int eventId;

  @override
  State<ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends State<ChecklistTab> {
  late Future<List<ChecklistItem>> _future;
  List<ChecklistItem>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<ChecklistApi>().list(widget.eventId);
    _future.then((items) {
      if (mounted) setState(() => _items = items);
    }).catchError((_) {});
  }

  Future<void> _cycleStatus(ChecklistItem item) async {
    final next = _nextStatus(item.status);
    try {
      final updated = await context.read<ChecklistApi>().update(
            widget.eventId,
            item.id,
            title: item.title,
            description: item.description,
            category: item.category,
            dueDate:
                item.dueDate != null ? _formatDateForApi(item.dueDate!) : null,
            status: next,
            vendorId: item.vendorId,
          );
      if (!mounted) return;
      setState(() {
        _items = _items!
            .map((i) => i.id == updated.id ? updated : i)
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeApiError(context, e))));
    }
  }

  Future<bool> _confirmDelete(ChecklistItem item) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.checklistDeleteItemTitle),
        content: Text(l10n.checklistConfirmDelete(item.title)),
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
    return confirmed ?? false;
  }

  Future<void> _delete(ChecklistItem item) async {
    try {
      await context.read<ChecklistApi>().delete(widget.eventId, item.id);
      if (!mounted) return;
      setState(() => _items = _items!.where((i) => i.id != item.id).toList());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeApiError(context, e))));
      // The item wasn't removed, so restore it in the list by reloading.
      setState(() => _load());
    }
  }

  Future<void> _openAddDialog() async {
    final created = await showDialog<ChecklistItem>(
      context: context,
      builder: (_) => _AddChecklistItemDialog(eventId: widget.eventId),
    );
    if (created == null || !mounted) return;
    setState(() => _items = [...?_items, created]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_items == null) {
      return FutureBuilder<List<ChecklistItem>>(
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

    final items = _items!;
    final doneCount = items.where((i) => i.status == 'done').length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.checklistSummary(items.length, doneCount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              FilledButton.icon(
                onPressed: _openAddDialog,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.checklistAddItem),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.checklist,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 12),
                      Text(l10n.checklistEmptyState),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    for (final status in _statusOrder)
                      ..._buildSection(l10n, status, items),
                  ],
                ),
        ),
      ],
    );
  }

  List<Widget> _buildSection(
      AppLocalizations l10n, String status, List<ChecklistItem> items) {
    final statusItems = items.where((i) => i.status == status).toList();
    if (statusItems.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          '${_statusLabel(l10n, status)} (${statusItems.length})',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      for (final item in statusItems) _buildTile(l10n, item),
    ];
  }

  Widget _buildTile(AppLocalizations l10n, ChecklistItem item) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(item),
      onDismissed: (_) => _delete(item),
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete,
            color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      child: ListTile(
        leading: IconButton(
          icon: Icon(_statusIcon(item.status),
              color: _statusColor(context, item.status)),
          tooltip: l10n.checklistChangeStatusTooltip,
          onPressed: () => _cycleStatus(item),
        ),
        title: Text(
          item.title,
          style: item.status == 'done'
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: (item.category != null || item.dueDate != null)
            ? Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (item.category != null && item.category!.isNotEmpty)
                    Chip(
                      label: Text(item.category!),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  if (item.dueDate != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14),
                        const SizedBox(width: 4),
                        Text(l10n
                            .checklistDueLabel(formatDate(context, item.dueDate!))),
                      ],
                    ),
                ],
              )
            : null,
      ),
    );
  }
}

class _AddChecklistItemDialog extends StatefulWidget {
  const _AddChecklistItemDialog({required this.eventId});

  final int eventId;

  @override
  State<_AddChecklistItemDialog> createState() =>
      _AddChecklistItemDialogState();
}

class _AddChecklistItemDialogState extends State<_AddChecklistItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime? _dueDate;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final category = _categoryController.text.trim();
      final created = await context.read<ChecklistApi>().create(
            widget.eventId,
            title: _titleController.text.trim(),
            category: category.isEmpty ? null : category,
            dueDate: _dueDate != null ? _formatDateForApi(_dueDate!) : null,
          );
      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (e) {
      setState(() => _error = describeApiError(context, e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateLabel =
        _dueDate != null ? formatDate(context, _dueDate!) : l10n.commonNotSet;
    return AlertDialog(
      title: Text(l10n.checklistAddDialogTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.checklistTitleLabel),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.checklistTitleRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration:
                    InputDecoration(labelText: l10n.checklistCategoryLabel),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration:
                      InputDecoration(labelText: l10n.checklistDueDateLabel),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateLabel),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
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
