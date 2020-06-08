import 'package:cartelera_tvc/program.dart';
import 'package:cartelera_tvc/utils.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:chips_choice/chips_choice.dart';
import 'channel.dart';

class MoviesList extends StatefulWidget {
  @override
  _MoviesListState createState() => _MoviesListState();
}

class _MoviesListState extends State<MoviesList> {
  var movies = new List();
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    chargeList();
  }

  void chargeList() {
    movies.clear();
    getChannels().then((channels) {
      channels.forEach((channel) {
        getProgram(channel).then((programs) {
          programs.forEach((program) {
            program.programItems.forEach((programItem) async {
              if (isToday(programItem) &&
                  mounted &&
                  ((isMovie(programItem) && moviesIsSeleted()) ||
                      (isSerie(programItem) && seriesIsSeleted()) ||
                      (isMusic(programItem) && musicIsSeleted()) ||
                      (isSports(programItem) && sportsIsSeleted()) ||
                      (isNews(programItem) && newsIsSeleted()) ||
                      (isDocumental(programItem) && documentalsIsSeleted()))) {
                RegExp exp1 = new RegExp(r"Título\soriginal:\s([A-Za-z :]*)");
                RegExp exp2 = new RegExp(r"([A-Za-z ]*)\s\(Titulo\sOriginal\)");
                RegExpMatch match =
                    exp1.firstMatch(programItem.descriptionLong);
                if (match == null) {
                  match = exp2.firstMatch(programItem.descriptionLong);
                }
                if (match == null &&
                    programItem.title.startsWith('Filmecito:')) {}

                Map<String, String> omdb = {};
                // if (match != null) {
                //   var title = match.group(1);
                //   print(title);
                //   var url = 'http://www.omdbapi.com/?apikey=c161b4d4&t=$title';
                //   var response = await http.get(url);
                //   if (response.statusCode == 200) {
                //     var jsonResponse = convert.jsonDecode(response.body);
                //     omdb['poster'] = jsonResponse['Poster'];
                //     omdb['imdbRating'] = jsonResponse['imdbRating'];
                //     print('$title $omdb');
                //   }
                // }

                setState(() {
                  movies.add([channel, programItem, omdb]);
                  movies.sort((a, b) {
                    var programA = (a[1] as ProgramItem);
                    var date0 = DateTime.parse(
                        '${programA.dateStart} ${programA.timeStart}');

                    var programB = (b[1] as ProgramItem);
                    var date1 = DateTime.parse(
                        '${programB.dateStart} ${programB.timeStart}');

                    return date0.compareTo(date1);
                  });
                  isLoading = false;
                });
              }
            });
          });
        });
      });
    });
  }

  List<String> tags = [
    'Películas',
    'Series',
    'Noticias',
    'Deporte',
    'Documentales',
    'Musicales'
  ];
  List<String> options = [
    'Películas',
    'Series',
    'Noticias',
    'Deporte',
    'Documentales',
    'Musicales'
  ];

  bool moviesIsSeleted() {
    return this.tags.contains('Películas');
  }

  bool seriesIsSeleted() {
    return this.tags.contains('Series');
  }

  bool newsIsSeleted() {
    return this.tags.contains('Noticias');
  }

  bool sportsIsSeleted() {
    return this.tags.contains('Deporte');
  }

  bool documentalsIsSeleted() {
    return this.tags.contains('Documentales');
  }

  bool musicIsSeleted() {
    return this.tags.contains('Musicales');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: ChipsChoice<String>.multiple(
              value: tags,
              options: ChipsChoiceOption.listFrom<String, String>(
                source: options,
                value: (i, v) => v,
                label: (i, v) => v,
              ),
              onChanged: (val) => setState(() {
                tags = val;
                chargeList();
              }),
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: isLoading
                  ? [
                      Center(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: CircularProgressIndicator(),
                      ))
                    ]
                  : [
                      ...movies.map((e) {
                        var channel = (e[0] as Channel);
                        var programItem = (e[1] as ProgramItem);
                        var omdb = (e[2] as Map<String, String>);
                        return ListTile(
                          leading: getImageForChannel(channel.name, 50),
                          title: Text(programItem.title),
                          subtitle: Column(
                            children: [
                              omdb['poster'] == null
                                  ? new Container()
                                  : Image.network(
                                      omdb['poster'],
                                      height: 300,
                                    ),
                              omdb['imdbRating'] == null
                                  ? new Container()
                                  : Text(omdb['imdbRating']),
                              Container(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                      '${programItem.timeStart} ${channel.name}'),
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
          ),
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
      text.contains('Reportaje')||
      text.contains('Emision especial')||
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
