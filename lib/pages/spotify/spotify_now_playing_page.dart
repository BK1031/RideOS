import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:ride_os/utils/config.dart';
import 'package:ride_os/utils/secret.dart';
import 'package:ride_os/utils/theme.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/crossfade_state.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyNowPlayingPage extends StatefulWidget {
  @override
  _SpotifyNowPlayingPageState createState() => _SpotifyNowPlayingPageState();
}

class _SpotifyNowPlayingPageState extends State<SpotifyNowPlayingPage> {

  bool _loading = false;
  final Logger _logger = Logger();

  CrossfadeState? crossfadeState;

  List<Widget> playlists = [];

  String imageUri = "";
  Image cover = Image.asset("images/play_button");

  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (spotifyToken != "") {
      connectToSpotifyRemote();
      timer = new Timer.periodic(const Duration(seconds: 1), (Timer t) => refreshTime());
    }
  }

  void refreshTime() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPlayerStateWidget();
  }

  Widget _buildPlayerStateWidget() {
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
      builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
        var track = snapshot.data?.track;
        var playerState = snapshot.data;

        if (playerState == null || track == null) {
          return Center(
            child: Container(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                color: currCardColor,
                child: Image.network("https://services.garmin.com/appsLibraryBusinessServices_v0/rest/apps/30c6c876-ba43-4cbb-b4c7-03583a7cb66b/icon/bdab70ac-eaa9-4d8e-8e81-61923864ff7c", height: 50),
                onPressed: () {
                  connectToSpotifyRemote();
                },
              ),
            ),
          );
        }

        return Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: spotifyImageWidget(track.imageUri.raw),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: currBackgroundColor.withOpacity(0.8),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 170,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 170,
                              height: 170,
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Center(child: Text('${track.name}', style: TextStyle(color: currTextColor, fontSize: 25, fontWeight: FontWeight.bold),)),
                                  Padding(padding: EdgeInsets.all(4),),
                                  Center(child: Text('${track.album.name} – ${track.artist.name}', style: TextStyle(color: Colors.grey, fontSize: 20),)),
                                  Padding(padding: EdgeInsets.all(8),),
                                  Container(
                                    height: 60,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: CupertinoButton(
                                            color: currCardColor,
                                            child: Image.asset("images/rewind_button.png", height: 50, color: Colors.white,),
                                            onPressed: () {
                                              skipPrevious();
                                            },
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.all(8),),
                                        Expanded(
                                          child: CupertinoButton(
                                            color: currCardColor,
                                            child: Image.asset(playerState.isPaused ? "images/play_button.png" : "images/pause_button.png", height: 50, color: Colors.white,),
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
                                            color: currCardColor,
                                            child: Image.asset("images/forward_button.png", height: 50, color: Colors.white,),
                                            onPressed: () {
                                              skipNext();
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(12)),
                    Container(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            child: LinearProgressIndicator(
                              minHeight: 6,
                              value: playerState.playbackPosition / playerState.track!.duration,
                              color: spotifyColor,
                              backgroundColor: currCardColor,
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(4)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${((playerState.playbackPosition / 1000) / 60).floor()}:${((playerState.playbackPosition / 1000) % 60).round()}", style: TextStyle(color: currTextColor),),
                              Text("${((playerState.track!.duration / 1000) / 60).floor()}:${((playerState.track!.duration / 1000) % 60).round()}", style: TextStyle(color: currTextColor),),
                            ],
                          ),
                          Container(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CupertinoButton(
                                  color: playerState.playbackOptions.isShuffling ? Colors.white : currCardColor,
                                  child: Image.asset("images/shuffle_button.png", height: 50, color: !playerState.playbackOptions.isShuffling ? Colors.white : currCardColor),
                                  onPressed: () {
                                    setShuffle(!playerState.playbackOptions.isShuffling);
                                  },
                                ),
                                Padding(padding: EdgeInsets.all(8),),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  color: currCardColor,
                                  child: Image.network("https://services.garmin.com/appsLibraryBusinessServices_v0/rest/apps/30c6c876-ba43-4cbb-b4c7-03583a7cb66b/icon/bdab70ac-eaa9-4d8e-8e81-61923864ff7c", height: 50),
                                  onPressed: () {
                                    connectToSpotifyRemote();
                                  },
                                ),
                                Padding(padding: EdgeInsets.all(8),),
                                CupertinoButton(
                                  color: playerState.playbackOptions.repeatMode.index == 0 ? currCardColor : Colors.white,
                                  child: Image.asset(playerState.playbackOptions.repeatMode.index == 1 ? "images/repeat_one_button.png" : "images/repeat_button.png", height: 50, color: playerState.playbackOptions.repeatMode.index == 0 ? Colors.white : currCardColor),
                                  onPressed: () {
                                    setRepeatMode(RepeatMode.values[(playerState.playbackOptions.repeatMode.index - 1) % 3]);
                                  },
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
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

  Future<void> setRepeatMode(RepeatMode repeatMode) async {
    try {
      await SpotifySdk.setRepeatMode(
        repeatMode: repeatMode,
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> setShuffle(bool shuffle) async {
    try {
      await SpotifySdk.setShuffle(
        shuffle: shuffle,
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
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
    else return cover;
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
      if (!result) getAuthenticationToken();
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

  Future<String> getAuthenticationToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAuthenticationToken(
          clientId: SPOTIFY_CLIENT_ID,
          redirectUrl: SPOTIFY_REDIRECT,
          spotifyUri: "omegalul",
          scope: 'app-remote-control, '
              'user-modify-playback-state, '
              'playlist-read-private, '
              'playlist-modify-public,user-read-currently-playing');
      setStatus('Got a token: $authenticationToken');
      spotifyToken = authenticationToken;
      return authenticationToken;
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      setStatus('not implemented');
      return Future.error('not implemented');
    }
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }

}
