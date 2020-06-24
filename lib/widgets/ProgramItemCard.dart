
import 'package:flutter/material.dart';
import 'package:tvcubana/models/ProgramItem.dart';
import '../utils.dart';

class ProgramItemCard extends StatelessWidget {
  const ProgramItemCard({
    Key key,
    @required this.shouldPositionTheScroll,
    @required this.stickyKey,
    @required this.programItem,
    @required this.iconWidget,
  }) : super(key: key);

  final bool shouldPositionTheScroll;
  final GlobalKey<State<StatefulWidget>> stickyKey;
  final ProgramItem programItem;
  final Widget iconWidget;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: shouldPositionTheScroll ? stickyKey : null,
      child: Ink(
        color: shouldPositionTheScroll
            ? Colors.lightBlue[50]
            : Colors.transparent,
        child: ListTile(
          leading: iconWidget, //getImageForCategory(programItem),
          title: Text(programItem.title),
          subtitle: Text(programItem.timeStart +
              ' ' +
              programItem.descriptionLong),
          isThreeLine: true,
        ),
      ),
    );
  }
}