import 'package:buldm/core/services/LocationService.dart';
import 'package:buldm/features/Add_Post/data/model/mapstyledata_model.dart';
import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class SoloPostLocation extends StatefulWidget {
  final PostEntity post;

  const SoloPostLocation({
    super.key,
    required this.post,
  });

  @override
  State<SoloPostLocation> createState() => _SoloPostLocationState();
}

class _SoloPostLocationState extends State<SoloPostLocation>
    with TickerProviderStateMixin {
  final MapController mapController = MapController();
  LatLng _initialPosition = LatLng(30.0444, 31.2357); // Default to Cairo, Egypt

  String _selectedStyle = 'streets-v2';

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  final String _apiKey = dotenv.env['mapapikey']!;
  final Map<String, MapStyleData> _mapStyles = {
    'streets-v2': MapStyleData('Streets', Icons.map, Color(0xFF2196F3)),
    'satellite':
        MapStyleData('Satellite', Icons.satellite_alt, Color(0xFF4CAF50)),
  };

  @override
  void initState() {
    super.initState();

    // Set initial position to post location
    _initialPosition = LatLng(
      widget.post.location.coordinates[0],
      widget.post.location.coordinates[1],
    );

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

    _fadeController.forward();
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
  }

  Future<void> _openInGoogleMaps() async {
    final double lat = widget.post.location.coordinates[0];
    final double lng = widget.post.location.coordinates[1];
    // Try geo: scheme first (opens Google Maps app if available), then HTTPS fallback
    final Uri geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    final Uri httpsUri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      final bool launchedGeo = await launchUrl(
        geoUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launchedGeo) {
        await launchUrl(
          httpsUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
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
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Container(
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
              icon: const Icon(Icons.location_searching_outlined,
                  color: Colors.black87),
              onPressed: () => {
                LocationService.requestAndGetLocation(context).then((position) {
                  if (position != null) {
                    setState(() {
                      _initialPosition =
                          LatLng(position.latitude, position.longitude);
                      mapController.move(_initialPosition, 13.0);
                    });
                  }
                })
              },
            ),
          ),
          // "Go to item" button
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: InkWell(
              onTap: _openInGoogleMaps,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7F7FD5),
                      Color(0xFF86A8E7),
                      Color(0xFF91EAE4)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: const Text(
                  'Go to',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // MAP
          FadeTransition(
            opacity: _fadeController,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: _initialPosition,
                initialZoom: 15.0, // Higher zoom for single post
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  userAgentPackageName: 'com.example.buldm',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        widget.post.location.coordinates[0],
                        widget.post.location.coordinates[1],
                      ),
                      width: 50,
                      height: 50,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _scaleController,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${localization.post}: ${widget.post.description}\n${localization.status}: ${widget.post.status}',
                                ),
                                backgroundColor: widget.post.status == 'found'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: widget.post.status == 'found'
                                  ? Colors.green
                                  : Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.post.status == 'found'
                                      ? Colors.green.withOpacity(0.5)
                                      : Colors.red.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // POST INFO CARD
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.post.status == 'found'
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.post.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.post.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // STYLE SELECTOR
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
        ],
      ),
    );
  }
}
