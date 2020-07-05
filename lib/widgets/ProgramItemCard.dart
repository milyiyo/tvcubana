import 'package:flutter/material.dart';
import 'package:tvcubana/models/ProgramItem.dart';
import 'package:tvcubana/widgets/ImdbPage.dart';

class ProgramItemCard extends StatelessWidget {
  const ProgramItemCard({
    Key key,
    @required this.shouldPositionTheScroll,
    @required this.stickyKey,
    @required this.programItem,
    @required this.iconWidget,
    this.omdbPoster,
    this.omdbRating,
    this.imdbID,
    this.channelName,
  }) : super(key: key);

  final bool shouldPositionTheScroll;
  final GlobalKey<State<StatefulWidget>> stickyKey;
  final ProgramItem programItem;
  final Widget iconWidget;
  final String omdbPoster;
  final String omdbRating;
  final String channelName;
  final String imdbID;

  Widget buildImageRounded(String url, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (this.imdbID != null && !kIsWeb)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ImdbPage(this.imdbID)),
          );
      },
      child: Container(
        margin:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0, bottom: 20.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0)),
        child: Center(
          child: Hero(
            tag: Random().nextDouble(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(url, height: 300),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: shouldPositionTheScroll ? stickyKey : null,
      child: Ink(
        color:
            shouldPositionTheScroll ? Colors.lightBlue[50] : Colors.transparent,
        child: ListTile(
          leading: iconWidget,
          title: Text(programItem.title),
          subtitle: Column(
            children: [
              omdbPoster == null
                  ? new Container()
                  : buildImageRounded(omdbPoster, context), //aqui
              omdbRating == null
                  ? new Container()
                  : Row(
                      children: [
                        Spacer(),
                        Icon(
                          Icons.star,
                          color: Colors.yellow[600],
                        ),
                        Text('$omdbRating / 10'),
                        Spacer(),
                      ],
                    ),
              Container(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('${programItem.timeStart} ${channelName == null ? '' : channelName}'),
                ),
              ),
              Container(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('${programItem.descriptionLong}'),
                ),
              ),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}
