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

class _MapScreenState extends State<MapScreen> {
  final placesService = PlacesService();
  final pageController = PageController();

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

            return Stack(
              children: [
                FlutterMap(
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
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: result.length,
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
}
