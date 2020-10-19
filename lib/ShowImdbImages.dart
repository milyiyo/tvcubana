import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ShowImdbImages with ChangeNotifier {
  bool _showImdbImages = false;
  bool get showImdbImages => _showImdbImages;

  void setShowImdbImages(bool value) {
    _showImdbImages = value;

    if (hasListeners) {
      print('Notifying..');
      notifyListeners();
    }
  }
}
