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
  var storedData = {'date': '', 'channelCurrentProg': []};
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

  getImageForChannel(String channelName, double dimension ) {
    // print(channelName);
    var images = getChannelImages();
    if (images.containsKey(channelName)) {
      return Image.asset(images[channelName], height: dimension, width: dimension);
    }
    return Icon(Icons.access_alarm);
  }

  getAgendaData(List<Channel> channels, String todayStr) {
    storedData = {'date': '', 'channelCurrentProg': []};

    for (var i = 0; i < channels.length; i++) {
      var channel = channels[i];
      getProgram(channel).then((programs) {
        var program =
            programs.firstWhere((p) => p.date == todayStr, orElse: () => null);
        if (program == null) return;

        program.channelId = channel.id;
        var currentProgram = getTheCurrentProgram(program.programItems);
        if (currentProgram[0] == null) return;

        var res = {'channel': channel, 'programItem': currentProgram[0]};
        (storedData['channelCurrentProg'] as List).add(res);

        if (mounted)
          setState(() {
            storedData['channelCurrentProg'] = storedData['channelCurrentProg'];
          });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var channelCurrentProg = storedData['channelCurrentProg'] as List;
    return ListView(children: [
      Column(
        children: [
          Text('Ahora'),
          Column(
            children: channelCurrentProg.length == 0
                ? []
                : [
                    ...channelCurrentProg.map((e) => ListTile(
                      leading: getImageForChannel((e['channel'] as Channel).name, 50),
                          subtitle: Text(
                            (e['channel'] as Channel).name,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          title: Text(
                            '${(e['programItem'] as ProgramItem)?.title}.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ))
                  ],
          ),
          Text('Después'),
        ],
      ),
    ]);
  }
}
