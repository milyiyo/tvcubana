import 'package:flutter/material.dart';

import 'channel.dart';
import 'channel_program.dart';
import 'short_agenda.dart';

class TabBarDemo extends StatelessWidget {
  List<Channel> channels;

  TabBarDemo(this.channels);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.access_time)),
                Tab(icon: Icon(Icons.calendar_today)),
                Tab(icon: Icon(Icons.favorite)),
                Tab(icon: Icon(Icons.view_agenda)),
              ],
            ),
            title: Text('Cartelera TVC'),
          ),
          body: TabBarView(
            children: [
              GridView.count(
                // Create a grid with 2 columns. If you change the scrollDirection to
                // horizontal, this produces 2 rows.
                crossAxisCount: 2,
                // Generate 100 widgets that display their index in the List.
                children: channels
                    .map((e) => Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                // leading: Icon(Icons.album),
                                title: Text(
                                  e.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                subtitle: Text('${e.description}.'),
                              ),
                              ButtonBar(
                                children: <Widget>[
                                  FlatButton(
                                    child: Text('Ver cartelera'),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ChannelProgram(e)),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
              ShortAgenda(),
            ],
          ),
        ),
      ),
    );
  }
}
