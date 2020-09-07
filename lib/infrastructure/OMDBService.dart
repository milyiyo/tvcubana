import '../models/ProgramItem.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class OMDBService {
  static Future<Map<String, String>> getOMDBData(ProgramItem programItem) async {
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
}