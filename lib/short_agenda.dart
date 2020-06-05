import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var storedData = {'date': '', 'channelCurrentProg': []};

  @override
  void initState() {
    super.initState();

    var today = new DateTime.now();
    var todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    _prefs.then((SharedPreferences prefs) {
      var dictStr = prefs.getString('dict');
      Map valueMap = storedData;
      try {
        valueMap = json.decode(dictStr);
      } catch (e) {}

      if (todayStr == valueMap['date'] && false) {
        print('Loaded from sharedPreference');
        storedData['date'] = valueMap['date'];
        storedData['channelCurrentProg'] =
            (valueMap['channelCurrentProg'] as List)
                .map((e) => {
                      'channel': Channel.fromJson(e['channel']),
                      'programItem': ProgramItem.fromJson(e['programItem'])
                    })
                .toList();

        setState(() {
          storedData['channelCurrentProg'] = storedData['channelCurrentProg'];
        });
      } else {
        print('Store in sharedPreference');
        storedData['date'] = todayStr;

        for (var i = 0; i < gChannels.length; i++) {
          getProgram(gChannels[i]).then((programs) {
            var program = programs.firstWhere((p) => p.date == todayStr,
                orElse: () => null);
            if (program == null) return;

            program.channelId = gChannels[i].id;
            var currentProgram = getTheCurrentProgram(program.programItems);
            if (currentProgram == null) return;

            var res = {'channel': gChannels[i], 'programItem': currentProgram};
            (storedData['channelCurrentProg'] as List).add(res);

            setState(() {
              storedData['channelCurrentProg'] =
                  storedData['channelCurrentProg'];
            });

            _prefs.then((SharedPreferences prefs) {
              return (prefs.setString('dict', json.encode(storedData)));
            });
          });
        }
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
