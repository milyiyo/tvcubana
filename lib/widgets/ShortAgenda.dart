import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tvcubana/infrastructure/CacheManager.dart';
import 'package:tvcubana/models/Channel.dart';
import 'package:tvcubana/models/ProgramItem.dart';
import 'package:tvcubana/widgets/ProgramItemCard.dart';
import '../infrastructure/ICRTService.dart';
import '../infrastructure/OMDBService.dart';
import '../utils.dart';

class ShortAgenda extends StatefulWidget {
  const ShortAgenda({
    Key key,
  }) : super(key: key);

  @override
  _ShortAgendaState createState() => _ShortAgendaState();
}

class _ShortAgendaState extends State<ShortAgenda> {
  var storedData = {
    'date': '',
    'channelCurrentProg': [],
    'channelNextProg': []
  };
  Timer timer;
  var isLoading = false;
  bool showPosters = true;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      print("\nHas focus: ${_focusNode.hasFocus}\n");
    });

    var today = new DateTime.now();
    var todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    var yesterday = new DateTime.now().subtract(Duration(hours: 24));
    var yesterdayStr =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    var tomorrow = new DateTime.now().add(Duration(hours: 24));
    var tomorrowStr =
        '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

    storedData['date'] = todayStr;
    isLoading = true;
    CacheManager.readShowImagesimdb().then((value) => setState(() {
          showPosters = value;
          print(['Show posters: ', showPosters]);
        }));

    ICRTService.getChannels(false).then((channels) =>
        getAgendaData(channels, todayStr, yesterdayStr, tomorrowStr));

    timer = new Timer.periodic(new Duration(seconds: 60), (Timer t) {
      ICRTService.getChannels(false).then((channels) =>
          getAgendaData(channels, todayStr, yesterdayStr, tomorrowStr));
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
    timer.cancel();
  }

  void getAgendaData(List<Channel> channels, String todayStr,
      String yesterdayStr, String tomorrowStr) {
    storedData = {'date': '', 'channelCurrentProg': [], 'channelNextProg': []};

    for (var i = 0; i < channels.length; i++) {
      var channel = channels[i];
      ICRTService.getProgram(channel, false).then((programs) {
        var program = programs
            .where((p) =>
                p.date == todayStr ||
                p.date == yesterdayStr ||
                p.date == tomorrowStr)
            .toList();
        if (program.isEmpty) return;

        // program[0].channelId = channel.id;
        var currentProgram = getTheCurrentAndNextProgram(
            program[0].programItems + program[1].programItems + program[2].programItems);
        if (currentProgram[0] == null) return;

        var curr = {'channel': channel, 'programItem': currentProgram[0]};
        (storedData['channelCurrentProg'] as List).add(curr);

        if (currentProgram[1] != null) {
          var next = {'channel': channel, 'programItem': currentProgram[1]};
          (storedData['channelNextProg'] as List).add(next);
        }

        if (mounted)
          setState(() {
            storedData['channelCurrentProg'] = storedData['channelCurrentProg'];
            storedData['channelNextProg'] = storedData['channelNextProg'];
            isLoading = false;
          });

        [storedData['channelCurrentProg'], storedData['channelNextProg']]
            .forEach((e) {
          for (var item in (e as List)) {
            var pI = item['programItem'];
            if (showPosters)
              OMDBService.getOMDBData(pI).then((omdb) {
                if (omdb == {} || !mounted) return;

                setState(() {
                  item['omdb'] = omdb;
                });
              });
          }
        });
      });
    }
  }

  Widget headerText(String text) {
    return Container(
      color: Colors.blue,
      child: Container(
        margin: new EdgeInsets.only(left: 20, top: 20, bottom: 10),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            text,
            style: new TextStyle(fontSize: 28, color: Colors.white),
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }

  Iterable<Widget> getListOfItems(List<dynamic> collection) {
    if (collection.length == 0) return [];

    return collection.map((e) {
      var channel = e['channel'] as Channel;
      var programItem = e['programItem'] as ProgramItem;
      var omdb = e['omdb'] as Map<String, String>;

      var result = ProgramItemCard(
          shouldPositionTheScroll: false,
          stickyKey: null,
          programItem: programItem,
          iconWidget: getImageForChannel(channel.name, 50));

      if (omdb != null) {
        result.omdbPoster = omdb['poster'];
        result.omdbRating = omdb['imdbRating'];
        result.imdbID = omdb['imdbID'];
      }

      return result;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var channelCurrentProg = storedData['channelCurrentProg'] as List;
    var channelNextProg = storedData['channelNextProg'] as List;
    // context.watch<ShowImdbImages>().showImdbImages;
    return ListView(children: [
      Column(
        children: isLoading
            ? [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              ]
            : [
                headerText('Ahora'),
                Column(
                  children: getListOfItems(channelCurrentProg),
                ),
                Divider(
                  color: Colors.transparent,
                  height: 20,
                  thickness: 5,
                  indent: 10,
                  endIndent: 10,
                ),
                headerText('Después'),
                Column(children: getListOfItems(channelNextProg)),
                new Container(margin: EdgeInsets.symmetric(vertical: 40))
              ],
      ),
    ]);
  }
}
