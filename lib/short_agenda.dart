import 'dart:async';

import 'package:flutter/material.dart';

import 'channel.dart';
import 'program.dart';
import 'utils.dart';

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

  @override
  void initState() {
    super.initState();

    var today = new DateTime.now();
    var todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    storedData['date'] = todayStr;
    getChannels().then((channels) => getAgendaData(channels, todayStr));

    timer = new Timer.periodic(new Duration(seconds: 5), (Timer t) {
      getChannels().then((channels) => getAgendaData(channels, todayStr));
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
      getProgram(channel).then((programs) {
        var program =
            programs.firstWhere((p) => p.date == todayStr, orElse: () => null);
        if (program == null) return;

        program.channelId = channel.id;
        var currentProgram = getTheCurrentProgram(program.programItems);
        if (currentProgram[0] == null) return;

        var curr = {'channel': channel, 'programItem': currentProgram[0]};
        (storedData['channelCurrentProg'] as List).add(curr);

        var next = {'channel': channel, 'programItem': currentProgram[1]};
        (storedData['channelNextProg'] as List).add(next);

        if (mounted)
          setState(() {
            storedData['channelCurrentProg'] = storedData['channelCurrentProg'];
            storedData['channelNextProg'] = storedData['channelNextProg'];
          });
      });
    }
  }

  Widget headerText(String text) {
    return Container(
      color: Colors.lightBlue[200],
      child: Container(
        margin: new EdgeInsets.only(left: 20, top: 20, bottom: 10),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            text,
            style: new TextStyle(fontSize: 28),
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

      return ListTile(
        leading: getImageForChannel(channel.name, 50),
        subtitle: Column(
          children: [
            Container(
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '> ${channel.name}',
                  style: new TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            programItem == null
                ? new Container()
                : Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      programItem.descriptionLong.trim(),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
          ],
        ),
        title: Text(
          '${programItem?.title}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var channelCurrentProg = storedData['channelCurrentProg'] as List;
    var channelNextProg = storedData['channelNextProg'] as List;
    return ListView(children: [
      Column(
        children: [
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
        ],
      ),
    ]);
  }
}
