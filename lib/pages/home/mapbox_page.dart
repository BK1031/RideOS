import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_os/pages/home/home_page.dart';
import 'package:ride_os/utils/config.dart';
import 'package:ride_os/utils/theme.dart';

class MapBoxPage extends StatefulWidget {
  LatLng start;
  LatLng end;
  String destination;
  MapBoxPage(this.start, this.end, this.destination);
  @override
  _MapBoxPageState createState() => _MapBoxPageState(this.start, this.end, this.destination);
}

class _MapBoxPageState extends State<MapBoxPage> {

  LatLng start;
  LatLng end;
  String destination;

  MapBoxNavigation? _directions;
  MapBoxOptions? _options;

  String _platformVersion = 'Unknown';
  String _instruction = "";
  double _distanceRemaining = 0;
  double _durationRemaining = 0;
  MapBoxNavigationViewController? _controller;
  bool _routeBuilt = false;
  bool _isNavigating = false;

  Position? position;
  StreamSubscription<Position>? positionStream;

  _MapBoxPageState(this.start, this.end, this.destination);

  @override
  void initState() {
    super.initState();
    initializeNavigation();
    getLocation();
  }


  @override
  void dispose() {
    super.dispose();
    positionStream!.cancel();
    _controller!.clearRoute();
    _controller!.finishNavigation();
  }

  Future<void> getLocation() async {
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
      if (mounted) {
        setState(() {
          this.position = position;
        });
      }
      print(position.speed);
    });
  }

  Future<void> initializeNavigation() async {
    _directions = MapBoxNavigation(onRouteEvent: _onEmbeddedRouteEvent);
    _options = MapBoxOptions(
        zoom: 13.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        longPressDestinationEnabled: false,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        mode: driveMode ? MapBoxNavigationMode.drivingWithTraffic : MapBoxNavigationMode.cycling,
        units: VoiceUnits.imperial,

        // CHANGE TO FALSE WHEN DEPLOYED
        simulateRoute: false,

        language: "en");
  }

  Future<void> startNavigation() async {
    _controller!.clearRoute();
    final _origin = WayPoint(
        name: "Origin",
        latitude: start.latitude,
        longitude: start.longitude);
    final _stop1 = WayPoint(
        name: destination,
        latitude: end.latitude,
        longitude: end.longitude);
    await _controller!.buildRoute(wayPoints: [_origin, _stop1]);
    _controller!.startNavigation();
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    // _distanceRemaining = await _directions!.distanceRemaining;
    // _durationRemaining = await _directions!.durationRemaining;
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction!;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        print("arrived!");
        await Future.delayed(Duration(seconds: 3));
        await _controller!.finishNavigation();
        state = "home";
        break;
      case MapBoxEvent.navigation_finished:
        print("finished!");
        await Future.delayed(Duration(seconds: 3));
        await _controller!.finishNavigation();
        state = "home";
        break;
      case MapBoxEvent.navigation_cancelled:
        await Future.delayed(Duration(seconds: 3));
        await _controller!.finishNavigation();
        _routeBuilt = false;
        _isNavigating = false;
        break;
      default:
        break;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currBackgroundColor,
      body: Container(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    SafeArea(
                      bottom: false,
                      right: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              color: Colors.red,
                              child: Text("End"),
                              onPressed: () async {
                                state = "home";
                                navigating = false;
                                body = HomePage();
                                mapboxWidget = Container();
                              },
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(8),),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Card(
                              color: currBackgroundColor.withOpacity(0.8),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${position != null ? ((position!.speed * 2.237).round() > 0 ? (position!.speed * 2.237).round() : "0") : "–"}", style: TextStyle(color: currTextColor, fontSize: 35),),
                                    Text("mph", style: TextStyle(color: currTextColor, fontSize: 18),),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.only(left: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: MapBoxNavigationView(
                    options: _options,
                    onRouteEvent: _onEmbeddedRouteEvent,
                    onCreated: (MapBoxNavigationViewController controller) async {
                      _controller = controller;
                      startNavigation();
                    }
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
