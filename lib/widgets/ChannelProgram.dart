import 'dart:async';
import 'dart:math';

import 'package:tvcubana/infrastructure/OMDBService.dart';
import 'package:tvcubana/models/Channel.dart';
import 'package:tvcubana/models/Program.dart';

import '../infrastructure/ICRTService.dart';
import '../utils.dart';
import 'package:flutter/material.dart';

import 'ProgramItemCard.dart';

class ChannelProgram extends StatefulWidget {
  final Channel channel;
  ChannelProgram(this.channel);

  @override
  _ChannelProgramState createState() => _ChannelProgramState();
}

class _ChannelProgramState extends State<ChannelProgram> {
  List<Program> programs = [null, null, null, null, null, null, null];
  var datesOfWeek = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  ScrollController scrollController = new ScrollController();
  GlobalKey stickyKey = GlobalKey();
  bool shouldScroll = true;

  @override
  void initState() {
    super.initState();

    ICRTService.getProgram(widget.channel, false).then((value) => setState(() {
          programs = value;
        }));
  }

  void reloadData() {
    ICRTService.getProgram(widget.channel, true).then((value) => setState(() {
          programs = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 3000), () {
      final keyContext = stickyKey.currentContext;
      if (keyContext != null && shouldScroll) {
        // widget is visible
        final box = keyContext.findRenderObject() as RenderBox;
        final pos =
            box.localToGlobal(Offset.fromDirection(270 * pi / 180, 100));
        scrollController.jumpTo(pos.dy);
        setState(() {
          shouldScroll = false;
        });
      }
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tag1',
        onPressed: reloadData,
        label: Text('Recargar'),
        icon: Icon(Icons.refresh),
        backgroundColor: Colors.blue,
      ),
      body: DefaultTabController(
        length: datesOfWeek.length,
        initialIndex: new DateTime.now().weekday - 1,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: datesOfWeek.map((t) => Tab(text: t)).toList(),
            ),
            title: Text("Cartelera ${widget.channel.name}"),
          ),
          body: TabBarView(
            children: programs.map((p) {
              var currentProgram = (p == null || p.programItems.length == 0)
                  ? null
                  : getTheCurrentProgram(p.programItems).first;
              return ListView(
                controller: scrollController,
                children: (p == null || p.programItems.length == 0)
                    ? [noResultsFound()]
                    : <Widget>[
                        ...p.programItems.map(
                          (pitem) {
                            var shouldPositionTheScroll =
                                currentProgram == pitem;

                            var result = new FutureBuilder<Map<String, String>>(
                                future: OMDBService.getOMDBData(pitem),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Map<String, String>>
                                        snapshot) {
                                  
                                  if(snapshot.data == {} || snapshot.data == null){
                                    return ProgramItemCard(
                                      shouldPositionTheScroll:
                                          shouldPositionTheScroll,
                                      stickyKey: stickyKey,
                                      programItem: pitem,
                                      iconWidget: getImageForCategory(pitem));
                                  }
                                  
                                  return ProgramItemCard(
                                      shouldPositionTheScroll:
                                          shouldPositionTheScroll,
                                      stickyKey: stickyKey,
                                      programItem: pitem,
                                      omdbPoster: snapshot.data['poster'],
                                      omdbRating: snapshot.data['imdbRating'],
                                      imdbID: snapshot.data['imdbID'],
                                      iconWidget: getImageForCategory(pitem));
                                });

                            return result;
                          },
                        ),
                      ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget noResultsFound() {
    var image = Image.asset('assets/images/icon_noresults.png');
    return ListView(shrinkWrap: true, children: <Widget>[
      image,
      Text(
        "No se encontraron resultados",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      )
    ]);
  }
}
