// Reference page: https://github.com/parse-community/Parse-SDK-Flutter

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

const String PARSE_APP_ID = 'Fy0qjfqDevGKQPT5XaANnq9EbQ1EbP2OtiQzhwWV';
const String PARSE_APP_URL = 'https://parseapi.back4app.com';
const String MASTER_KEY = 'mPpFoKblASqkm362EhSv6Bw3AsXKTqJqLEBpmps6';
const String LIVE_QUERY_URL = 'wss://qwertydomain.back4app.io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _setTargetPlatformForDesktop();

  runApp(MyApp());
}

void _setTargetPlatformForDesktop() async {
  await Parse().initialize(PARSE_APP_ID, PARSE_APP_URL,
      masterKey: MASTER_KEY, debug: true);

  final ParseResponse apiResponse = await ParseObject('Comment').getAll();

  if (apiResponse.success && apiResponse.count > 0) {
    for (final ParseObject testObject in apiResponse.results) {
      print(keyAppName + ': ' + testObject.toString());
    }
  }

  print(apiResponse.count);

  var comment = ParseObject('Comment')
    ..set('content', 'test content')
    ..set('likes', 65);
  await comment.save();

  print(apiResponse.count);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text(text),
        ),
      ),
    );
  }
}