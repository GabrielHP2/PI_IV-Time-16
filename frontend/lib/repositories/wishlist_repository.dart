import 'package:flutter/foundation.dart';

import '../models/movie_model.dart';
import '../services/wishlist_service.dart';

/// Repositório da lista de desejos persistida no MongoDB via Cloud Functions.
class WishlistRepository {
  WishlistRepository._();

  static final WishlistService _service = WishlistService();

  static final ValueNotifier<List<Movie>> items =
      ValueNotifier<List<Movie>>(<Movie>[]);

  static bool _isLoaded = false;
  static Future<void>? _loading;

  static bool get isLoaded => _isLoaded;

  static bool contains(String movieId) {
    return items.value.any((movie) => movie.id == movieId);
  }

  static Future<void> load() async {
    if (_isLoaded) return;
    if (_loading != null) return _loading!;

    _loading = _loadFromServer();
    try {
      await _loading;
    } finally {
      _loading = null;
    }
  }

  static Future<void> refresh() async {
    await _loadFromServer();
  }

  static Future<void> _loadFromServer() async {
    final movies = await _service.getWishlist();
    items.value = List<Movie>.unmodifiable(movies);
    _isLoaded = true;
  }

  static Future<void> add(Movie movie) async {
    if (contains(movie.id)) return;
    await _service.addToWishlist(movie);
    items.value = List<Movie>.unmodifiable([...items.value, movie]);
  }

  static Future<void> remove(String movieId) async {
    final movie = items.value.where((item) => item.id == movieId).firstOrNull;
    if (movie == null) return;

    await _service.removeFromWishlist(movie);
    items.value = List<Movie>.unmodifiable(
      items.value.where((item) => item.id != movieId),
    );
  }

  static Future<void> toggle(Movie movie) async {
    if (contains(movie.id)) {
      await remove(movie.id);
    } else {
      await add(movie);
    }
  }
}
