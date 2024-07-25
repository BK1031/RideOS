import 'package:fluro/fluro.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rideos/models/version.dart';
import 'package:rideos/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final router = FluroRouter();
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

Logger logger = Logger();
var httpClient = http.Client();
late SharedPreferences prefs;

Version appVersion = Version("2.0.0+1");

String MAPBOX_PUBLIC_TOKEN = "mapbox-public-token";
String MAPBOX_ACCESS_TOKEN = "mapbox-access-token";
String WEATHER_API_KEY = "weather-api-key";