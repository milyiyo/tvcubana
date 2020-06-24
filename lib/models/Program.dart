import 'dart:convert';

import 'ProgramItem.dart';

class Program {
  String date;
  String channelId;
  List<ProgramItem> programItems;

  Program(this.date, this.programItems);

  Program.fromJson(Map<String, dynamic> pjson)
      : date = pjson['date'],
        programItems = pjson['programItems'] == null ? [] :(json.decode(pjson['programItems']) as List).map((e) => ProgramItem.fromJson(e)).toList();

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'programItems': json.encode(programItems.map((e) => e.toJson()).toList()),
    };
  }
}
