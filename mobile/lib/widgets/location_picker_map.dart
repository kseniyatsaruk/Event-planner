import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const _defaultCenter = LatLng(51.505, -0.09);
const _defaultZoom = 13.0;

/// Tap-to-pick location map, parity with the web app's LocationPicker
/// (react-leaflet + OpenStreetMap tiles, no API keys).
class LocationPickerMap extends StatelessWidget {
  const LocationPickerMap({
    super.key,
    required this.lat,
    required this.lng,
    required this.onPick,
  });

  final double? lat;
  final double? lng;
  final ValueChanged<LatLng> onPick;

  @override
  Widget build(BuildContext context) {
    final hasPosition = lat != null && lng != null;
    final center = hasPosition ? LatLng(lat!, lng!) : _defaultCenter;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 260,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: _defaultZoom,
            onTap: (_, point) => onPick(point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.eventplanner.mobile',
            ),
            if (hasPosition)
              MarkerLayer(markers: [
                Marker(
                  point: LatLng(lat!, lng!),
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on,
                      color: Colors.red, size: 36),
                ),
              ]),
          ],
        ),
      ),
    );
  }
}
