import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tvcubana/models/Channel.dart';
import 'package:tvcubana/models/ProgramItem.dart';
import 'package:tvcubana/widgets/ProgramItemCard.dart';

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

  @override
  void initState() {
    super.initState();

    var today = new DateTime.now();
    var todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    storedData['date'] = todayStr;
    isLoading = true;
    getChannels(false).then((channels) => getAgendaData(channels, todayStr));

    timer = new Timer.periodic(new Duration(seconds: 5), (Timer t) {
      getChannels(false).then((channels) => getAgendaData(channels, todayStr));
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  getAgendaData(List<Channel> channels, String todayStr) {
    storedData = {'date': '', 'channelCurrentProg': [], 'channelNextProg': []};

    for (var i = 0; i < channels.length; i++) {
      var channel = channels[i];
      getProgram(channel, false).then((programs) {
        var program =
            programs.firstWhere((p) => p.date == todayStr, orElse: () => null);
        if (program == null) return;

        program.channelId = channel.id;
        var currentProgram = getTheCurrentProgram(program.programItems);
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

      return ProgramItemCard(shouldPositionTheScroll: false, stickyKey: null, programItem: programItem, iconWidget: getImageForChannel(channel.name, 50));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var channelCurrentProg = storedData['channelCurrentProg'] as List;
    var channelNextProg = storedData['channelNextProg'] as List;
    return ListView(children: [
      Column(
        children: isLoading
            ? [
                Center(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: CircularProgressIndicator(),
                ))
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