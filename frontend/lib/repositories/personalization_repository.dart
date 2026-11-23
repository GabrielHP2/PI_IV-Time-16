// Feito por Felipe Batista Bastos - 25005337

import 'package:flutter/foundation.dart';

import '../models/movie_model.dart';
import '../models/platform_model.dart';

class PersonalizationRepository {
  PersonalizationRepository._();

  // Valor total que o usuário gasta mensalmente com streaming.
  static final ValueNotifier<double?> currentMonthlySpend =
      ValueNotifier<double?>(null);

  static void setCurrentMonthlySpend(double value) {
    currentMonthlySpend.value = value;
  }

  // Orçamento mensal que o usuário deseja atingir.
  static final ValueNotifier<double?> desiredMonthlySpend =
      ValueNotifier<double?>(null);

  static void setDesiredMonthlySpend(double value) {
    desiredMonthlySpend.value = value;
  }

  // Indica que o usuário registrou a prévia do planejamento.
  static final ValueNotifier<bool> isPlanRegistered =
      ValueNotifier<bool>(false);

  static void setPlanRegistered(bool value) {
    isPlanRegistered.value = value;
  }

  // Nomes das plataformas selecionadas. Mantido como String para compatibilidade
  // com a Main Page, notificações e Configurações já existentes.
  static final ValueNotifier<List<String>> subscribedPlatforms =
      ValueNotifier<List<String>>([]);

  // IDs numéricos exigidos pela função setSubscriptionPlan do backend.
  static final ValueNotifier<List<int>> subscribedPlatformIds =
      ValueNotifier<List<int>>([]);

  // Catálogo de plataformas retornado pela Cloud Function getPlatforms.
  static final ValueNotifier<List<PlatformModel>> availablePlatforms =
      ValueNotifier<List<PlatformModel>>([]);

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

  static bool containsPlatformId(int platformId) {
    return subscribedPlatformIds.value.contains(platformId);
  }

  static void togglePlatformItem(PlatformModel platform) {
    final selectedNames = [...subscribedPlatforms.value];
    final selectedIds = [...subscribedPlatformIds.value];

    if (selectedIds.contains(platform.id)) {
      selectedIds.remove(platform.id);
      selectedNames.remove(platform.name);
    } else {
      selectedIds.add(platform.id);
      if (!selectedNames.contains(platform.name)) {
        selectedNames.add(platform.name);
      }
    }

    subscribedPlatforms.value = selectedNames;
    subscribedPlatformIds.value = selectedIds;
  }

  // Filmes e séries que o usuário informou estar assistindo.
  static final ValueNotifier<List<Movie>> ongoingContents =
      ValueNotifier<List<Movie>>([]);

  // Filmes e séries que o usuário gostaria de assistir futuramente.
  static final ValueNotifier<List<Movie>> desiredContents =
      ValueNotifier<List<Movie>>([]);

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
