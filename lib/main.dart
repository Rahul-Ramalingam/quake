import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//Links for Date formatting
//Date format: https://pub.dartlang.org/packages/intl#-readme-tab-
//DateFormat: https://www.dartdocs.org/documentation/intl/0.15.1/intl/DateFormat-class.html
//https://stackoverflow.com/questions/45357520/dart-converting-milliseconds-since-epoch-unix-timestamp-into-human-readable
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() async {
  FirebaseMessaging().getToken().then((id) {
    print(id);
  });

  Map _data = await getJson();

  List _features = _data["features"];

  print(_features.length);

  runApp(new MaterialApp(
    title: "Quake App",
    home: new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue[900],
          centerTitle: true,
          title: new Text("Quake",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  letterSpacing: 1.3)),
        ),
        body: new Center(
          child: new ListView.builder(
            itemCount: _features.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (BuildContext context, int position) {
              var timeformat = _features[position]['properties']['time'] * 1000;
              var _formatted = DateTime.fromMicrosecondsSinceEpoch(timeformat);

              var format = new DateFormat('EEE, d/M/y');
              var format1 = new DateFormat('HH:mm a');
              var dateString = format.format(_formatted);
              var dateString1 = format1.format(_formatted);
              var date = dateString + "  Time:" + dateString1;

              return new ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
                  leading: new CircleAvatar(
                    backgroundColor: Colors.orange[400],
                    child: new Text(
                        "Mag:${_features[position]['properties']['mag']}",
                        style: TextStyle(color: Colors.white, fontSize: 8)),
                  ),
                  onTap: () {
                    _ontapp(
                        context,
                        ("PLACE:                                                     ${_features[position]['properties']['place']}"),
                        ("COORDINATES:                                     ${_features[position]['geometry']['coordinates']}"),
                        ("${_features[position]['properties']['url']}"));
                  },
                  title: new Text("Date: $date",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)));
            },
          ),
        )),
  ));
}

void _ontapp(BuildContext context, String message1, message2, message3) {
  var alert = new AlertDialog(
    title: new Text("More Informations"),
    content: new Container(
        height: 150,
        width: 110,
        // padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(message1),
            new Text(
              message2,
              style: TextStyle(fontSize: 15),
            ),
            //new Text(message3),
            InkWell(
              child: Text(
                "click here for detailed information",
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              onTap: () async {
                if (await canLaunch(message3)) {
                  await launch(message3);
                }
              },
            ),
          ],
        )),
    actions: <Widget>[
      new RaisedButton(
        child: new Text(
          "Ok",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      )
    ],
  );
  showDialog(context: context, builder: (context) => alert);
}

Future<Map> getJson() async {
  String apiurl =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson';
  http.Response response = await http.get(apiurl);
  return jsonDecode(response.body);
}
