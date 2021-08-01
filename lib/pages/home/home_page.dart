import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_os/pages/home/mapbox_page.dart';
import 'package:ride_os/utils/config.dart';
import 'package:ride_os/utils/secret.dart';
import 'package:ride_os/utils/theme.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Completer<GoogleMapController> _controller = Completer();
  StreamSubscription<Position>? positionStream;
  Set<Marker> _markers = Set();
  Set<Polyline> _polylines = Set();

  Position? position;

  bool mapBrowsing = false;

  bool searchActive = false;
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  String searchText = "";

  List<dynamic> placeList = [];
  Widget placeDetailWidget = new Container();
  bool placeSelected = false;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 10,
  );

  Future<void> getLocation() async {
    final GoogleMapController controller = await _controller.future;
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
      if (!mapBrowsing) {
        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 17,
            tilt: driveMode ? 1000 : 0,
            bearing: position.heading
        )));
      }
      if (mounted) {
        setState(() {
          this.position = position;
        });
      }
    });
  }

  void setMapStyle() {
    switch (mapPref) {
      case "day":
        selectedMapTheme = mapDayTheme;
        break;
      case "day-plain":
        selectedMapTheme = mapDayPlainTheme;
        break;
      case "night":
        selectedMapTheme = mapNightTheme;
        break;
      case "night-plain":
        selectedMapTheme = mapNightPlainTheme;
        break;
      default:
        if (mapPref == "automatic") {
          if (DateTime.now().hour > 6 && DateTime.now().hour < 20) {
            selectedMapTheme = mapDayTheme;
          }
          else selectedMapTheme = mapNightTheme;
        }
        else {
          if (DateTime.now().hour > 6 && DateTime.now().hour < 20) {
            selectedMapTheme = mapDayPlainTheme;
          }
          else selectedMapTheme = mapNightPlainTheme;
        }
    }
  }

  Future<void> searchPlaces(String query) async {
    var response = await http.get(Uri.parse("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&location=${position!.latitude},${position!.longitude}&key=$GOOGLE_PLACES_API_KEY"));
    print("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&location=${position!.latitude},${position!.longitude}&key=$GOOGLE_PLACES_API_KEY");
    if (response.statusCode == 200) {
      setState(() {
        placeList = json.decode(response.body)['predictions'];
      });
    } else {
      print('Failed to load predictions');
    }
  }

  Future<void> getPlaceDetails(String id) async {
    var response = await http.get(Uri.parse("https://maps.googleapis.com/maps/api/place/details/json?place_id=$id&key=$GOOGLE_PLACES_API_KEY"));
    var directions = await http.get(Uri.parse("https://maps.googleapis.com/maps/api/directions/json?origin=${position!.latitude},${position!.longitude}&destination=place_id:$id&mode=${driveMode ? "driving" : "bicycling"}&key=$GOOGLE_PLACES_API_KEY"));
    print(directions.body);
    if (response.statusCode == 200) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(json.decode(directions.body)["routes"][0]["bounds"]["southwest"]["lat"], json.decode(directions.body)["routes"][0]["bounds"]["southwest"]["lng"]),
          northeast: LatLng(json.decode(directions.body)["routes"][0]["bounds"]["northeast"]["lat"], json.decode(directions.body)["routes"][0]["bounds"]["northeast"]["lng"]),
        ),
        32
      ));
      setState(() {
        placeSelected = true;
        _markers.clear();
        _polylines.clear();
        _markers.add(Marker(
          markerId: MarkerId(id),
          position: LatLng(json.decode(response.body)["result"]["geometry"]["location"]["lat"], json.decode(response.body)["result"]["geometry"]["location"]["lng"]),
        ));
        PolylinePoints polylinePoints = PolylinePoints();
        _polylines.add(Polyline(
          polylineId: PolylineId(id),
          points: polylinePoints.decodePolyline(json.decode(directions.body)["routes"][0]["overview_polyline"]["points"]).map((e) => LatLng(e.latitude, e.longitude)).toList(),
          color: mainColor.withOpacity(0.8),
          width: 5,
        ));
        placeDetailWidget = Card(
          color: currBackgroundColor.withOpacity(0.8),
          child: new Container(
            padding: EdgeInsets.only(left: 16, top: 8, right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    new Image.network(json.decode(response.body)["result"]["icon"], color: mainColor, height: 35,),
                    new Padding(padding: EdgeInsets.all(8)),
                    new Expanded(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text(
                            json.decode(response.body)["result"]["name"],
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new Text(
                            "${json.decode(directions.body)["routes"][0]["legs"][0]["distance"]["text"]} • ${json.decode(directions.body)["routes"][0]["legs"][0]["duration"]["text"]}",
                            style: TextStyle(color: mainColor, fontStyle: FontStyle.italic),
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new Text(
                            json.decode(response.body)["result"]["formatted_address"],
                            style: TextStyle(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 70,
                  child: Row(
                    children: [
                      Expanded(
                        child: new CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: new Text("Go", style: TextStyle(color: mainColor),),
                          color: currCardColor,
                          onPressed: () {
                            setState(() {
                              body = MapBoxPage(
                                LatLng(json.decode(directions.body)["routes"][0]["legs"][0]["start_location"]["lat"], json.decode(directions.body)["routes"][0]["legs"][0]["start_location"]["lng"]),
                                LatLng(json.decode(directions.body)["routes"][0]["legs"][0]["end_location"]["lat"], json.decode(directions.body)["routes"][0]["legs"][0]["end_location"]["lng"]),
                                json.decode(response.body)["result"]["name"]
                              );
                              state = "mapbox";
                              navigating = true;
                              mapboxWidget = MapBoxPage(
                                LatLng(json.decode(directions.body)["routes"][0]["legs"][0]["start_location"]["lat"], json.decode(directions.body)["routes"][0]["legs"][0]["start_location"]["lng"]),
                                LatLng(json.decode(directions.body)["routes"][0]["legs"][0]["end_location"]["lat"], json.decode(directions.body)["routes"][0]["legs"][0]["end_location"]["lng"]),
                                json.decode(response.body)["result"]["name"]
                              );
                            });
                          },
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(4)),
                      Expanded(
                        child: new CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: new Text("Cancel", style: TextStyle(color: Colors.red),),
                          color: currCardColor,
                          onPressed: () {
                            setState(() {
                              placeSelected = false;
                              mapBrowsing = false;
                              _polylines.clear();
                              _markers.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      });
    } else {
      print('Failed to load place');
    }
  }

  @override
  void initState() {
    super.initState();
    getLocation();
    setMapStyle();
  }


  @override
  void dispose() {
    super.dispose();
    positionStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButton: Visibility(
        visible: debug,
        child: Card(
          color: currBackgroundColor.withOpacity(0.8),
          child: Container(
            padding: EdgeInsets.all(8),
            height: 100,
            child: Column(
              children: [
                Text("Lat: ${position?.latitude}", style: TextStyle(color: currTextColor),),
                Text("Long: ${position?.longitude}", style: TextStyle(color: currTextColor),),
                Text("Heading: ${position?.heading}", style: TextStyle(color: currTextColor),),
                Text("Speed: ${position?.speed}", style: TextStyle(color: currTextColor),),
              ],
            ),
          ),
        )
      ),
      body: Stack(
        children: [
          GoogleMap(
            trafficEnabled: !placeSelected,
            buildingsEnabled: true,
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 5),
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            compassEnabled: false,
            markers: _markers,
            polylines: _polylines,
            initialCameraPosition: _kGooglePlex,
            onCameraMoveStarted: () {
              // setState(() {
                // mapBrowsing = true;
              // });
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              controller.setMapStyle(selectedMapTheme);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Card(
                      color: currBackgroundColor.withOpacity(0.8),
                      child: AnimatedContainer(
                        width: searchActive ? MediaQuery.of(context).size.width / 2 : 56,
                        height: searchText != "" ? MediaQuery.of(context).size.height - 90 : 56,
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Visibility(visible: searchActive, child: Padding(padding: EdgeInsets.all(8))),
                                Expanded(
                                  child: Visibility(
                                    visible: !placeSelected,
                                    child: TextField(
                                      controller: searchController,
                                      focusNode: searchFocusNode,
                                      decoration: InputDecoration(
                                        hintText: "Search",
                                        border: InputBorder.none
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          searchText = value;
                                        });
                                        searchPlaces(value.replaceAll(" ", "+"));
                                      },
                                    ),
                                  )
                                ),
                                FloatingActionButton(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: Icon(searchActive ? Icons.clear : Icons.search, color: Colors.white,),
                                  onPressed: () {
                                    if (searchActive) {
                                      searchController.clear();
                                      searchFocusNode.unfocus();
                                      setState(() {
                                        searchActive = false;
                                        searchText = "";
                                      });
                                    }
                                    else {
                                      setState(() {
                                        searchActive = true;
                                        placeSelected = false;
                                        mapBrowsing = false;
                                        _polylines.clear();
                                        _markers.clear();
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            new Visibility(
                              visible: searchText != "",
                              child: new Expanded(
                                child: Scrollbar(
                                  child: ListView.builder(
                                    itemCount: placeList.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        onTap: () {
                                          print("Getting place details");
                                          getPlaceDetails(placeList[index]["place_id"]);
                                          setState(() {
                                            searchText = "";
                                            searchActive = false;
                                            mapBrowsing = true;
                                          });
                                          searchController.clear();
                                        },
                                        title: Text(placeList[index]["structured_formatting"]["main_text"]),
                                        subtitle: Text(placeList[index]["description"]),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      width: placeSelected ? MediaQuery.of(context).size.width / 3 : 0,
                      height: placeSelected ? null : 0,
                      duration: const Duration(milliseconds: 200),
                      child: placeDetailWidget
                    )
                  ],
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(),
              Visibility(
                visible: searchText == "" && !searchFocusNode.hasFocus && !placeSelected,
                child: Container(
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
              ),
            ],
          )
        ],
      ),
    );
  }
}
