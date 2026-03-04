import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NearYouScreen extends StatelessWidget {
  const NearYouScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nearByLocations = [
      'King Abdul Aziz Historical Center',
      'King Fahad Cultural Center',
      'Saudi National Museum',
    ];

    // map center Riyadh
    final mapController = MapController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Near You'),
        backgroundColor: const Color(0xFF6B4B8A),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 250,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(24.7136, 46.6753),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: LatLng(24.6760, 46.6668),
                      child: const Icon(Icons.location_on, color: Colors.red),
                    ),
                    Marker(
                      width: 40,
                      height: 40,
                      point: LatLng(24.7072, 46.6907),
                      child: const Icon(Icons.location_on, color: Colors.red),
                    ),
                    Marker(
                      width: 40,
                      height: 40,
                      point: LatLng(24.6877, 46.7219),
                      child: const Icon(Icons.location_on, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: nearByLocations.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(nearByLocations[index]),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
