import 'dart:convert';

import 'Program.dart';

class Channel {
  String id;
  String name;
  String logo;
  String description;
  List<Program> programs = [];

  Channel(this.id, this.name, this.logo, this.description);

  @override
  String toString() {
    return "${this.id}, ${this.name}, ${this.logo}, ${this.description}\n";
  }

  Channel.fromJson(Map<String, dynamic> pjson)
      : id = pjson['id'],
        name = pjson['name'],
        logo = pjson['logo'],
        description = pjson['description'],
        programs = (json.decode(pjson['programs']) as List).map((e) => Program.fromJson(e)).toList();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'description': description,
      'programs': json.encode(programs.map((e) => e.toJson()).toList()),
    };
  }
}
