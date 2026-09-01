import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../api/api_error.dart';
import '../../api/events_api.dart';
import '../../api/geocoding_api.dart';
import '../../l10n/format_date.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/event.dart';
import '../../widgets/location_picker_map.dart';

class EventOverviewTab extends StatefulWidget {
  const EventOverviewTab({
    super.key,
    required this.event,
    required this.onSaved,
  });

  final EventItem event;
  final ValueChanged<EventItem> onSaved;

  @override
  State<EventOverviewTab> createState() => _EventOverviewTabState();
}

class _EventOverviewTabState extends State<EventOverviewTab> {
  final _formKey = GlobalKey<FormState>();
  final _geocodingApi = GeocodingApi();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  DateTime? _date;
  double? _lat;
  double? _lng;
  bool _saving = false;
  bool _geocoding = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.name);
    _descriptionController =
        TextEditingController(text: widget.event.description ?? '');
    _addressController =
        TextEditingController(text: widget.event.locationAddress ?? '');
    _date = widget.event.eventDate;
    _lat = widget.event.locationLat;
    _lng = widget.event.locationLng;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _onMapTap(LatLng point) async {
    setState(() {
      _lat = point.latitude;
      _lng = point.longitude;
      _geocoding = true;
    });
    final address =
        await _geocodingApi.reverseGeocode(point.latitude, point.longitude);
    if (!mounted) return;
    setState(() {
      _geocoding = false;
      if (address != null) _addressController.text = address;
    });
  }

  static String? _formatDateForApi(DateTime? date) {
    if (date == null) return null;
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final description = _descriptionController.text.trim();
      final address = _addressController.text.trim();
      final updated = await context.read<EventsApi>().update(
            widget.event.id,
            name: _nameController.text.trim(),
            eventDate: _formatDateForApi(_date),
            description: description.isEmpty ? null : description,
            locationAddress: address.isEmpty ? null : address,
            locationLat: _lat,
            locationLng: _lng,
          );
      widget.onSaved(updated);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.overviewSavedMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeApiError(context, e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateLabel =
        _date != null ? formatDate(context, _date!) : l10n.commonNotSet;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.eventsNameFieldLabel,
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.overviewNameRequired
                  : null,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.overviewDateLabel,
                  border: const OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateLabel),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.overviewDescriptionLabel,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 6,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: l10n.overviewAddressLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(l10n.overviewLocationLabel,
                    style: Theme.of(context).textTheme.titleSmall),
                if (_geocoding) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    height: 12,
                    width: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.overviewLocationHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            LocationPickerMap(lat: _lat, lng: _lng, onPick: _onMapTap),
            if (_lat != null && _lng != null) ...[
              const SizedBox(height: 8),
              Text(
                '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}
