import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ride_os/pages/home/home_page.dart';
import 'package:ride_os/pages/menu_page.dart';
import 'package:ride_os/pages/spotify/spotify_now_playing_page.dart';
import 'package:ride_os/utils/config.dart';
import 'package:ride_os/utils/secret.dart';
import 'package:ride_os/utils/theme.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/crossfade_state.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';


class SkeletonPage extends StatefulWidget {
  @override
  _SkeletonPageState createState() => _SkeletonPageState();
}

class _SkeletonPageState extends State<SkeletonPage> {

  String batteryLevel = "";
  bool charging = false;
  bool batteryLowPowerMode = false;

  Weather? weather;

  bool _loading = false;
  final Logger _logger = Logger();

  CrossfadeState? crossfadeState;

  String? imageUri = "";
  Image? cover = Image.asset("images/play_button");

  Future<void> getBattery() async {
    var battery = Battery();
    batteryLevel = (await battery.batteryLevel).toString();
    batteryLowPowerMode = await battery.isInBatterySaveMode;
    // print(batteryLevel);
    battery.onBatteryStateChanged.listen((BatteryState state) {
      if (state.index == 1) charging = true;
      else charging = false;
    });
    setState(() {});
  }

  Future<void> getConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print("mobile");
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("wifi");
    }
  }

  Future<void> getWeather() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    WeatherFactory wf = new WeatherFactory(WEATHER_API_KEY);
    weather = await wf.currentWeatherByLocation(position.latitude, position.longitude);
    // print("Weather: $weather");
    setState(() {});
  }

  Future<void> getParking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // TODO: Parking feature
  }

  @override
  void initState() {
    super.initState();
    getBattery();
    new Timer.periodic(const Duration(seconds: 1), (Timer t) => getBattery());
    getConnection();
    getWeather();
    new Timer.periodic(const Duration(minutes: 5), (Timer t) => getWeather());
    if (spotifyToken != "") {
      connectToSpotifyRemote();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                body,
                SafeArea(
                  child: Container(
                    padding: EdgeInsets.only(top: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Visibility(
                                visible: state == "home" || state == "mapbox",
                                child: Card(
                                  color: currBackgroundColor.withOpacity(0.8),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("${DateFormat.jm().format(DateTime.now())}", style: TextStyle(color: currTextColor, fontSize: 25),),
                                        Text("${DateFormat.yMMMEd().format(DateTime.now())}", style: TextStyle(color: currTextColor, fontSize: 18),),
                                      ],
                                    ),
                                  )
                                ),
                              ),
                              Visibility(
                                visible: (state == "home" || state == "mapbox") && spotifyToken != "",
                                child: Card(
                                    color: currBackgroundColor.withOpacity(0.8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                      onTap: () {
                                        print("spotify now playing");
                                        body = SpotifyNowPlayingPage();
                                        state = "spotify-now-playing";
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        child: _buildPlayerStateWidget()
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: state == "mapbox" ? 4 : 3,
                          child: Container(
                            // color: Colors.greenAccent,
                          )
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ),
          Container(
            padding: EdgeInsets.all(6),
            height: 50,
            color: currBackgroundColor,
            child: SafeArea(
              left: true,
              right: true,
              bottom: false,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: CupertinoButton(
                      child: Image.asset(state == "menu" ? "images/dashboard.png" : "images/home_button.png", color: Colors.white, height: 50,),
                      padding: EdgeInsets.all(0),
                      color: currCardColor,
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        if (state == "menu") {
                          if (navigating) {
                            setState(() {
                              state = "mapbox";
                              body = mapboxWidget;
                            });
                          }
                          else {
                            setState(() {
                              state = "home";
                              body = HomePage();
                            });
                          }
                        }
                        else {
                          setState(() {
                            state = "menu";
                            body = MenuPage();
                          });
                        }
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8),),
                  Expanded(
                    flex: 1,
                    child: CupertinoButton(
                      child: Image.asset(driveMode ? "images/car.png" : "images/bike.png", color: Colors.white, height: 25,),
                      padding: EdgeInsets.all(0),
                      color: currCardColor,
                      onPressed: () {
                        setState(() {
                          driveMode = !driveMode;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("${driveMode ? "Drive" : "Bike"} mode activated!", style: TextStyle(color: currTextColor), textAlign: TextAlign.center,),
                          backgroundColor: currBackgroundColor.withOpacity(0.8),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                          width: 200,
                        ));
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8),),
                  Expanded(
                    flex: 1,
                    child: CupertinoButton(
                      child: Image.asset("images/parking.png", color: Colors.white, height: 35,),
                      padding: EdgeInsets.all(0),
                      color: currCardColor,
                      onPressed: () {
                        getParking();
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8),),
                  Text(
                    "RideOS ${appVersion.major}.${appVersion.minor}",
                    style: TextStyle(color: currTextColor),
                  ),
                  Padding(padding: EdgeInsets.all(8),),
                  Expanded(
                    flex: 1,
                    child: CupertinoButton(
                      child: Container(
                        child: Stack(
                          children: [
                            // Center(child: Image.asset("images/battery.png", color: Colors.white, height: 30,)),
                            // Center(child: Text("100 %", style: TextStyle(fontSize: 14),)),
                            Center(child: Text("$batteryLevel %", style: TextStyle(fontSize: 16, color: batteryLowPowerMode ? warningColor : charging ? successColor : currTextColor),))
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(0),
                      color: currCardColor,
                      onPressed: () {
                        getBattery();
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8),),
                  Expanded(
                    flex: 2,
                    child: CupertinoButton(
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Center(child: BoxedIcon(WeatherIcons.fromString(weather != null ? "wi-${DateTime.now().hour > 6 && DateTime.now().hour < 20 ? "day" : "night"}-${weatherCodeToIcon[weather?.weatherConditionCode]}" : "wi-moon-new", fallback: WeatherIcons.day_sunny))),
                            Center(child: Text(weather != null ? "${weather?.temperature?.fahrenheit?.toStringAsFixed(1)} °F" : "– °F", style: TextStyle(fontSize: 16, color: currTextColor),))
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(0),
                      color: currCardColor,
                      onPressed: () {
                        getWeather();
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8),),
                  Expanded(
                    flex: 1,
                    child: CupertinoButton(
                      child: Container(),
                      padding: EdgeInsets.all(0),
                      color: currCardColor,
                      onPressed: () {

                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlayerStateWidget() {
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
      builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
        var track = snapshot.data?.track;
        var playerState = snapshot.data;

        if (playerState == null || track == null) {
          return Center(
            child: Container(),
          );
        }

        return SafeArea(
          bottom: false,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              child: spotifyImageWidget(track.imageUri.raw)
                          )
                      ),
                      Padding(padding: EdgeInsets.all(8),),
                      Expanded(
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('${track.name}', style: TextStyle(color: currTextColor, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
                              Padding(padding: EdgeInsets.all(2),),
                              Text('${track.artist.name}', style: TextStyle(color: Colors.grey, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis,),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.all(4)),
                Container(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: LinearProgressIndicator(
                          value: playerState.playbackPosition / playerState.track!.duration,
                          color: spotifyColor,
                          backgroundColor: currCardColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.all(4)),
                Container(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: currCardColor,
                          child: Image.asset("images/rewind_button.png", height: 35, color: Colors.white,),
                          onPressed: () {
                            skipPrevious();
                          },
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(8),),
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: currCardColor,
                          child: Image.asset(playerState.isPaused ? "images/play_button.png" : "images/pause_button.png", height: 35, color: Colors.white,),
                          onPressed: () {
                            if (playerState.isPaused) {
                              resume();
                            }
                            else {
                              pause();
                            }
                          },
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(8),),
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: currCardColor,
                          child: Image.asset("images/forward_button.png", height: 35, color: Colors.white,),
                          onPressed: () {
                            skipNext();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget spotifyImageWidget(String uri) {
    if (imageUri != uri) {
      return FutureBuilder(
          future: SpotifySdk.getImage(
            imageUri: ImageUri(uri),
            dimension: ImageDimension.small,
          ),
          builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
            if (snapshot.hasData) {
              imageUri = uri;
              cover = Image.memory(snapshot.data!, fit: BoxFit.cover,);
              return Image.memory(snapshot.data!, fit: BoxFit.cover,);
            } else if (snapshot.hasError) {
              setStatus(snapshot.error.toString());
              return SizedBox(
                width: ImageDimension.large.value.toDouble(),
                height: ImageDimension.large.value.toDouble(),
                child: const Center(child: Text('Error getting image')),
              );
            } else {
              return SizedBox(
                width: ImageDimension.large.value.toDouble(),
                height: ImageDimension.large.value.toDouble(),
                child: const Center(child: Text('Getting image...')),
              );
            }
          });
    }
    else return cover != null ? cover! : Image.asset("images/play_button");
  }

  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> resume() async {
    try {
      await SpotifySdk.resume();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> skipNext() async {
    try {
      await SpotifySdk.skipNext();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> connectToSpotifyRemote() async {
    try {
      setState(() {
        _loading = true;
      });
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: SPOTIFY_CLIENT_ID,
          accessToken: spotifyToken,
          redirectUrl: SPOTIFY_REDIRECT);
      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }

}
