// Reference page: https://github.com/parse-community/Parse-SDK-Flutter

import 'package:cartelera_tvc/TabBarDemo.dart';
import 'package:cartelera_tvc/channel.dart';
import 'package:cartelera_tvc/program.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'utils.dart';
import 'dart:convert';

const String PARSE_APP_ID = 'Fy0qjfqDevGKQPT5XaANnq9EbQ1EbP2OtiQzhwWV';
const String PARSE_APP_URL = 'https://parseapi.back4app.com';
const String MASTER_KEY = 'mPpFoKblASqkm362EhSv6Bw3AsXKTqJqLEBpmps6';
const String LIVE_QUERY_URL = 'wss://qwertydomain.back4app.io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //_setTargetPlatformForDesktop();
  var channels = await getChannels();

  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: TabBarDemo(channels),
  ));
}

void testJsons() {
  var pi = new ProgramItem('description', 'descriptionLong', 'duration', 'date',
      'dateStart', 'dateEnd', 'timeStart', 'timeEnd', 'title');
  var p = new Program('date', [pi]);
  var c = new Channel('id', 'name', 'logo', 'description');

  var enc = Program.fromJson(json.decode(json.encode(p)));
  var encChn = Channel.fromJson(json.decode(json.encode(c)));

  print(encChn);
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
