import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ImdbPage extends StatefulWidget {
  String imdbId;
  ImdbPage(this.imdbId);

  @override
  _ImdbPageState createState() => _ImdbPageState();
}

class _ImdbPageState extends State<ImdbPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles"),
      ),
      body: WebView(initialUrl: 'https://www.imdb.com/title/${widget.imdbId}/'),
    );
  }
}
