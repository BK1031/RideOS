import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rideos/config/config.dart';
import 'package:rideos/pages/map/mapbox_page.dart';
import 'package:rideos/utils/alert_service.dart';
import 'package:rideos/utils/logger.dart';

class SkeletonPage extends StatefulWidget {
  const SkeletonPage({super.key});

  @override
  State<SkeletonPage> createState() => _SkeletonPageState();
}

class _SkeletonPageState extends State<SkeletonPage> {

  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AlertService.showErrorDialog(context, "Location Error", "Location services are disabled", null);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AlertService.showErrorDialog(context, "Location Error", "Location permissions are denied", null);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AlertService.showErrorDialog(context, "Location Error", "Location permissions are permanently denied, we cannot request permissions.", null);
    }

    positionStream = Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      logger.log("Position: ${position.toJson()}", LogLevel.debug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapboxPage(),
    );
  }
}
