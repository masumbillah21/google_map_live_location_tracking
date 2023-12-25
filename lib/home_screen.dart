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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Animation and Tracking'),
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
            onTap: () {
              _showInfoWindow();
            },
          ),
        },
        mapType: MapType.terrain,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });

    // Fetch user's initial location
    _fetchLocation();

    // Fetch location every 10 seconds
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
  }

  void _showInfoWindow() {
    mapController?.showMarkerInfoWindow(const MarkerId('userMarker'));
  }
}
