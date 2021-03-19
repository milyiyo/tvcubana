import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/Channel.dart';
import '../models/Program.dart';

class CacheManager {
  static void clearCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static Future<List<Program>> retrievePrograms(
      String channelId, String dateStr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var programsStr = prefs.getString('programs_${channelId}_$dateStr');
    var decodedStr = json.decode(programsStr);
    var programs =
        (decodedStr as List).map((e) => Program.fromJson(e)).toList();
    return programs;
  }

  static Future<List<Channel>> retrieveChannels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var channelsStr = prefs.getString('channels');
    var decodedStr = json.decode(channelsStr);
    var channels =
        (decodedStr as List).map((e) => Channel.fromJson(e)).toList();
    return channels;
  }

  static void storePrograms(
      List<Program> programs, String channelId, String dateStr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('programs_${channelId}_$dateStr', json.encode(programs));
  }

  static Future<void> storeChannels(List<Channel> channels) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('channels', json.encode(channels));
  }

  static Future<void> storeDate(String date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('date', date);
  }

  static Future<bool> hasCacheForProgram(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().contains(key);
  }

  static Future<bool> hasCacheFor(String dateStr) async {
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

    return parsedDate.isBefore(DateTime.parse(cacheDateStr)) ||
        parsedDate == DateTime.parse(cacheDateStr);
  }

  static void storeShowImages(bool showImagesimdb) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'showImagesimdb';
    prefs.setBool(key, showImagesimdb);
  }

  static Future<bool> readShowImagesimdb() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showImagesimdb') ?? true;
  }
}
