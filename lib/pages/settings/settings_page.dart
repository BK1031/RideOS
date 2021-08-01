import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ride_os/utils/config.dart';
import 'package:ride_os/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        new CupertinoSliverNavigationBar(
          backgroundColor: currCardColor,
          largeTitle: new Text("Settings", style: TextStyle(color: mainColor),),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            new Padding(padding: EdgeInsets.all(8.0)),
            SafeArea(
              child: new Card(
                child: Column(
                  children: <Widget>[
                    new Container(
                      width: 1000.0,
                      padding: EdgeInsets.all(16.0),
                      child: new Text(
                        currUser.firstName + " " + currUser.lastName,
                        style: TextStyle(
                            fontSize: 25.0,
                            color: mainColor,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    new Container(
                      child: new Column(
                        children: <Widget>[
                          new ListTile(
                            title: new Text("Email", style: TextStyle(fontSize: 16.0, color: currTextColor)),
                            trailing: new Text(currUser.email, style: TextStyle(fontSize: 16.0, color: currTextColor)),
                          ),
                          new ListTile(
                            title: new Text("User ID", style: TextStyle(fontSize: 16.0, color: currTextColor)),
                            trailing: new Text(currUser.id, style: TextStyle(fontSize: 16.0, color: currTextColor)),
                          ),
                          new ListTile(
                            title: new Text("Update Profile", style: TextStyle(color: mainColor), textAlign: TextAlign.center,),
                            onTap: () {
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SafeArea(
              child: new Card(
                color: currCardColor,
                child: Column(
                  children: <Widget>[
                    new ListTile(
                      title: new Text("About", style: TextStyle(fontSize: 17, color: currTextColor)),
                      trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                      onTap: () {
                      },
                    ),
                    new ListTile(
                        title: new Text("Legal", style: TextStyle(fontSize: 17, color: currTextColor)),
                        trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                        onTap: () {
                          showLicensePage(
                            context: context,
                            applicationVersion: appVersion.toString(),
                            applicationName: "RideOS",
                            applicationLegalese: appLegal,
                          );
                        }
                    ),
                    new SwitchListTile.adaptive(
                      activeColor: mainColor,
                      activeTrackColor: mainColor,
                      value: driveMode,
                      onChanged: (val) {
                        setState(() {
                          driveMode = val;
                        });
                      },
                      title: new Text("Drive Mode", style: TextStyle(fontSize: 17, color: currTextColor)),
                    ),
                    new SwitchListTile.adaptive(
                      activeColor: mainColor,
                      activeTrackColor: mainColor,
                      value: !driveMode,
                      onChanged: (val) {
                        setState(() {
                          driveMode = !val;
                        });
                      },
                      title: new Text("Ride Mode", style: TextStyle(fontSize: 17, color: currTextColor)),
                    ),
                    new SwitchListTile.adaptive(
                      activeColor: mainColor,
                      activeTrackColor: mainColor,
                      value: debug,
                      onChanged: (val) {
                        setState(() {
                          debug = !debug;
                        });
                      },
                      title: new Text("Debug Mode", style: TextStyle(fontSize: 17, color: currTextColor)),
                    ),
                    new ListTile(
                      title: new Text("Map Style", style: TextStyle(fontSize: 17, color: currTextColor)),
                      trailing: DropdownButton<String>(
                        value: mapPref,
                        items: <String>[
                          'automatic',
                          'automatic-plain',
                          'day',
                          'day-plain',
                          'night',
                          'night-plain',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        hint:Text(
                          "Please choose a map style",
                        ),
                        onChanged: (value) async {
                          setState(() {
                            mapPref = value!;
                          });
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString("mapPref", mapPref);
                        },
                      ),
                    ),
                    new ListTile(
                      title: new Text("Sign Out", style: TextStyle(fontSize: 17, color: Colors.red), textAlign: TextAlign.center,),
                      onTap: () async {
                      },
                    ),
                  ],
                ),
              ),
            ),
            new Padding(padding: EdgeInsets.all(8.0)),
          ]),
        )
      ],
    );
  }
}
