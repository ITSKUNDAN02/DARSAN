import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';

enum TravelMode { driving, walking, cycling }

extension TravelModeExtension on TravelMode {
  String get displayName {
    switch (this) {
      case TravelMode.driving:
        return 'Car';
      case TravelMode.walking:
        return 'Walk';
      case TravelMode.cycling:
        return 'Bike';
    }
  }

  IconData get icon {
    switch (this) {
      case TravelMode.driving:
        return Icons.directions_car;
      case TravelMode.walking:
        return Icons.directions_walk;
      case TravelMode.cycling:
        return Icons.directions_bike;
    }
  }

  String get osrmProfile {
    switch (this) {
      case TravelMode.driving:
        return 'driving';
      case TravelMode.walking:
        return 'foot';
      case TravelMode.cycling:
        return 'bike';
    }
  }
}

class LocationSuggestion {
  final String name;
  final LatLng location;

  LocationSuggestion({required this.name, required this.location});
}

class RouteOption {
  final TravelMode mode;
  final double distance;
  final Duration duration;
  final List<LatLng> points;

  RouteOption({
    required this.mode,
    required this.distance,
    required this.duration,
    required this.points,
  });

  String get distanceText => '${distance.toStringAsFixed(1)} km';
  String get durationText {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }
}

class MapScreen extends StatefulWidget {
  final String? destinationQuery;
  final bool autoStartNavigation;

  const MapScreen({
    super.key,
    this.destinationQuery,
    this.autoStartNavigation = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController mapController;
  LatLng? currentLocation;
  LatLng? startPoint;
  LatLng? endPoint;

  List<RouteOption> routeOptions = [];
  RouteOption? selectedRoute;
  bool _expandRoutesPanel = false;

  StreamSubscription<Position>? _positionStream;
  bool _isLoading = false;
  bool _showSearchPanel = true;
  bool _isNavigating = false;
  bool _isBottomPanelExpanded = true;
  double _remainingDistance = 0;

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    _startLocationTracking();

    if (widget.destinationQuery != null &&
        widget.destinationQuery!.isNotEmpty) {
      toController.text = widget.destinationQuery!;
      await _searchAndNavigate(widget.destinationQuery!);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _startLocationTracking() {
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position pos) {
          if (mounted) {
            final newLocation = LatLng(pos.latitude, pos.longitude);
            setState(() {
              currentLocation = newLocation;
            });

            if (_isNavigating && endPoint != null) {
              _updateRemainingDistance(newLocation);
              mapController.move(newLocation, 18);
            }
          }
        });
  }

  void _updateRemainingDistance(LatLng userLocation) {
    if (endPoint == null) return;

    const double earthRadius = 6371;
    final lat1 = userLocation.latitude * 3.14159 / 180;
    final lat2 = endPoint!.latitude * 3.14159 / 180;
    final dLat = (endPoint!.latitude - userLocation.latitude) * 3.14159 / 180;
    final dLon = (endPoint!.longitude - userLocation.longitude) * 3.14159 / 180;

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1) * cos(lat2) * (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    setState(() {
      _remainingDistance = distance;
    });
  }

  Future<List<LocationSuggestion>> _getLocationSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final url =
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=8&addressdetails=1';

      final response = await http
          .get(Uri.parse(url), headers: {'User-Agent': 'DarshanApp/1.0'})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return [];

      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) {
            try {
              final lat = double.parse(item['lat'].toString());
              final lon = double.parse(item['lon'].toString());
              return LocationSuggestion(
                name: item['display_name'] ?? 'Unknown',
                location: LatLng(lat, lon),
              );
            } catch (e) {
              return null;
            }
          })
          .whereType<LocationSuggestion>()
          .toList();
    } catch (e) {
      debugPrint('Suggestion error: $e');
      return [];
    }
  }

  Future<LatLng?> _geocodeLocation(String query) async {
    try {
      final suggestions = await _getLocationSuggestions(query);
      return suggestions.isNotEmpty ? suggestions.first.location : null;
    } catch (e) {
      debugPrint('Geocode error: $e');
      return null;
    }
  }

  Future<RouteOption?> _calculateSingleRoute(
    TravelMode mode,
    LatLng from,
    LatLng to,
  ) async {
    try {
      final url =
          'https://router.project-osrm.org/route/v1/${mode.osrmProfile}/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?overview=full&geometries=geojson';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List?;

        if (routes != null && routes.isNotEmpty) {
          final route = routes[0];
          final coords = route['geometry']['coordinates'] as List;
          final distance = (route['distance'] as num).toDouble() / 1000;
          final durationSeconds = (route['duration'] as num).toInt();

          return RouteOption(
            mode: mode,
            distance: distance,
            duration: Duration(seconds: durationSeconds),
            points: coords
                .map(
                  (c) => LatLng(
                    (c[1] as num).toDouble(),
                    (c[0] as num).toDouble(),
                  ),
                )
                .toList(),
          );
        }
      }
    } catch (e) {
      debugPrint('Route error: $e');
    }
    return null;
  }

  Future<void> _calculateAllRoutes(LatLng from, LatLng to) async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _calculateSingleRoute(TravelMode.driving, from, to),
        _calculateSingleRoute(TravelMode.walking, from, to),
        _calculateSingleRoute(TravelMode.cycling, from, to),
      ]);

      final routes = results.whereType<RouteOption>().toList();

      if (mounted && routes.isNotEmpty) {
        setState(() {
          routeOptions = routes;
          selectedRoute = routes.first;
        });
        mapController.move(from, 13);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getRoute() async {
    if (toController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter destination')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      LatLng? from;
      if (fromController.text.isEmpty && currentLocation != null) {
        from = currentLocation;
      } else if (fromController.text.isNotEmpty) {
        from = await _geocodeLocation(fromController.text);
      }

      final to = await _geocodeLocation(toController.text);

      if (from == null || to == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location not found')));
        return;
      }

      setState(() {
        startPoint = from;
        endPoint = to;
      });

      await _calculateAllRoutes(from, to);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _swapLocations() {
    final temp = fromController.text;
    fromController.text = toController.text;
    toController.text = temp;
  }

  Future<void> _searchAndNavigate(String destination) async {
    setState(() => _isLoading = true);

    try {
      final to = await _geocodeLocation(destination);
      if (to == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Destination not found')),
          );
        }
        return;
      }

      setState(() {
        startPoint = currentLocation;
        endPoint = to;
      });

      await _calculateAllRoutes(currentLocation!, to);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearRoute() {
    setState(() {
      routeOptions = [];
      selectedRoute = null;
      startPoint = null;
      endPoint = null;
      _isNavigating = false;
      _remainingDistance = 0;
      toController.clear();
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    fromController.dispose();
    toController.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final center = currentLocation ?? const LatLng(27.7172, 85.3240);

    return Scaffold(
      body: Stack(
        children: [
          // Map Layer
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.darsan_app',
              ),
              if (selectedRoute != null && selectedRoute!.points.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: selectedRoute!.points,
                      strokeWidth: 5,
                      color: Colors.blue.withOpacity(0.8),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (currentLocation != null)
                    Marker(
                      point: currentLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  if (startPoint != null && startPoint != currentLocation)
                    Marker(
                      point: startPoint!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  if (endPoint != null)
                    Marker(
                      point: endPoint!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Top Search Panel
          if (_showSearchPanel)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 10 : 16),
                  child: Container(
                    width: isMobile ? double.infinity : 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // From Field
                          TypeAheadField<LocationSuggestion>(
                            controller: fromController,
                            builder: (context, controller, focusNode) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: 'Starting location',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  prefixIcon: const Icon(
                                    Icons.location_on,
                                    color: Colors.green,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                              );
                            },
                            suggestionsCallback: (search) async {
                              if (search.isEmpty) return [];
                              return await _getLocationSuggestions(search);
                            },
                            itemBuilder: (context, suggestion) => Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey[200]!),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestion.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${suggestion.location.latitude.toStringAsFixed(3)}, ${suggestion.location.longitude.toStringAsFixed(3)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onSelected: (suggestion) {
                              fromController.text = suggestion.name;
                            },
                            hideOnEmpty: true,
                            debounceDuration: const Duration(milliseconds: 300),

                            loadingBuilder: (context) => const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // To Field with Swap
                          Row(
                            children: [
                              Expanded(
                                child: TypeAheadField<LocationSuggestion>(
                                  controller: toController,
                                  builder: (context, controller, focusNode) {
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      decoration: InputDecoration(
                                        hintText: 'Destination',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.flag,
                                          color: Colors.red,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                    );
                                  },
                                  suggestionsCallback: (search) async {
                                    if (search.isEmpty) return [];
                                    return await _getLocationSuggestions(
                                      search,
                                    );
                                  },
                                  itemBuilder: (context, suggestion) => Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          suggestion.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${suggestion.location.latitude.toStringAsFixed(3)}, ${suggestion.location.longitude.toStringAsFixed(3)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onSelected: (suggestion) {
                                    toController.text = suggestion.name;
                                  },
                                  hideOnEmpty: true,
                                  debounceDuration: const Duration(
                                    milliseconds: 300,
                                  ),

                                  loadingBuilder: (context) => const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.swap_vert,
                                    color: Colors.grey,
                                  ),
                                  onPressed: _swapLocations,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Get Route Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      await _getRoute();

                                      if (routeOptions.isNotEmpty) {
                                        setState(() {
                                          _showSearchPanel = false;
                                        });
                                      }
                                    },
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.directions),
                              label: Text(
                                _isLoading ? 'Searching...' : 'Get Route',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Route Options Panel
          if (routeOptions.isNotEmpty && selectedRoute != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 10 : 16),
                child: Container(
                  width: isMobile ? double.infinity : 500,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Summary
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isNavigating
                                            ? '${_remainingDistance.toStringAsFixed(1)} km'
                                            : selectedRoute!.distanceText,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        _isNavigating
                                            ? 'Remaining'
                                            : 'Distance',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedRoute!.durationText,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        'Est. time',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isNavigating = !_isNavigating;

                                        if (_isNavigating) {
                                          _isBottomPanelExpanded = false;
                                        }
                                      });

                                      if (_isNavigating) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Navigating via ${selectedRoute!.mode.displayName}',
                                            ),
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isNavigating
                                          ? Colors.orange
                                          : Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      _isNavigating
                                          ? 'Stop'
                                          : 'Start Navigation',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _clearRoute();

                                      setState(() {
                                        _showSearchPanel = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[300],
                                      foregroundColor: Colors.grey[700],
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Clear',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Route Options
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: routeOptions.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final route = routeOptions[index];
                            final isSelected = selectedRoute == route;
                            return GestureDetector(
                              onTap: () {
                                setState(() => selectedRoute = route);
                              },
                              child: Container(
                                color: isSelected
                                    ? Colors.blue.withOpacity(0.05)
                                    : Colors.transparent,
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.grey[200],
                                      ),
                                      child: Icon(
                                        route.mode.icon,
                                        size: 20,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            route.mode.displayName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '${route.durationText} • ${route.distanceText}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
