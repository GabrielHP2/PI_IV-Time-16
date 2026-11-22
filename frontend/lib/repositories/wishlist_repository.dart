// Feito por Felipe Batista Bastos - 25005337
// Correções por Luis Felipe Pontes Mita RA - 25018740

import 'package:flutter/material.dart';
import '../models/movie_model.dart';

class WishlistRepository {
  WishlistRepository._();

  static final ValueNotifier<List<Movie>> items =
      ValueNotifier<List<Movie>>([]);

  static bool contains(int movieId) {
    return items.value.any((movie) => movie.id == movieId);
  }

  static void add(Movie movie) {
    if (contains(movie.id)) return;

    items.value = [...items.value, movie];
  }

  static void remove(int movieId) {
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