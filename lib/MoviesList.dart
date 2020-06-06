import 'package:cartelera_tvc/program.dart';
import 'package:cartelera_tvc/utils.dart';
import 'package:flutter/material.dart';

import 'channel.dart';

class MoviesList extends StatefulWidget {
  @override
  _MoviesListState createState() => _MoviesListState();
}

class _MoviesListState extends State<MoviesList> {
  var movies = new List();

  @override
  void initState() {
    super.initState();

    getChannels().then((channels) {
      channels.forEach((channel) {
        getProgram(channel).then((programs) {
          programs.forEach((program) {
            program.programItems.forEach((programItem) {
              if (isToday(programItem) && isMovie(programItem) && mounted) {
                setState(() {
                  movies.add([channel, programItem]);
                  movies.sort((a, b) {
                    var programA = (a[1] as ProgramItem);
                    var date0 = DateTime.parse(
                        '${programA.dateStart} ${programA.timeStart}');

                    var programB = (b[1] as ProgramItem);
                    var date1 = DateTime.parse(
                        '${programB.dateStart} ${programB.timeStart}');

                    return date0.compareTo(date1);
                  });
                });
              }
            });
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: [
          ...movies.map((e) {
            var channel = (e[0] as Channel);
            var programItem = (e[1] as ProgramItem);
            return ListTile(
              leading: getImageForChannel(channel.name, 50),
              title: Text(programItem.title),
              subtitle: Column(
                children: [
                  Container(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('${programItem.timeStart} ${channel.name}'),
                    ),
                  ),
                  Container(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('${programItem.descriptionLong}'),
                    ),
                  ),
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}

bool isToday(ProgramItem programItem) {
  var today = new DateTime.now();
  var todayStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  return programItem.dateStart == todayStr;
}

bool isMovie(ProgramItem programItem) {
  var keywords = ['pelicula', 'película', 'filme', 'cine', 'serie'];
  var longText =
      '${programItem.title.toLowerCase()} ${programItem.descriptionLong.toLowerCase()}';

  return keywords.any((element) => longText.contains(element));
}
