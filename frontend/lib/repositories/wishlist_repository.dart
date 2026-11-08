
import 'package:flutter/material.dart';
import '../models/movie_model.dart';

class WishlistRepository {
  WishlistRepository._();

  static final ValueNotifier<List<Movie>> items =
      ValueNotifier<List<Movie>>([]);

  static bool contains(String movieId) {
    return items.value.any((movie) => movie.id == movieId);
  }

  static void add(Movie movie) {
    if (contains(movie.id)) return;

    items.value = [...items.value, movie];
  }

  static void remove(String movieId) {
    items.value = items.value
        .where((movie) => movie.id != movieId)
        .toList();
  }

  static void toggle(Movie movie) {
    if (contains(movie.id)) {
      remove(movie.id);
    } else {
      add(movie);
    }
  }
}
