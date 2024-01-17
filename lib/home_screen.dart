import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? mapController;
  LocationData? currentLocation;
  Set<LatLng> polylinePoints = <LatLng>{};
  bool _isOpenInfoWindow = false;

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });

    _fetchLocation();

    Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchLocation();
    });
  }

  Future<void> _fetchLocation() async {
    var location = Location();
    LocationData locationData = await location.getLocation();

    // Update marker position
    mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(
        locationData.latitude ?? 23.808397346705693,
        locationData.longitude ?? 90.41005799898663,
      )),
    );

    // Update polyline
    setState(() {
      polylinePoints.add(LatLng(
        locationData.latitude ?? 23.808397346705693,
        locationData.longitude ?? 90.41005799898663,
      ));
    });

    // Update current location
    setState(() {
      currentLocation = locationData;
    });
    if (_isOpenInfoWindow) {
      _showInfoWindow();
    }
  }

  InfoWindow infoWindow() {
    return InfoWindow(
      title: 'My current location',
      snippet:
          'Lat: ${currentLocation?.latitude?.toStringAsFixed(6) ?? 23.808397346705693}, Lng: ${currentLocation?.longitude?.toStringAsFixed(6) ?? 90.41005799898663}',
    );
  }

  void _showInfoWindow() {
    mapController?.showMarkerInfoWindow(const MarkerId('userMarker'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Location Tracker'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(23.808397346705693,
              90.41005799898663), // Default initial position
          zoom: 12.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        polylines: {
          Polyline(
            polylineId: const PolylineId('userRoute'),
            points: polylinePoints.toList(),
            color: Colors.blue,
            width: 5,
          ),
        },
        markers: {
          Marker(
            markerId: const MarkerId('userMarker'),
            position: LatLng(
              currentLocation?.latitude ?? 23.808397346705693,
              currentLocation?.longitude ?? 90.41005799898663,
            ),
            infoWindow: infoWindow(),
            onTap: () {
              setState(() {
                _isOpenInfoWindow = true;
              });
              _showInfoWindow();
            },
          ),
        },
        mapType: MapType.terrain,
      ),
    );
  }
}
