import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:ride_os/utils/config.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  Future<void> getPrefs() async {
    await rootBundle.loadString('assets/maps_day_theme.txt').then((string) {
      mapDayTheme = string;
    });
    await rootBundle.loadString('assets/maps_night_theme.txt').then((string) {
      mapNightTheme = string;
    });
    await rootBundle.loadString('assets/maps_day_plain_theme.txt').then((string) {
      mapDayPlainTheme = string;
    });
    await rootBundle.loadString('assets/maps_night_plain_theme.txt').then((string) {
      mapNightPlainTheme = string;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("mapPref")) prefs.setString("mapPref", "automatic");
    else mapPref = prefs.getString("mapPref")!;
    router.navigateTo(context, "/home", transition: TransitionType.fadeIn, replace: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(child: Text("RideOS"), onPressed: () => router.navigateTo(context, "/home", transition: TransitionType.fadeIn, replace: true),),
      ),
    );
  }
}
