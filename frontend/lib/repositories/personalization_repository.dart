import 'package:flutter/foundation.dart';

import '../models/movie_model.dart';

class PersonalizationRepository {
  PersonalizationRepository._();

  // Valor total que o usuário gasta mensalmente com streaming.
  static final ValueNotifier<double?> currentMonthlySpend =
      ValueNotifier<double?>(null);

  static void setCurrentMonthlySpend(double value) {
    currentMonthlySpend.value = value;
  }

  // Plataformas que o usuário informou assinar.
  static final ValueNotifier<List<String>> subscribedPlatforms =
      ValueNotifier<List<String>>([]);

  // Filmes e séries que o usuário informou estar assistindo.
  static final ValueNotifier<List<Movie>> ongoingContents =
      ValueNotifier<List<Movie>>([]);

  // Filmes e séries que o usuário gostaria de assistir futuramente.
  static final ValueNotifier<List<Movie>> desiredContents =
      ValueNotifier<List<Movie>>([]);

  static bool containsPlatform(String platform) {
    return subscribedPlatforms.value.contains(platform);
  }

  static void togglePlatform(String platform) {
    final currentPlatforms = subscribedPlatforms.value;

    if (currentPlatforms.contains(platform)) {
      subscribedPlatforms.value = currentPlatforms
          .where((item) => item != platform)
          .toList();
    } else {
      subscribedPlatforms.value = [...currentPlatforms, platform];
    }
  }

  static bool containsOngoingContent(String movieId) {
    return ongoingContents.value.any((movie) => movie.id == movieId);
  }

  static void toggleOngoingContent(Movie movie) {
    final currentContents = ongoingContents.value;

    if (containsOngoingContent(movie.id)) {
      ongoingContents.value = currentContents
          .where((item) => item.id != movie.id)
          .toList();
    } else {
      ongoingContents.value = [...currentContents, movie];
    }
  }

  static bool containsDesiredContent(String movieId) {
    return desiredContents.value.any((movie) => movie.id == movieId);
  }

  static void toggleDesiredContent(Movie movie) {
    final currentContents = desiredContents.value;

    if (containsDesiredContent(movie.id)) {
      desiredContents.value = currentContents
          .where((item) => item.id != movie.id)
          .toList();
    } else {
      desiredContents.value = [...currentContents, movie];
    }
  }
}
