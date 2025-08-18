import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/core/services/LocationService.dart';
import 'package:buldm/features/Add_Post/data/model/mapstyledata_model.dart';
import 'package:buldm/features/Add_Post/presentation/view/screens/PostView.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/view/screens/PostWidget.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapLocationScreen extends StatefulWidget {
  const MapLocationScreen({super.key});

  @override
  State<MapLocationScreen> createState() => _MapLocationScreen();
}

class _MapLocationScreen extends State<MapLocationScreen>
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
              icon: const Icon(Icons.location_searching_outlined,
                  color: Colors.black87),
              onPressed: () => {
                    LocationService.requestAndGetLocation(context)
                        .then((position) {
                      if (position != null) {
                        setState(() {
                          _initialPosition =
                              LatLng(position.latitude, position.longitude);
                          mapController.move(_initialPosition, 13.0);
                        });
                      }
                    })
                  }),
        ),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          if (state is PostLoaded) {
            var posts = state.posts;
            return Stack(
              children: [
                // MAP
                FadeTransition(
                  opacity: _fadeController,
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: _initialPosition,
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: tileUrl,
                        userAgentPackageName: 'com.example.buldm',
                      ),
                      MarkerLayer(
                        markers: posts.asMap().entries.map((entry) {
                          final index = entry.key;
                          final post = entry.value;
                          return Marker(
                            point: LatLng(post.location.coordinates[0],
                                post.location.coordinates[1]),
                            width: 40,
                            height: 40,
                            child: ScaleTransition(
                              scale:
                                  Tween<double>(begin: 0.5, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _scaleController,
                                  curve: Curves.elasticOut,
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  //here next time we add the post details screen for one post
                                  // Handle marker tap
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MultiBlocProvider(
                                            providers: [
                                              BlocProvider(
                                                  create: (context) =>
                                                      sl<PostBloc>()),
                                              BlocProvider(
                                                  create: (context) =>
                                                      sl<UserBloc>()),
                                            ],
                                            child: Postview(
                                              post: post,
                                              child: SliverToBoxAdapter(
                                                child: PostWidget(
                                                  post: post,
                                                  index: index,
                                                ),
                                              ),
                                            )),
                                      ));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${localization.post}: ${post.description}\n${localization.status}: ${post.status}',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: post.status == 'found'
                                        ? Colors.green
                                        : Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: post.status == 'found'
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
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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
                                color: isSelected
                                    ? entry.value.color
                                    : Colors.grey[600],
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
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        },
      ),
    );
  }
}
