import 'CacheManager.dart';
import '../models/Channel.dart';
import '../models/Program.dart';
import '../models/ProgramItem.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../utils.dart';

class ICRTService {
  static Future<List<Program>> getProgram(
      Channel channel, bool forceUpdate) async {
    var date = new DateTime.now();
    var programs = new List<Program>();
    var lastDayOfWeek = date.add(new Duration(days: 7 - date.weekday));
    var dateStr = getStrDate(lastDayOfWeek);

    bool hasCache = await CacheManager.hasCacheForProgram(
        'programs_${channel.id}_$dateStr');
    if (!hasCache || forceUpdate) {
      programs = await _getProgramFromURL(channel);
      CacheManager.storePrograms(programs, channel.id, dateStr);
    } else {
      programs = await CacheManager.retrievePrograms(channel.id, dateStr);
    }

    return programs;
  }

  static Future<List<Program>> _getProgramFromURL(Channel channel) async {
    var now = new DateTime.now();
    var weekday = now.weekday;
    var firstDayOfWeek = now.subtract(new Duration(days: weekday - 1));

    var programs = List<Program>();
    for (var i = 0; i < 7; i++) {
      var date = firstDayOfWeek.add(new Duration(days: i));
      var dateStr = getStrDate(date);

      var url =
          'http://eprog2.tvcdigital.cu/programacion/${channel.id}/$dateStr';
      var result = List<ProgramItem>();
      // Await the http get response, then decode the json-formatted response.
      var response = await http.get(url);
      if (response.statusCode == 200 &&
          !response.body.startsWith('{"solapamiento":{"eventos_solapados"')) {
        var jsonResponse = convert.jsonDecode(response.body);
        for (var pjson in jsonResponse) {
          result.add(new ProgramItem(
              pjson['_id'],
              pjson['descripcion'],
              pjson['descripcion_ampliada'],
              pjson['duracion'],
              pjson['fecha'],
              pjson['fecha_inicial'],
              pjson['fecha_final'],
              pjson['hora_inicio'],
              pjson['hora_fin'],
              pjson['titulo'],
              (pjson['clasific'] as List)
                  .map((e) => e['clasificacion'].toString().trim())
                  .toList()));
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
      programs.add(new Program(dateStr, result));
    }
    return programs;
  }

  static Future<List<Channel>> _getChannelsFromURL() async {
    var result = new List<Channel>();
    var url = 'http://eprog2.tvcdigital.cu/canales';

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);

      for (var jsonChannel in jsonResponse) {
        result.add(new Channel(
          jsonChannel['_id'],
          jsonChannel['nombre'],
          jsonChannel['logo'],
          jsonChannel['descripcion'],
        ));
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return result;
  }

  static Future<List<Channel>> getChannels(bool forceUpdate) async {
    var date = new DateTime.now();
    var lastDayOfWeek = date.add(new Duration(days: 7 - date.weekday));
    print(lastDayOfWeek);
    var dateStr = getStrDate(date);
    var channels = new List<Channel>();

    bool hasCache = await CacheManager.hasCacheFor(dateStr);
    if (!hasCache || forceUpdate) {
      channels = await _getChannelsFromURL();
      CacheManager.storeChannels(channels);
      CacheManager.storeDate(getStrDate(lastDayOfWeek));
    } else {
      channels = await CacheManager.retrieveChannels();
    }

    return channels;
  }
}