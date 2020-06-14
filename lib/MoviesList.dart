import 'package:tvcubana/program.dart';
import 'package:tvcubana/utils.dart';
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
                String searchString = programItem.title.toLowerCase() +
                    ' & ' +
                    programItem.descriptionLong.toLowerCase();

                var exps = [
                  new RegExp(r"tiempo\sde\scine:\s([a-z :]*)"),
                  new RegExp(r"multicine:\s([a-z :]*)"),
                  new RegExp(r"filmecito:\s([a-z :]*)"),
                  new RegExp(r"minicinema:\s([a-z :]*)"),
                  new RegExp(r"directores\sen\sacción:\s([a-z :]*)"),
                  new RegExp(r"ellas\sy\sellos:(\s)*([a-z :]*)"),
                  new RegExp(r"cine\sde\saventuras:\s([a-z :]*)"),
                  new RegExp(r"algo\spara\srecordar:\s([a-z :]*)"),
                  new RegExp(r"t[i-í]tulo\soriginal:\s([a-z :]*)"),
                  new RegExp(r"\w*t[i-í]tulo\soriginal:\s([a-z -\s1]*)"),
                  new RegExp(r"&\s[a-z -ó2]*\st[i-í]tulo\soriginal:([a-z :\s0-9]*)"),

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

                if (match == null &&
                    programItem.title.startsWith('Filmecito:')) {}

                Map<String, String> omdb = {};
                if (match != null) {
                  var title = match.group(1).trim();
                  print(title);
                  var url = 'http://www.omdbapi.com/?apikey=c161b4d4&t=$title';
                  try {
                    var response = await http.get(url);
                    if (response.statusCode == 200) {
                      var jsonResponse = convert.jsonDecode(response.body);
                      omdb['poster'] = jsonResponse['Poster'];
                      omdb['imdbRating'] = jsonResponse['imdbRating'];
                      if(omdb['poster'] == 'N/A' || omdb['imdbRating'] == 'N/A')
                        omdb = {};
                      print('$title $omdb');
                    }
                  } catch (e) {}
                }

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
    // 'Series',
    // 'Noticias',
    // 'Deporte',
    // 'Documentales',
    // 'Musicales'
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
                                  : buildImageRounded(omdb['poster']),
                              omdb['imdbRating'] == null
                                  ? new Container()
                                  : Row(
                                      children: [
                                        Spacer(),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow[600],
                                        ),
                                        Text('${omdb['imdbRating']} / 10'),
                                        Spacer(),
                                      ],
                                    ),
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

  Container buildImageRounded(String url) {
    return Container(
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0, bottom: 20.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0)),
      child: Center(
        child: Hero(
          tag: 'tag',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(url, height: 300),
          ),
        ),
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
      text.contains('Reportaje') ||
      text.contains('Emision especial') ||
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
