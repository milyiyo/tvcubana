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

  @override
  void initState() {
    super.initState();

    var today = new DateTime.now();
    var todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    storedData['date'] = todayStr;
    getChannels().then((channels) {
      for (var i = 0; i < channels.length; i++) {
        var channel = channels[i];
        getProgram(channel).then((programs) {
          var program = programs.firstWhere((p) => p.date == todayStr,
              orElse: () => null);
          if (program == null) return;

          program.channelId = channel.id;
          var currentProgram = getTheCurrentProgram(program.programItems);
          if (currentProgram == null) return;

          var res = {'channel': channel, 'programItem': currentProgram};
          (storedData['channelCurrentProg'] as List).add(res);

          setState(() {
            storedData['channelCurrentProg'] = storedData['channelCurrentProg'];
          });
        });
      }
    });
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
                          subtitle: Text(
                            (e['channel'] as Channel).name,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          title: Text(
                            '${(e['programItem'] as ProgramItem)?.title}.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
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
