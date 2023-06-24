import 'package:latlong2/latlong.dart';

class Place {
  final String? image;
  final String title;
  final LatLng coordinates;
  final String address;
  final int rating;

  const Place({
    this.image,
    required this.coordinates,
    required this.title,
    required this.address,
    required this.rating,
  });

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      image: map['image'],
      coordinates: LatLng(map['lat'], map['lng']),
      title: map['title'],
      address: map['address'],
      rating: map['rating'],
    );
  }
}
