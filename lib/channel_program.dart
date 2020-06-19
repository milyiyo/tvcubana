import 'dart:async';
import 'dart:math';

import 'package:tvcubana/program.dart';
import 'package:flutter/material.dart';
import 'channel.dart';
import 'utils.dart';

class ChannelProgram extends StatefulWidget {
  Channel channel;
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

    getProgram(widget.channel, false).then((value) => setState(() {
          programs = value;
        }));
  }

  void reloadData() {
    getProgram(widget.channel, true).then((value) => setState(() {
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
            children: programs
                .map((p) => ListView(
                      controller: scrollController,
                      children: (p == null || p.programItems.length == 0)
                          ? [Image.asset('assets/images/noresult.jpg')]
                          : <Widget>[
                              ...p.programItems.map(
                                (pitem) {
                                  var shouldPositionTheScroll =
                                      getTheCurrentProgram(p.programItems)
                                              .first ==
                                          pitem;
                                  return Card(
                                    key: shouldPositionTheScroll
                                        ? stickyKey
                                        : null,
                                    child: Ink(
                                      color: shouldPositionTheScroll
                                          ? Colors.lightBlue[50]
                                          : Colors.transparent,
                                      child: ListTile(
                                        leading: getImageForCategory(pitem),
                                        title: Text(pitem.title),
                                        subtitle: Text(pitem.timeStart +
                                            ' ' +
                                            pitem.descriptionLong),
                                        isThreeLine: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Center(
                              //   child: RaisedButton(
                              //     onPressed: () {
                              //       Navigator.pop(context);
                              //     },
                              //     child: Text('Go back!'),
                              //   ),
                              // ),
                            ],
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

getImageForCategory(ProgramItem pitem) {
  var categories = pitem.classification.join(' ').toLowerCase();

  var getIcon =
      (IconData icon) => Icon(icon, size: 50, color: Colors.lightBlue[400]);

  if (categories.contains('concierto') ||
      categories.contains('musi') ||
      categories.contains('recital') ||
      categories.contains('espectaculo')) return getIcon(Icons.music_video);

  if (categories.contains('animacion') ||
      categories.contains('telefilme') ||
      categories.contains('pelicula') ||
      categories.contains('cine')) return getIcon(Icons.movie);

  if (categories.contains('documenta')) return getIcon(Icons.videocam);
  if (categories.contains('depor')) return getIcon(Icons.accessibility);

  if (categories.contains('formacion general') ||
      categories.contains('teleclase')) return getIcon(Icons.school);

  if (categories.contains('reportaje') ||
      categories.contains('concurso') ||
      categories.contains('disertacion especializada') ||
      categories.contains('opinión') ||
      categories.contains('resumen informativo') ||
      categories.contains('promoción de la programación') ||
      categories.contains('telediario') ||
      categories.contains('noticiero') ||
      categories.contains('emision') ||
      categories.contains('revista') ||
      categories.contains('debate') ||
      categories.contains('capsula') ||
      categories.contains('boletin') ||
      categories.contains('spot')) return getIcon(Icons.mic);

  if (categories.contains('utilitario'))
    return Icon(Icons.home, size: 50, color: Colors.lightBlue[400]);

  if (categories.contains('seriado') || categories.contains('serie'))
    return getIcon(Icons.subscriptions);

  if (categories.contains('novela')) return getIcon(Icons.dvr);

  print(categories);

  return FlutterLogo(size: 72.0);
}
