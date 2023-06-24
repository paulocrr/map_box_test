import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_box_test/app_constants.dart';
import 'package:map_box_test/models/place.dart';
import 'package:map_box_test/services/places_service.dart';
import 'package:map_box_test/widgets/app_web_view.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final placesService = PlacesService();
  final pageController = PageController();
  final mapController = MapController();
  late Place? currentPlace;
  var selectedMarker = 0;
  List<Place> result = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MapBox test'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: placesService.getPlaces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Fallo al connectar con la base de datos'),
            );
          }

          final data = snapshot.data?.docs;

          if (data != null) {
            List<Place> result = data.map((e) {
              final data = e.data();
              return Place.fromMap(data as Map<String, dynamic>);
            }).toList();

            currentPlace = result.first;

            return Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    maxZoom: 18,
                    minZoom: 4,
                    zoom: 13,
                    center: AppConstants.initialLocation,
                  ),
                  nonRotatedChildren: [
                    SimpleAttributionWidget(
                      source: const Text('MapBox'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const AppWebView(
                                  url: AppConstants.mapBoxWebPage);
                            },
                          ),
                        );
                      },
                    )
                  ],
                  children: [
                    TileLayer(
                      urlTemplate: AppConstants.mapBoxUrl,
                    ),
                    MarkerLayer(
                      markers: [
                        ...result
                            .map(
                              (e) => Marker(
                                rotate: true,
                                point: e.coordinates,
                                builder: (_) => const Icon(
                                  Icons.place,
                                  size: 48,
                                  color: Colors.red,
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 88,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: result.length,
                      onPageChanged: (index) {
                        selectedMarker = index;
                        currentPlace = result[index];
                        _mapMove(
                          currentPlace?.coordinates ??
                              AppConstants.initialLocation,
                          13,
                        );
                      },
                      itemBuilder: (context, index) {
                        final item = result[index];

                        return Card(
                          elevation: 5,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                item.image ?? AppConstants.defaultImageUrl,
                              ),
                            ),
                            title: Text(item.title),
                            subtitle: Text(item.address),
                            trailing: Text(
                              '${item.rating}',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            );
          }

          return const Center(
            child: Text('Ocurrio un error desconocido'),
          );
        },
      ),
    );
  }

  void _mapMove(LatLng destination, double destinationZoom) {
    final latTween = Tween<double>(
      begin: mapController.center.latitude,
      end: destination.latitude,
    );

    final lngTween = Tween<double>(
      begin: mapController.center.longitude,
      end: destination.longitude,
    );

    final zoomTween = Tween<double>(
      begin: mapController.zoom,
      end: destinationZoom,
    );

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(
      () {
        mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation),
        );
      },
    );

    animation.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          controller.dispose();
        }
      },
    );

    controller.forward();
  }
}
