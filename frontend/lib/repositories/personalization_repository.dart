import 'package:flutter/foundation.dart';

import '../models/movie_model.dart';

class PersonalizationRepository {
  PersonalizationRepository._();

  // Plataformas que o usuário informou assinar.
  static final ValueNotifier<List<String>> subscribedPlatforms =
      ValueNotifier<List<String>>([]);

  // Filmes e séries que o usuário informou estar assistindo.
  static final ValueNotifier<List<Movie>> ongoingContents =
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
}
