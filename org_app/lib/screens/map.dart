import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:org/utilities/providers.dart';
import 'package:org/utilities/shared.dart';
import 'package:provider/provider.dart';

class Mapx extends StatefulWidget {
  const Mapx({super.key});

  @override
  State<Mapx> createState() => _MapxState();
}

class _MapxState extends State<Mapx> {
  LatLng? _selectedLocation;
  final MapController _mapCon = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (() async {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          _mapCon.move(
              LatLng(position.latitude, position.longitude), _mapCon.zoom);
        }),
        child: const Icon(Icons.my_location),
      ),
      appBar: buildAppBar(context, "Set Location", button: const BackButton()),
      body: Stack(children: [
        FlutterMap(
          mapController: _mapCon,
          options: MapOptions(
            center: _selectedLocation ?? LatLng(36.189292, 44.009992),
            zoom: 12,
            onTap: (tapPosition, point) {
              setState(() {
                _selectedLocation = point;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              maxZoom: 19,
            ),
            _selectedLocation != null
                ? MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation as LatLng,
                        builder: (context) {
                          return const Icon(
                            Icons.location_on,
                            size: 50,
                            color: Colors.red,
                          );
                        },
                      ),
                    ],
                  )
                : const Text(""),
            CurrentLocationLayer(),
          ],
        ),
        Container(
          margin: const EdgeInsets.all(15),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              child: const Text("Set Location"),
              onPressed: () {
                if (_selectedLocation == null) {
                  snackbar(context, "Set a Location First", 2);
                  return;
                }
                Provider.of<LocationProvider>(context, listen: false)
                    .setOrgLocation(_selectedLocation as LatLng);
                Console.log("Location Set");
                Navigator.pop(context);
              },
            ),
          ),
        )
      ]),
    );
  }
}
