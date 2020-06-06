import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'channel.dart';
import 'program.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Map<String, String> getChannelImages() {
  Map<String, String> images = new Map<String, String>();

  images['Canal Caribe'] = 'assets/images/canal_caribe.jpg';
  images['Telerebelde'] = 'assets/images/telerebelde.jpg';
  images['Educativo'] = 'assets/images/educativo.jpg';
  images['Educativo 2'] = 'assets/images/educativo2.jpg';
  images['Multivisión'] = 'assets/images/canal_multivision.png';
  images['Clave'] = 'assets/images/clave.jpg';
  images['Cubavisión'] = 'assets/images/cubavision.png';
  images['Cubavisión Plus'] = 'assets/images/cubavision.png';
  images['Cubavisión Internacional'] =
      'assets/images/cubavision_internacional.png';
  images['Canal Habana'] = 'assets/images/canal_habana.jpg';
  images['Artv'] = 'assets/images/artemisa_tv.jpg';
  images['Telemayabeque'] = 'assets/images/tele_mayabeque.jpg';
  images['Centrovisión Yayabo'] = 'assets/images/yayabo_tv.jpg';
  images['Tele Pinar'] = 'assets/images/tele_pinar.jpg';
  images['Telecubanacan'] = 'assets/images/tele_cubanacan.jpg';
  images['Tele Cristal'] = 'assets/images/tele_cristal.jpg';
  images['MiTV'] = 'assets/images/mitv.jpg';

  return images;
}

Future<List<Program>> getProgram(Channel channel) async {
  // print('start:getProgram');
  var date = new DateTime.now();
  var dateStr =
      '${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}';
  var programs = new List<Program>();

  bool hasCache = await hasCacheForProgram('programs_${channel.id}_$dateStr');
  if (!hasCache) {
    programs = await getProgramFromURL(channel);
    storeProgramsInCache(programs, channel.id, dateStr);
  } else {
    programs = await retrieveProgramsFromCache(channel.id, dateStr);
  }

  // print('end:getProgram');
  return programs;
}

clearCache() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

retrieveProgramsFromCache(String channelId, String dateStr) async {
  // print('start:retrieveProgramsFromCache');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var programsStr = prefs.getString('programs_${channelId}_$dateStr');
  var decodedStr = json.decode(programsStr);
  var programs = (decodedStr as List).map((e) => Program.fromJson(e)).toList();
  // print('end:retrieveProgramsFromCache');
  return programs;
}

storeProgramsInCache(
    List<Program> programs, String channelId, String dateStr) async {
  // print('start:storeProgramsInCache');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('programs_${channelId}_$dateStr', json.encode(programs));
  // print('end:storeProgramsInCache');
}

Future<List<Program>> getProgramFromURL(Channel channel) async {
  var now = new DateTime.now();
  var weekday = now.weekday;
  var firstDayOfWeek = now.subtract(new Duration(days: weekday - 1));

  var programs = List<Program>();
  for (var i = 0; i < 7; i++) {
    var date = firstDayOfWeek.add(new Duration(days: i));
    var dateStr =
        '${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}';

    var url = 'http://eprog2.tvcdigital.cu/programacion/${channel.id}/${date}';
    var result = List<ProgramItem>();
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);

      for (var json in jsonResponse) {
        result.add(new ProgramItem(
            json['descripcion'],
            json['descripcion_ampliada'],
            json['duracion'],
            json['fecha'],
            json['fecha_inicial'],
            json['fecha_final'],
            json['hora_inicio'],
            json['hora_fin'],
            json['titulo']));
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    programs.add(new Program(dateStr, result));
  }
  return programs;
}

Future<List<Channel>> getChannelsFromURL() async {
  // print('start:getChannelsFromURL');
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
  // print('end:getChannelsFromURL');
  return result;
}

Future<List<Channel>> getChannels() async {
  // print('start:getChannels');
  var date = new DateTime.now();
  var dateStr =
      '${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}';
  var channels = new List<Channel>();

  bool hasCache = await hasCacheFor(dateStr);
  if (!hasCache) {
    channels = await getChannelsFromURL();
    storeChannelsInCache(channels);
    storeDateInCache(dateStr);
  } else {
    channels = await retrieveChannelsFromCache();
  }

  // print('end:getChannels');
  return channels;
}

Future<List<Channel>> retrieveChannelsFromCache() async {
  // print('start:retrieveChannelsFromCache');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var channelsStr = prefs.getString('channels');
  var decodedStr = json.decode(channelsStr);
  var channels = (decodedStr as List).map((e) => Channel.fromJson(e)).toList();
  // print('end:retrieveChannelsFromCache');
  return channels;
}

Future<void> storeChannelsInCache(List<Channel> channels) async {
  // print('start:storeChannelsInCache');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('channels', json.encode(channels));
  // print('end:storeChannelsInCache');
}

Future<void> storeDateInCache(String date) async {
  // print('start:storeDateInCache');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('date', date);
  // print('end:storeDateInCache');
}

Future<bool> hasCacheFor(String dateStr) async {
  // print('start:hasCacheFor');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cacheDateStr = prefs.getString('date');
  if (cacheDateStr == null) {
    return false;
  }
  // print('end:hasCacheFor $cacheDateStr ${dateStr == cacheDateStr}');
  return dateStr == cacheDateStr;
}

Future<bool> hasCacheForProgram(String key) async {
  // print('call:hasCacheForProgram');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getKeys().contains(key);
}

List<ProgramItem> getTheCurrentProgram(List<ProgramItem> pitemsList) {
  List<ProgramItem> result = [null, null];
  for (var i = 0; i < pitemsList.length; i++) {
    var pitem = pitemsList[i];

    var now = new DateTime.now();
    var dateStartProg = DateTime.parse(pitem.dateStart +
        ' ' +
        pitem.timeStart +
        (pitem.timeStart.length == 8 ? '' : '0'));
    var dateEndProg = DateTime.parse(pitem.dateEnd +
        ' ' +
        pitem.timeEnd +
        (pitem.timeEnd.length == 8 ? '' : '0'));

    if ((dateStartProg.isBefore(now) && dateEndProg.isAfter(now)) ||
        dateStartProg == now ||
        dateEndProg == now) {
      result[0] = pitem;
      if (i + 1 < pitemsList.length) result[1] = pitemsList[i + 1];
      break;
    }
  }
  return result;
}

ProgramItem getTheCurrentProgramOld(List<ProgramItem> pitemsList) {
  for (var pitem in pitemsList) {
    var now = new DateTime.now();
    var dateStartProg = DateTime.parse(pitem.dateStart +
        ' ' +
        pitem.timeStart +
        (pitem.timeStart.length == 8 ? '' : '0'));
    var dateEndProg = DateTime.parse(pitem.dateEnd +
        ' ' +
        pitem.timeEnd +
        (pitem.timeEnd.length == 8 ? '' : '0'));

    if ((dateStartProg.isBefore(now) && dateEndProg.isAfter(now)) ||
        dateStartProg == now ||
        dateEndProg == now) {
      return pitem;
    }
  }
  return null;
}
