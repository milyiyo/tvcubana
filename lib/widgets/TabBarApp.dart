import 'package:tvcubana/infrastructure/CacheManager.dart';
import 'package:tvcubana/models/Channel.dart';
import 'package:tvcubana/utils.dart';
import 'package:flutter/material.dart';
import 'package:tvcubana/widgets/ConfigPage.dart';
import 'package:tvcubana/widgets/SearchPage.dart';
import 'package:draggable_floating_button/draggable_floating_button.dart';

import '../infrastructure/ICRTService.dart';
import 'ChannelProgram.dart';
import 'ImdbPage.dart';
import 'MoviesList.dart';
import 'ShortAgenda.dart';

class TabBarApp extends StatefulWidget {
  @override
  _TabBarAppState createState() => _TabBarAppState();
}

class _TabBarAppState extends State<TabBarApp> {
  var channels = <Channel>[];
  var isLoading = false;
  var isSearchActive = false;
  var isShowImagesActive = true;

  @override
  void initState() {
    super.initState();

    isLoading = true;
    ICRTService.getChannels(false).then((value) {
      if (mounted) {
        channels = value.where((element) => element.name != null).toList();
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void reloadData() {
    setState(() {
      isLoading = true;
    });

    ICRTService.getChannels(true).then((channels) {
      for (var i = 0; i < channels.length; i++) {
        ICRTService.getProgram(channels[i], true).then((programs) {
          if (i == channels.length - 1)
            setState(() {
              isLoading = false;
            });
        });
      }
    });
  }

  void onChangeSearchTerm(String searchTerm) {
    if (searchTerm.length > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ImdbPage('')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: 'Ahora'),
                Tab(text: 'Categorías'),
                Tab(text: 'Canales'),
              ],
            ),
            title: isSearchActive
                ? TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(hintText: 'Texto a buscar'),
                    onChanged: (value) => onChangeSearchTerm(value),
                  )
                : Text('TVCubana'),
            actions: <Widget>[
              // action button
              if (isSearchActive)
                IconButton(
                  tooltip: 'Cancelar',
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      isSearchActive = false;
                    });
                  },
                )
              else
                IconButton(
                  tooltip: 'Buscar',
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                ),
              IconButton(
                tooltip: 'Configuración',
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ConfigPage()),
                  ).then((value) => CacheManager.readShowImagesimdb()
                      .then((value) => setState(() {
                            isShowImagesActive = value;
                          })));
                },
              ),
              // overflow menu
            ],
          ),
          floatingActionButton: 
            DraggableFloatingActionButton(
              // offset: new Offset(100, 100),
              child: new Icon(
                Icons.refresh
              ),
              onPressed: () => reloadData(),
              appContext: context,
              heroTag: 'tag2',
              ),
          body: FutureBuilder<void>(
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) =>
                TabBarView(
              children: [
                ShortAgenda(),
                CategoriesList(),
                isLoading
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: CircularProgressIndicator(),
                      ))
                    : OrientationBuilder(
                        builder: (context, orientation) {
                          return GridView.count(
                            // Create a grid with 2 columns. If you change the scrollDirection to
                            // horizontal, this produces 2 rows.
                            crossAxisCount:
                                orientation == Orientation.portrait ? 2 : 4,
                            children: [
                              ...channels.map(
                                (e) => Card(
                                  // Clip the content outside the Card to avoid the image overflow
                                  clipBehavior: Clip.antiAlias,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ChannelProgram(e)),
                                      );
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          title: Text(
                                            e.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          subtitle: Text('${e.description}.'),
                                        ),
                                        getImageForChannel(e.name, 100),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              new Container()
                            ],
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
