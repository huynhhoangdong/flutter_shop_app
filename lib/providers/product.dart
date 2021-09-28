import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  void _setFavorite(bool oldFavorite) {
    isFavorite = oldFavorite;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    final oldFavorite = isFavorite;
    isFavorite = !isFavorite;

    final url = Uri.parse(
        'https://flutter-demo-5e00b-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken');
    try {
      final response = await http.put(url,
          body: json.encode(
            isFavorite,
          ));
      if (response.statusCode >= 400) {
        _setFavorite(oldFavorite);
      }
    } catch (e) {
      _setFavorite(oldFavorite);
    }
    notifyListeners();
  }
}
