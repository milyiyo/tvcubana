import 'package:flutter/material.dart';
import 'package:tvcubana/models/Channel.dart';
import 'package:tvcubana/models/ProgramItem.dart';
import 'package:tvcubana/widgets/ProgramItemCard.dart';

import '../utils.dart';

class SearchPage extends StatefulWidget {
  SearchPage();

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var _controller = TextEditingController();
  var _searchQuery = '';
  var _programs = new List();

  @override
  void initState() {
    super.initState();
    chargeList();
  }

  void chargeList() {
    _programs.clear();
    getChannels(false).then((channels) {
      channels.forEach((channel) {
        getProgram(channel, false).then((programs) {
          programs.forEach((program) {
            program.programItems.forEach((programItem) async {
              setState(() {
                _programs.add([channel, programItem]);
              });
            });
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _controller.addListener(() {
      setState(() {
        _searchQuery = _controller.text;
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Texto a buscar',
            suffixIcon: IconButton(
              onPressed: () => _controller.clear(),
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          ..._programs.where((element) {
            var programItem = (element[1] as ProgramItem);
            var lowerCaseSearch = _searchQuery.toLowerCase();
            return programItem.title.toLowerCase().contains(lowerCaseSearch) ||
                programItem.descriptionLong
                    .toLowerCase()
                    .contains(lowerCaseSearch);
          }).map((e) {
            var channel = (e[0] as Channel);
            var programItem = (e[1] as ProgramItem);
            return ProgramItemCard(
              shouldPositionTheScroll: false,
              stickyKey: null,
              programItem: programItem,
              iconWidget: getImageForChannel(channel.name, 50),
              channelName: channel.name,
              showDate: true,
            );
          }),
          new Container(margin: EdgeInsets.symmetric(vertical: 40))
        ],
      ),
    );
  }
}
