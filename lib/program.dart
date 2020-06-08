import 'dart:convert';

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

class ProgramItem {
  String dateEnd;
  String dateStart;
  String date;
  String descriptionLong;
  String description;
  String duration;
  String timeEnd;
  String timeStart;
  String title;
  List<String> classification = [];

  ProgramItem(this.description, this.descriptionLong, this.duration, this.date,
      this.dateStart, this.dateEnd, this.timeStart, this.timeEnd, this.title, this.classification);

  ProgramItem.fromJson(Map<String, dynamic> pjson)
      : description = pjson['description'],
        descriptionLong = pjson['descriptionLong'],
        duration = pjson['duration'],
        date = pjson['date'],
        dateStart = pjson['dateStart'],
        dateEnd = pjson['dateEnd'],
        timeStart = pjson['timeStart'],
        timeEnd = pjson['timeEnd'],
        title = pjson['title'],
        classification = (pjson['classification'] as List).map((e) => e.toString()).toList();

  Map<String, dynamic> toJson() => {
        'description': description,
        'descriptionLong': descriptionLong,
        'duration': duration,
        'date': date,
        'dateStart': dateStart,
        'dateEnd': dateEnd,
        'timeStart': timeStart,
        'timeEnd': timeEnd,
        'title': title,
        'classification': classification
      };
}
