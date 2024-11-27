import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  bool isFavorite(Product product) {
    return _favorites.any((element) => element.id == product.id);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      _favorites.removeWhere((element) => element.id == product.id);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
  }

  void removeFavorite(Product product) {
    _favorites.removeWhere((element) => element.id == product.id);
    notifyListeners();
  }
}
