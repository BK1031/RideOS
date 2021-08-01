import 'package:firebase_core/firebase_core.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ride_os/pages/onboarding/onboarding_page.dart';
import 'package:ride_os/pages/skeleton_page.dart';
import 'package:ride_os/utils/config.dart';
import 'package:ride_os/utils/theme.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) => Container();

  SystemChrome.setEnabledSystemUIOverlays([]);

  FirebaseApp app = await Firebase.initializeApp();
  print('Initialized default app $app');
  // FirebaseAnalytics analytics = FirebaseAnalytics();

  router.define('/', handler: new Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return new OnboardingPage();
  }));

  router.define('/home', handler: new Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return new SkeletonPage();
  }));

  setPathUrlStrategy();
  runApp(new MaterialApp(
    title: "FoodTok",
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    theme: mainTheme,
    onGenerateRoute: router.generator,
    navigatorObservers: [
      // FirebaseAnalyticsObserver(analytics: analytics),
    ],
  ));
}