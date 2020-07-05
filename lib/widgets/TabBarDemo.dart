import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/foundation.dart';
import 'package:tvcubana/models/Channel.dart';
import 'package:tvcubana/utils.dart';
import 'package:flutter/material.dart';

import '../ad_manager.dart';
import 'ChannelProgram.dart';
import 'MoviesList.dart';
import 'ShortAgenda.dart';

class TabBarDemo extends StatefulWidget {
  @override
  _TabBarDemoState createState() => _TabBarDemoState();
}

class _TabBarDemoState extends State<TabBarDemo> {
  var channels = new List<Channel>();
  var isLoading = false;
  var bannerLoaded = false;

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: ['9B3152C88AA40F2B2725F13CCEB8F39A'],
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  BannerAd _bannerAd;

  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(
          anchorType: AnchorType
              .bottom); //.then((value) => setState(() {bannerLoaded = value;}));
  }

  @override
  void initState() {
    super.initState();

    isLoading = true;
    getChannels(false).then((value) {
      if (mounted) {
        channels = value;
        setState(() {
          isLoading = false;
        });
      }
    });

    if (!kIsWeb) {
      _bannerAd = BannerAd(
        adUnitId: AdManager.bannerAdUnitId,
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) {
            setState(() {
              bannerLoaded = true;
            });
          }
        },
      );

      _loadBannerAd();
    }
  }

  @override
  void dispose() {
    // TODO: Dispose BannerAd object
    _bannerAd?.dispose();
    super.dispose();
  }

  void reloadData() {
    setState(() {
      isLoading = true;
    });

    getChannels(true).then((channels) {
      for (var i = 0; i < channels.length; i++) {
        getProgram(channels[i], true).then((programs) {
          if (i == channels.length - 1)
            setState(() {
              isLoading = false;
            });
        });
      }
    });
  }

  getImageForChannel(String channelName) {
    var images = getChannelImages();
    if (images.containsKey(channelName)) {
      return Image.asset(images[channelName], height: 100, width: 100);
    }
    return Container(
        margin: EdgeInsets.only(top: 10),
        child: Icon(
          Icons.live_tv,
          size: 50,
          color: Colors.lightBlue[200],
        ));
  }

  Future<void> _initAdMob() {
    if (!kIsWeb)
      return FirebaseAdMob.instance.initialize(appId: AdManager.appId);
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
                Tab(icon: Icon(Icons.access_time)),
                Tab(icon: Icon(Icons.category)),
                Tab(icon: Icon(Icons.view_agenda)),
              ],
            ),
            title: Text('TVCubana'),
          ),
          floatingActionButton: Container(
            margin: EdgeInsets.only(bottom: bannerLoaded ? 40 : 0),
            child: FloatingActionButton.extended(
              onPressed: reloadData,
              label: Text('Recargar'),
              icon: Icon(Icons.refresh),
              backgroundColor: Colors.blue,
            ),
          ),
          body: FutureBuilder<void>(
            future: _initAdMob(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) =>
                TabBarView(
              children: [
                isLoading
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: CircularProgressIndicator(),
                      ))
                    : GridView.count(
                        // Create a grid with 2 columns. If you change the scrollDirection to
                        // horizontal, this produces 2 rows.
                        crossAxisCount: 2,
                        // Generate 100 widgets that display their index in the List.
                        children: [...channels
                            .map(
                              (e) => Card(
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
                                      getImageForChannel(e.name),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            , new Container()],
                      ),
                MoviesList(),
                ShortAgenda(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
