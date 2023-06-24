import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_box_test/app_constants.dart';
import 'package:map_box_test/widgets/app_web_view.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MapBox test'),
      ),
      body: FlutterMap(
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
                    return const AppWebView(url: AppConstants.mapBoxWebPage);
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
        ],
      ),
    );
  }
}
