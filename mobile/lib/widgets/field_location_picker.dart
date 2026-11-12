import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../l10n/app_strings.dart';

class FieldLocationPicker extends StatefulWidget {
  const FieldLocationPicker({
    required this.initialLatitude,
    required this.initialLongitude,
    super.key,
  });

  final double initialLatitude;
  final double initialLongitude;

  static Future<LatLng?> show(
    BuildContext context, {
    required double initialLatitude,
    required double initialLongitude,
  }) {
    return showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FieldLocationPicker(
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
      ),
    );
  }

  @override
  State<FieldLocationPicker> createState() => _FieldLocationPickerState();
}

class _FieldLocationPickerState extends State<FieldLocationPicker> {
  final MapController _mapController = MapController();
  late LatLng _selectedPoint;
  bool _isLocating = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _selectedPoint = LatLng(widget.initialLatitude, widget.initialLongitude);
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    final s = AppStrings.of(context);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) {
          setState(() => _locationError = s.locationServiceDisabled);
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _locationError = s.locationPermissionDenied);
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
      if (!mounted) return;

      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedPoint = point;
        _locationError = null;
      });
      _mapController.move(point, 16);
    } catch (error) {
      debugPrint('Could not get current field location: $error');
      if (mounted) {
        setState(() => _locationError = s.locationRequestFailed);
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.84,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F6F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.mapPickTitle,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF191D24),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.mapPickHint,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          if (_locationError != null) ...[
            const SizedBox(height: 8),
            Text(
              _locationError!,
              style: const TextStyle(
                color: Color(0xFFB42318),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedPoint,
                  initialZoom: 14,
                  minZoom: 4,
                  maxZoom: 19,
                  onTap: (_, point) {
                    setState(() {
                      _selectedPoint = point;
                      _locationError = null;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ci.palayplan',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPoint,
                        width: 44,
                        height: 52,
                        child: const Icon(
                          Icons.location_pin,
                          color: Color(0xFFE85736),
                          size: 44,
                        ),
                      ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('© OpenStreetMap contributors'),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: FilledButton.tonalIcon(
                        onPressed: _isLocating ? null : _useCurrentLocation,
                        icon: _isLocating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location, size: 18),
                        label: Text(s.useCurrentLocation),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF191D24),
                          minimumSize: const Size(44, 44),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_selectedPoint.latitude.toStringAsFixed(5)}, '
            '${_selectedPoint.longitude.toStringAsFixed(5)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _selectedPoint),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7E55),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                s.confirmFieldLocation,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
