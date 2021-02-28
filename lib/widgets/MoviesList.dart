import 'package:provider/provider.dart';
import 'package:tvcubana/ShowImdbImages.dart';
import 'package:tvcubana/models/Channel.dart';
import 'package:tvcubana/models/ProgramItem.dart';
import 'package:tvcubana/utils.dart';
import 'package:flutter/material.dart';
import 'package:chips_choice/chips_choice.dart';

import '../infrastructure/ICRTService.dart';
import '../infrastructure/OMDBService.dart';
import 'ProgramItemCard.dart';

class CategoriesList extends StatefulWidget {
  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  var movies = [];
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    chargeList();
  }

  void chargeList({bool getImdbInfo: true}) {
    movies.clear();
    ICRTService.getChannels(false).then((channels) {
      channels.forEach((channel) {
        ICRTService.getProgram(channel, false).then((programs) {
          programs.forEach((program) {
            program.programItems.forEach((programItem) async {
              if (programItem.isToday() &&
                  mounted &&
                  ((programItem.isMovie() && moviesIsSeleted()) ||
                      (programItem.isSerie() && seriesIsSeleted()) ||
                      (programItem.isMusic() && musicIsSeleted()) ||
                      (programItem.isSports() && sportsIsSeleted()) ||
                      (programItem.isNews() && newsIsSeleted()) ||
                      (programItem.isDocumental() && documentalsIsSeleted()))) {
                setState(() {
                  movies.add([channel, programItem, null]);
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

                if (getImdbInfo)
                  OMDBService.getOMDBData(programItem).then((omdb) {
                    if (omdb == {}) return;
                    setState(() {
                      var idx = movies.indexWhere((element) =>
                          (element[1] as ProgramItem).id == programItem.id);
                      if (idx >= 0) movies[idx][2] = omdb;
                    });
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
    var showImdbImages = context.watch<ShowImdbImages>().showImdbImages;
    print(showImdbImages);
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

                        if (omdb == null || !showImdbImages)
                          return ProgramItemCard(
                              shouldPositionTheScroll: false,
                              stickyKey: null,
                              programItem: programItem,
                              iconWidget: getImageForChannel(channel.name, 50),
                              channelName: channel.name);

                        return ProgramItemCard(
                            shouldPositionTheScroll: false,
                            stickyKey: null,
                            programItem: programItem,
                            omdbPoster: omdb['poster'],
                            omdbRating: omdb['imdbRating'],
                            imdbID: omdb['imdbID'],
                            iconWidget: getImageForChannel(channel.name, 50),
                            channelName: channel.name);
                      }),
                      new Container(margin: EdgeInsets.symmetric(vertical: 40))
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
