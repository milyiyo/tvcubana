class ProgramItem {
  String id;
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

  ProgramItem(this.id, this.description, this.descriptionLong, this.duration, this.date,
      this.dateStart, this.dateEnd, this.timeStart, this.timeEnd, this.title, this.classification);

  ProgramItem.fromJson(Map<String, dynamic> pjson)
      : description = pjson['description'],
        descriptionLong = pjson['descriptionLong'],
        duration = pjson['duration'],
        id = pjson['id'],
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
        'id': id,
        'date': date,
        'dateStart': dateStart,
        'dateEnd': dateEnd,
        'timeStart': timeStart,
        'timeEnd': timeEnd,
        'title': title,
        'classification': classification
      };
}
