import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tvcubana/notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../ShowImdbImages.dart';
import '../infrastructure/CacheManager.dart';

import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:flutter_touch_spin/flutter_touch_spin.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConfigPage extends StatefulWidget {
  ConfigPage();

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool showImages = false;
  bool hasResult = false;
  int minutes;

  @override
  void initState() {
    super.initState();
    CacheManager.readShowImagesimdb().then((value) {
      setState(() {
        showImages = value;
        hasResult = true;
        print(['ShowImages', showImages]);
      });
    });
  }

  FutureBuilder<int> spinMinutesBefore() {
    return new FutureBuilder<int>(
      future: retrieveMinutesBeforeFromCache(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
          return new TouchSpin(
            value: snapshot.data,
            min: 0,
            max: 60,
            step: 5,
            textStyle: TextStyle(fontSize: 24),
            iconSize: 36.0,
            addIcon: Icon(Icons.add_circle_outline),
            subtractIcon: Icon(Icons.remove_circle_outline),
            iconActiveColor: Colors.blue[500],
            iconDisabledColor: Colors.blueGrey[100],
            iconPadding: EdgeInsets.all(10),
            onChanged: (val) {
              minutes = val;
              storeMinutesBefore(val);
            },
            enabled: true,
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  Future<bool> _onBackPressed() {
    if (minutes != null) {
      //validar q el valor no sea el mismo q el que estaba anteriormente
      reScheduleNotifications(minutes);
    }
    Navigator.of(context).pop(true);
    return Future.value(true);
  }

  void showToast(bool state) {
    var message = "Reinicie la aplicación para que se reflejen los cambios";
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.lightBlue[600],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  FutureBuilder<String> dialogAboutUs() {
    return new FutureBuilder<String>(
      future: _getVersionNumber(), // a Future<int> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return AlertDialog(
            title: Text('Acerca de'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Esta aplicación ha sido desarrollada por:\n',
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                  RichText(
                    text: TextSpan(
                      text: ' - Alberto Carmona Barthelemy: ',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'milyiyo@gmail.com',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        TextSpan(text: ''),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: ' - Marisel Torres Martínez: ',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'mtorresm911025@gmail.com',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        TextSpan(text: ''),
                      ],
                    ),
                  ),
                  Text('\nVersión: ${snapshot.data}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  Future<void> _showAboutUsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return dialogAboutUs();
      },
    );
  }

  Future<String> _getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;

    // Other data you can get:
    //
    // 	String appName = packageInfo.appName;
    // 	String packageName = packageInfo.packageName;
    //	String buildNumber = packageInfo.buildNumber;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Configuración',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: ListView(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text('Notificaciones: ',
                          style: TextStyle(height: 2, fontSize: 18)),
                      Text('(minutos antes)',
                          style: TextStyle(height: 1, fontSize: 14))
                    ],
                  ),
                  Flexible(
                      child: Row(children: [
                    Expanded(flex: 1, child: Container()),
                    spinMinutesBefore()
                  ]))
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Container(
                  height: 1.0,
                  width: 130.0,
                  color: Colors.black12,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text('Mostrar pósters: ',
                          style: TextStyle(height: 2, fontSize: 18)),
                      Text('(películas)',
                          style: TextStyle(height: 1, fontSize: 14))
                    ],
                  ),
                  Flexible(
                      child: Row(children: [
                    Expanded(flex: 1, child: Container()),
                    hasResult
                        ? LiteRollingSwitch(
                            value: showImages,
                            textSize: 18,
                            textOn: 'Sí',
                            textOff: 'No',
                            colorOn: Colors.blue[500],
                            colorOff: Colors.blueGrey[100],
                            iconOn: Icons.thumb_up,
                            iconOff: Icons.thumb_down,
                            onChanged: (bool state) {
                              if (hasResult) {
                                CacheManager.storeShowImages(state);
                                if (showImages != state) {
                                  Provider.of<ShowImdbImages>(context,
                                          listen: false)
                                      .setShowImdbImages(state);
                                  showToast(state);
                                }
                              }
                            },
                          )
                        : Container()
                  ]))
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Container(
                  height: 1.0,
                  width: 130.0,
                  color: Colors.black12,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showAboutUsDialog();
                },
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Acerca de...',
                          style: TextStyle(height: 2, fontSize: 18),
                        ),
                      )
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
