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

    getProgram(widget.channel).then((value) => setState(() {
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
                                        leading: FlutterLogo(size: 72.0),
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
