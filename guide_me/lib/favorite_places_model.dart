import 'package:flutter/foundation.dart';

class FavoritePlacesModel extends ChangeNotifier {
  List<String> _favoritePlaces = [];

  List<String> get favoritePlaces => _favoritePlaces;

  bool isFavorite(String placeName) {
    return _favoritePlaces.contains(placeName);
  }

  void add(String placeName) {
    _favoritePlaces.add(placeName);
    notifyListeners();
  }

  void remove(String placeName) {
    _favoritePlaces.remove(placeName);
    notifyListeners();
  }

  void logout() {}
}