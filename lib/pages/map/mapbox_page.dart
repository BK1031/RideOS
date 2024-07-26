import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rideos/config/config.dart';

class MapboxPage extends StatefulWidget {
  const MapboxPage({super.key});

  @override
  State<MapboxPage> createState() => _MapboxPageState();
}

class _MapboxPageState extends State<MapboxPage> {

  MapboxMapController? mapController;
  Position? localPosition;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission;
    await Geolocator.isLocationServiceEnabled();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return;
    }
    Geolocator.getPositionStream().listen((Position position) {
      mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16.0,
          bearing: position.heading,
          tilt: 60.0,
        ),
      ));
      setState(() {
        localPosition = position;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapboxMap(
            accessToken: MAPBOX_PUBLIC_TOKEN,
            onMapCreated: (MapboxMapController controller) {
              mapController = controller;
              _determinePosition();
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194),
              zoom: 11.0,
            ),
            attributionButtonMargins: const Point(-32, -32),
            compassEnabled: false,
            logoViewMargins: const Point(-32, -32),
            trackCameraPosition: true,
            myLocationEnabled: true,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 16),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${localPosition != null ? (localPosition!.speed * 2.23694).round() : 0}",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
                        ),
                        Text(
                          "MPH",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
