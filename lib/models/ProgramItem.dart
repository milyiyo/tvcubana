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

  ProgramItem(
      this.id,
      this.description,
      this.descriptionLong,
      this.duration,
      this.date,
      this.dateStart,
      this.dateEnd,
      this.timeStart,
      this.timeEnd,
      this.title,
      this.classification);

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
        classification =
            (pjson['classification'] as List).map((e) => e.toString()).toList();

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

  bool isToday() {
    var today = new DateTime.now();
    var todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return this.dateStart == todayStr;
  }

  bool isMovie() {
    var text = this.classification.join(',');
    return text.contains('Cine') ||
        text.contains('Pelicula') ||
        text.contains('filme');
  }

  bool isSerie() {
    var text = this.classification.join(',');
    return text.contains('Seri');
  }

  bool isNews() {
    var text = this.classification.join(',');
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

  bool isDocumental() {
    var text = this.classification.join(',');
    return text.contains('Documental');
  }

  bool isSports() {
    var text = this.classification.join(',');
    return text.contains('Deport');
  }

  bool isMusic() {
    var text = this.classification.join(',');
    return text.contains('Musical') ||
        text.contains('Concierto') ||
        text.contains('Espectaculo');
  }
}
