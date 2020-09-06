import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'models/Channel.dart';
import 'models/Program.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'models/ProgramItem.dart';

var sportNames = [
  r"\b[e-é]isbol",
  r"\f[u-ú]tbol",
  'basket',
  'baloncesto',
  'boxeo',
  r'\nataci[o-ó]n',
  'judo',
  'taekwondo',
  'lucha'
];

Map<String, String> getChannelImages() {
  Map<String, String> images = new Map<String, String>();

  images['Canal Caribe'] = 'assets/images/canal_caribe.jpg';
  images['Telerebelde'] = 'assets/images/telerebelde-icon.jpg';
  images['Educativo'] = 'assets/images/educativo-icon.png';
  images['Educativo 2'] = 'assets/images/educativo2-icon.png';
  images['Multivisión'] = 'assets/images/multivision-icon.png';
  images['Clave'] = 'assets/images/clave.jpg';
  images['Cubavisión'] = 'assets/images/cubavision-icon.png';
  images['Cubavisión Plus'] = 'assets/images/cubavision_plus.png';
  images['Cubavisión Internacional'] =
      'assets/images/cubavision_internacional.png';
  images['Canal Habana'] = 'assets/images/canalHabana-icon.png';
  images['Artv'] = 'assets/images/artemisa_tv.jpg';
  images['Telemayabeque'] = 'assets/images/tele_mayabeque.jpg';
  images['Centrovisión Yayabo'] = 'assets/images/yayabo_tv.jpg';
  images['Tele Pinar'] = 'assets/images/telepinar-icon.jpg';
  images['Telecubanacan'] = 'assets/images/tele_cubanacan.jpg';
  images['Tele Cristal'] = 'assets/images/tele_cristal.jpg';
  images['MiTV'] = 'assets/images/mitv.jpg';
  images['Islavisión'] = 'assets/images/islavision-icon.png';
  images['CNC Tv'] = 'assets/images/cnctv-icon.jpeg';
  images['Perlavisión'] = 'assets/images/perlavision-icon.png';
  images['Solvisión'] = 'assets/images/solvision-icon.jpeg';
  images['Tele Turquino'] = 'assets/images/tvSantiago-icon.jpg';
  images['Tunasvisión'] = 'assets/images/tunasvision-icon.png';
  images['TV Avileña'] = 'assets/images/tvavilena-icon.png';
  images['TV Camaguey'] = 'assets/images/tvcamaguey-icon.png';
  images['TV Yumuri'] = 'assets/images/tvyumuri-icon.png';
  images['Telerebelde Plus'] = 'assets/images/telerebeldePlus-icon.png';
  images['Russia Today'] = 'assets/images/rusiaToday-icon.png';

  return images;
}

getImageForChannel(String channelName, double dimension) {
  var images = getChannelImages();
  if (images.containsKey(channelName)) {
    return Image.asset(images[channelName],
        height: dimension, width: dimension);
  }
  return Container(
      margin: EdgeInsets.only(top: 10),
      child: Icon(Icons.live_tv, size: 50, color: Colors.lightBlue[200]));
}

String getStrDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}';
}

Future<List<Program>> getProgram(Channel channel, bool forceUpdate) async {
  // print('start:getProgram');
  var date = new DateTime.now();
  var programs = new List<Program>();
  var lastDayOfWeek = date.add(new Duration(days: 7 - date.weekday));
  var dateStr = getStrDate(lastDayOfWeek);

  bool hasCache = await hasCacheForProgram('programs_${channel.id}_$dateStr');
  if (!hasCache || forceUpdate) {
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
    var dateStr = getStrDate(date);

    var url = 'http://eprog2.tvcdigital.cu/programacion/${channel.id}/$dateStr';
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

Future<List<Channel>> getChannels(bool forceUpdate) async {
  // print('start:getChannels');
  var date = new DateTime.now();
  var lastDayOfWeek = date.add(new Duration(days: 7 - date.weekday));
  print(lastDayOfWeek);
  var dateStr = getStrDate(date);
  var channels = new List<Channel>();

  bool hasCache = await hasCacheFor(dateStr);
  if (!hasCache || forceUpdate) {
    channels = await getChannelsFromURL();
    storeChannelsInCache(channels);
    storeDateInCache(getStrDate(lastDayOfWeek));
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
  var cacheChannelStr = prefs.getString('channels');
  if (cacheDateStr == null) {
    return false;
  }
  if (cacheDateStr == null && cacheChannelStr != null) {
    return false;
  }
  var parsedDate = DateTime.parse(dateStr);
  // print('end:hasCacheFor $cacheDateStr ${dateStr == cacheDateStr} $dateStr');
  return parsedDate.isBefore(DateTime.parse(cacheDateStr)) ||
      parsedDate == DateTime.parse(cacheDateStr);
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

Widget getImageForCategory(ProgramItem pitem) {
  var categories = pitem.classification.join(' ').toLowerCase();

  var containsAnyOf = (String text, List<String> words) {
    for (var word in words) {
      if (text.contains(word)) return true;
    }
    return false;
  };

  var getIcon =
      (IconData icon) => Icon(icon, size: 50, color: Colors.lightBlue[400]);

  if (containsAnyOf(
      categories, ['concierto', 'musi', 'recital', 'espectaculo']))
    return getIcon(Icons.music_video);

  if (containsAnyOf(categories, ['animacion', 'telefilme', 'pelicula', 'cine']))
    return getIcon(Icons.movie);

  if (categories.contains('documenta')) return getIcon(Icons.videocam);
  if (categories.contains('depor')) return getIcon(Icons.accessibility);

  if (containsAnyOf(categories, ['formacion general', 'teleclase']))
    return getIcon(Icons.school);

  if (containsAnyOf(categories, [
    'reportaje',
    'concurso',
    'disertacion especializada',
    'opinión',
    'resumen informativo',
    'promoción de la programación',
    'telediario',
    'noticiero',
    'emision',
    'revista',
    'debate',
    'capsula',
    'boletin',
    'spot'
  ])) return getIcon(Icons.mic);

  if (categories.contains('utilitario'))
    return Icon(Icons.home, size: 50, color: Colors.lightBlue[400]);

  if (containsAnyOf(categories, ['seriado', 'serie']))
    return getIcon(Icons.subscriptions);

  if (categories.contains('novela')) return getIcon(Icons.dvr);

  print(categories);

  return Icon(Icons.live_tv, size: 50, color: Colors.lightBlue[400]);
}

Future<Map<String, String>> getOMDBData(ProgramItem programItem) async {
  Map<String, String> omdb = {};
  String searchString = programItem.title.toLowerCase() +
      ' & ' +
      programItem.descriptionLong.toLowerCase();

  var exps = [
    new RegExp(r"tiempo\sde\scine:\s([0-9a-z :]*)"),
    new RegExp(r"multicine:\s([a-z0-9 :]*)"),
    new RegExp(r"domingo en casa:\s([A-Za-z0-9 :]*)"),
    new RegExp(r"filmecito:\s([a-z ñáéíóú:]*)"),
    new RegExp(r"filme:\s([A-Za-z áéíóú:]*)"),
    new RegExp(r"minicinema:\s([a-z :]*)"),
    new RegExp(r"directores\sen\sacción:(\s)*([A-Za-z :]*)"),
    new RegExp(r"ellas\sy\sellos:(\s)*([A-Za-z :]*)"),
    new RegExp(r"cine\sde\saventuras:\s([a-z :]*)"),
    new RegExp(r"cinema\sjoven:\s([a-z :]*)"),
    new RegExp(r"algo\spara\srecordar:\s([a-z :]*)"),
    new RegExp(r"t[i-í]tulo\soriginal:\s([a-z :]*)"),
    new RegExp(r"t[i-í]tulo\soriginal\s([a-z :]*)"),
    new RegExp(r"\w*t[i-í]tulo\soriginal:\s([a-z -\s1]*)"),
    new RegExp(r"&\s[a-z -ó2]*\st[i-í]tulo\soriginal:([a-z :\s0-9]*)"),
    new RegExp(r"([a-z ]*).\sTítulo\soriginal"),
    new RegExp(r"([a-z -ó2]*)\s\(titulo\soriginal\)"),
    new RegExp(r"([a-z -ó2]*).\stítulo\soriginal"),
    new RegExp(r"([a-z -ó2]*)\stítulo\soriginal"),
    new RegExp(r"&\s([a-z -ó2]*)\stítulo\soriginal"),
    new RegExp(r"título\sen\sidioma\soriginal:\s([a-z :]*)"),
    new RegExp(r"([a-z -]*).\stítulo\sen\sespañol"),
    new RegExp(r"titulo\soriginal\s:\s([a-z :\s]*)"),
    new RegExp(r"&[a-z áéíóú]*\(([a-z ]*)\)"),
  ];
  RegExpMatch match;

  for (var exp in exps) {
    match = exp.firstMatch(searchString);
    if (match != null) break;
  }

  if (match == null && programItem.title.startsWith('Filmecito:')) {}

  if (match != null) {
    var title = match.group(1).trim();
    print(title);
    var url = 'http://www.omdbapi.com/?apikey=c161b4d4&t=$title';
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        omdb['imdbID'] = jsonResponse['imdbID'];
        omdb['poster'] = jsonResponse['Poster'];
        omdb['imdbRating'] = jsonResponse['imdbRating'];
        if (omdb['poster'] == 'N/A' || omdb['imdbRating'] == 'N/A') omdb = {};
        print('$title $omdb');
      }
    } catch (e) {}
  }
  return omdb;
}

bool isToday(ProgramItem programItem) {
  var today = new DateTime.now();
  var todayStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  return programItem.dateStart == todayStr;
}

bool isMovie(ProgramItem programItem) {
  var text = programItem.classification.join(',');
  return text.contains('Cine') ||
      text.contains('Pelicula') ||
      text.contains('filme');
}

bool isSerie(ProgramItem programItem) {
  var text = programItem.classification.join(',');
  return text.contains('Seri');
}

bool isNews(ProgramItem programItem) {
  var text = programItem.classification.join(',');
  return text.contains('Notici') ||
      text.contains('Telediario') ||
      text.contains('Revista') ||
      text.contains('Debate') ||
      text.contains('Boletin') ||
      text.contains('Opinión') ||
      text.contains('Entrevista') ||
      text.contains('Reportaje') ||
      text.contains('Emision especial') ||
      text.contains('Informativo');
}

bool isDocumental(ProgramItem programItem) {
  var text = programItem.classification.join(',');
  return text.contains('Documental');
}

bool isSports(ProgramItem programItem) {
  var text = programItem.classification.join(',');
  return text.contains('Deport');
}

bool isMusic(ProgramItem programItem) {
  var text = programItem.classification.join(',');
  return text.contains('Musical') ||
      text.contains('Concierto') ||
      text.contains('Espectaculo');
}
