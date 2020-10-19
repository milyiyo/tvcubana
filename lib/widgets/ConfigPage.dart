import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tvcubana/notifications.dart';

import '../ShowImdbImages.dart';
import '../infrastructure/CacheManager.dart';

import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:flutter_touch_spin/flutter_touch_spin.dart';

class ConfigPage extends StatefulWidget {
  ConfigPage();

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool showImages = false;
  bool hasResult = false;
  var _searchQuery = '';
  int minutes;

  @override
  void initState() {
    super.initState();
    CacheManager.readShowImagesimdb().then((value) {
      setState(() {
        showImages = value;
        hasResult = true;
      });
    });
  }

  FutureBuilder<int> spinMinutesBefore() {
    return new FutureBuilder<int>(
      future: retrieveMinutesBeforeFromCache(), // a Future<int> or null
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new TouchSpin(
              value: snapshot.data,
              min: 0,
              max: 60,
              step: 5,
              // displayFormat:
              //     NumberFormat.currency(locale: 'en_US', symbol: '\$'),
              textStyle: TextStyle(fontSize: 24),
              iconSize: 24.0,
              addIcon: Icon(Icons.add_circle_outline),
              subtractIcon: Icon(Icons.remove_circle_outline),
              iconActiveColor: Colors.blue[500],
              iconDisabledColor: Colors.blueGrey[100],
              iconPadding: EdgeInsets.all(20),
              onChanged: (val) {
                minutes = val;
                storeMinutesBefore(val);
              },
              enabled: true,
            );
          // case ConnectionState.waiting: return new Text('Awaiting result...');
          default:
            return new TouchSpin(
              value: 10,
              min: 0,
              max: 60,
              step: 5,
              // displayFormat:
              //     NumberFormat.currency(locale: 'en_US', symbol: '\$'),
              textStyle: TextStyle(fontSize: 24),
              iconSize: 36.0,
              addIcon: Icon(Icons.add_circle_outline),
              subtractIcon: Icon(Icons.remove_circle_outline),
              iconActiveColor: Colors.blue[500],
              iconDisabledColor: Colors.blueGrey[100],
              iconPadding: EdgeInsets.all(20),
              onChanged: (val) {
                minutes = val;
                storeMinutesBefore(val);
              },
              enabled: true,
            );
        }
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

  Future<void> _showAboutUsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Acerca de'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Esta aplicación ha sido desarrollada por:\n',
                    style: TextStyle(
                              color: Colors.black,
                              fontSize: 18)
                    ),
                RichText(
                  text: TextSpan(
                    text: ' - Alberto Carmona Barthelemy: ',
                    style: TextStyle(
                              color: Colors.black,
                              fontSize: 18),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'milyiyo@gmail.com',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      TextSpan(text: ''),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: ' - Marisel Torres Martínez: ',
                    style: TextStyle(
                              color: Colors.black,
                              fontSize: 18),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'mtorresm911025@gmail.com',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      TextSpan(text: ''),
                    ],
                  ),
                ),
                Text('\nVersión: 1.0.2'),
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
      },
    );
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
                  Text('Notificaciones: ',
                      style: TextStyle(height: 5, fontSize: 18)),
                  Flexible(
                      child: Row(children: [
                    Expanded(flex: 2, child: Container()),
                    spinMinutesBefore(),
                    Text(' minutos antes. ',
                        style: TextStyle(height: 5, fontSize: 16)),
                  ]))
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
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
                  Text('Mostrar imágenes (películas)',
                      style: TextStyle(height: 5, fontSize: 18)),
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
                              // context.read<ShowImdbImages>().setShowImdbImages(state);
                              if (showImages != state)
                                Provider.of<ShowImdbImages>(context,
                                        listen: false)
                                    .setShowImdbImages(state);
                            }
                          },
                        )
                      : Container()
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
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
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Acerca de...',
                          style: TextStyle(height: 5, fontSize: 18),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
