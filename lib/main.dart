import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rideos/config/config.dart';
import 'package:rideos/config/theme.dart';
import 'package:rideos/pages/skeleton.dart';
import 'package:rideos/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return const Scaffold(
        body: Center(
            child: Text("Unexpected error. See log for details.")));
  };

  await dotenv.load(fileName: ".env");
  MAPBOX_PUBLIC_TOKEN = dotenv.env['MAPBOX_PUBLIC_TOKEN']!;
  MAPBOX_ACCESS_TOKEN = dotenv.env['MAPBOX_ACCESS_TOKEN']!;
  WEATHER_API_KEY = dotenv.env['WEATHER_API_KEY']!;

  logger.setLevel(LogLevel.debug);

  prefs = await SharedPreferences.getInstance();
  logger.log("RideOS v${appVersion.toString()} – ${appVersion.getVersionCode()}");

  // ROUTE DEFINITIONS
  router.define("/", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const SkeletonPage();
  }));

  runApp(MaterialApp(
    title: "RideOS",
    initialRoute: "/",
    onGenerateRoute: router.generator,
    theme: darkTheme,
    darkTheme: darkTheme,
    debugShowCheckedModeBanner: false,
    navigatorObservers: [
      routeObserver,
    ],
  ));
}