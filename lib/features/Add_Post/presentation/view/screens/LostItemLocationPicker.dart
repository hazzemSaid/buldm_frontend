import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LostItemLocationPicker extends StatefulWidget {
  const LostItemLocationPicker({super.key});

  @override
  State<LostItemLocationPicker> createState() => _LostItemLocationPickerState();
}

class _LostItemLocationPickerState extends State<LostItemLocationPicker>
    with TickerProviderStateMixin {
  final MapController mapController = MapController();
  final LatLng _initialPosition = LatLng(30.033333, 31.233334); // Cairo

  LatLng? _pickedLatLng;
  bool _isMapReady = false;
  String _selectedStyle = 'streets-v2';

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  final String _apiKey = 'KIM7YAdBi5YGtDz7vVue';

  final Map<String, MapStyleData> _mapStyles = {
    'streets-v2': MapStyleData('Streets', Icons.map, Color(0xFF2196F3)),
    'satellite':
        MapStyleData('Satellite', Icons.satellite_alt, Color(0xFF4CAF50)),
    'topo-v2': MapStyleData('Terrain', Icons.terrain, Color(0xFF795548)),
    'basic-v2': MapStyleData('Basic', Icons.layers, Color(0xFF607D8B)),
    'bright': MapStyleData('Bright', Icons.wb_sunny, Color(0xFFFFC107)),
    'dark-matter': MapStyleData('Dark', Icons.dark_mode, Color(0xFF424242)),
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onTapMap(LatLng point) {
    setState(() {
      _pickedLatLng = point;
    });
    _scaleController.reset();
    _scaleController.forward();

    // Haptic feedback
    // HapticFeedback.lightImpact();
  }

  void _confirmLocation() {
    // Handel this later with Bloc
    if (_pickedLatLng != null) {
      Navigator.pop(context, {
        'coordinates': [_pickedLatLng!.longitude, _pickedLatLng!.latitude],
        'placeName': 'Selected Location',
      });
    }
  }

  void _resetSelection() {
    setState(() {
      _pickedLatLng = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tileUrl =
        'https://api.maptiler.com/maps/$_selectedStyle/256/{z}/{x}/{y}.png?key=$_apiKey';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutCubic,
          )),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Pick Lost Item Location',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map
          FadeTransition(
            opacity: _fadeController,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: _initialPosition,
                initialZoom: 13.0,
                onTap: (_, point) => _onTapMap(point),
                onMapReady: () {
                  setState(() {
                    _isMapReady = true;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  userAgentPackageName: 'com.example.lost_item_app',
                ),
                if (_pickedLatLng != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pickedLatLng!,
                        width: 60,
                        height: 60,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _scaleController,
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Map Style Selector
          Positioned(
            top: 120,
            right: 16,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: Curves.easeOutCubic,
              )),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _mapStyles.entries.map((entry) {
                    final isSelected = _selectedStyle == entry.key;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStyle = entry.key;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? entry.value.color.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? entry.value.color
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          entry.value.icon,
                          color:
                              isSelected ? entry.value.color : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Instruction Card
          if (_pickedLatLng == null)
            Positioned(
              top: 140,
              left: 16,
              right: 80,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.easeOutCubic,
                )),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.touch_app,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Tap on the map to mark where you lost your item',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Selected Location Info
          if (_pickedLatLng != null)
            Positioned(
              top: 140,
              left: 16,
              right: 80,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _scaleController,
                  curve: Curves.easeOutCubic,
                )),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Location Selected',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _resetSelection,
                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lat: ${_pickedLatLng!.latitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Lng: ${_pickedLatLng!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Confirm Button
          if (_pickedLatLng != null)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _scaleController,
                  curve: Curves.easeOutCubic,
                )),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _confirmLocation,
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Confirm Location',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MapStyleData {
  final String name;
  final IconData icon;
  final Color color;

  MapStyleData(this.name, this.icon, this.color);
}
