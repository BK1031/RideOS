import 'package:flutter/material.dart';
import 'package:ride_os/pages/settings/settings_page.dart';
import 'package:ride_os/pages/spotify/spotify_page.dart';
import 'package:ride_os/utils/config.dart';
import 'package:ride_os/utils/theme.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  String debug = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currBackgroundColor,
      body: Container(
        padding: EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          scrollDirection: Axis.horizontal,
          children: [
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      onTap: () {
                        setState(() {
                          print("spotify");
                          body = SpotifyPage();
                          state = "spotify";
                        });
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Image.network("https://services.garmin.com/appsLibraryBusinessServices_v0/rest/apps/30c6c876-ba43-4cbb-b4c7-03583a7cb66b/icon/bdab70ac-eaa9-4d8e-8e81-61923864ff7c", fit: BoxFit.cover,),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(4),),
                  Text("Spotify", style: TextStyle(color: currTextColor, fontSize: 18),)
                ],
              )
            ),
            Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        onTap: () {
                          print("settings");
                          body = SettingsPage();
                          state = "settings";
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          width: 100,
                          height: 100,
                          child: Image.network("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/1f80c78a-4070-4082-85ed-f2d4cf3894db/d88y06v-9bf586ed-3aa1-42b8-8ca5-343fc26843a2.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzFmODBjNzhhLTQwNzAtNDA4Mi04NWVkLWYyZDRjZjM4OTRkYlwvZDg4eTA2di05YmY1ODZlZC0zYWExLTQyYjgtOGNhNS0zNDNmYzI2ODQzYTIucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.3ztis7iKYyTWcoutMZaydFV7NmDooZvh22emcS9OqEk", fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(4),),
                    Text("Settings", style: TextStyle(color: currTextColor, fontSize: 18),)
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}
