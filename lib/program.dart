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
    print('Program toJson');
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

  ProgramItem(this.description, this.descriptionLong, this.duration, this.date,
      this.dateStart, this.dateEnd, this.timeStart, this.timeEnd, this.title);

  ProgramItem.fromJson(Map<String, dynamic> json)
      : description = json['description'],
        descriptionLong = json['descriptionLong'],
        duration = json['duration'],
        date = json['date'],
        dateStart = json['dateStart'],
        dateEnd = json['dateEnd'],
        timeStart = json['timeStart'],
        timeEnd = json['timeEnd'],
        title = json['title'];

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
      };
}
