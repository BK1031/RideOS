import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rideos/config/config.dart';
import 'package:rideos/pages/map/mapbox_page.dart';
import 'package:rideos/utils/alert_service.dart';

class SkeletonPage extends StatefulWidget {
  const SkeletonPage({super.key});

  @override
  State<SkeletonPage> createState() => _SkeletonPageState();
}

class _SkeletonPageState extends State<SkeletonPage> {

  @override
  void initState() {
    super.initState();
    _determinePosition();
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

    Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      logger.log("Location: ${position.latitude}, ${position.longitude}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapboxPage(),
    );
  }
}
