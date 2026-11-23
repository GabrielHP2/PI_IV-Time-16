import 'package:cloud_functions/cloud_functions.dart';

import '../models/movie_model.dart';
import '../models/platform_model.dart';

class PersonalizationService {
  PersonalizationService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  final FirebaseFunctions _functions;

  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  /// Busca as plataformas disponíveis no catálogo do backend.
  Future<List<PlatformModel>> getPlatforms() async {
    try {
      final result = await _functions.httpsCallable('getPlatforms').call();
      if (result.data is! List) {
        throw Exception('O backend retornou uma lista de plataformas inválida.');
      }

      return (result.data as List<dynamic>).map((item) {
        if (item is! Map) {
          throw const FormatException('Plataforma retornada em formato inválido.');
        }
        return PlatformModel.fromMap(Map<String, dynamic>.from(item));
      }).where((platform) => platform.name.isNotEmpty).toList();
    } on FirebaseFunctionsException catch (error) {
      throw _translateError(error, 'Não foi possível carregar as plataformas.');
    }
  }

  /// Pesquisa filmes e séries e busca os detalhes de cada resultado.
  /// getSpecificContent retorna duas categorias: movie e tv.
  Future<List<Movie>> searchContent(String title) async {
    final query = title.trim();
    if (query.length < 2) return [];

    try {
      final searchResult = await _functions
          .httpsCallable('getSpecificContent')
          .call(<String, dynamic>{'title': query, 'page': 1});

      if (searchResult.data is! List) {
        throw Exception('O backend retornou resultados em formato inválido.');
      }

      final List<Future<Movie?>> detailRequests = [];
      for (final categoryResult in searchResult.data as List<dynamic>) {
        if (categoryResult is! Map) continue;
        final categoryMap = Map<String, dynamic>.from(categoryResult);
        final String category =
    categoryMap['category']?.toString() ?? '';
        final rawResults = categoryMap['results'];
        if ((category != 'movie' && category != 'tv') || rawResults is! List) {
          continue;
        }

        // Limita a quantidade para evitar muitas chamadas simultâneas ao TMDB.
        for (final item in rawResults.take(10)) {
          if (item is! Map) continue;
          final rawId = item['id'];
          if (rawId is! num || rawId < 1) continue;
          detailRequests.add(_getContentDetails(rawId.toInt(), category));
        }
      }

      final details = await Future.wait(detailRequests);
      return details.whereType<Movie>().toList();
    } on FirebaseFunctionsException catch (error) {
      throw _translateError(error, 'Não foi possível pesquisar filmes e séries.');
    }
  }

  Future<Movie?> _getContentDetails(int id, String category) async {
    final result = await _functions.httpsCallable('getContentDetails').call(
      <String, dynamic>{'id': id, 'category': category},
    );

    if (result.data is! Map) return null;
    final data = Map<String, dynamic>.from(result.data as Map);
    final title = (data['title'] ?? data['name'] ?? '').toString().trim();
    if (title.isEmpty) return null;

    final rawGenres = data['genre'];
    final genres = rawGenres is List
        ? rawGenres.map((item) => item.toString()).where((item) => item.isNotEmpty).toList()
        : <String>[];

    final rawPlatforms = data['platform'];
    final platforms = rawPlatforms is List
        ? rawPlatforms
            .whereType<Map>()
            .map((item) => item['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList()
        : <String>[];

    final posterPath = data['poster_path']?.toString() ?? '';
    final releaseDate = (data['release_date'] ?? data['first_air_date'] ?? '').toString();
    final rawRating = data['rating'];

    return Movie(
      // O ID inclui a categoria porque filmes e séries podem ter IDs iguais.
      id: '$category:$id',
      title: title,
      synopsis: data['synopsis']?.toString() ?? '',
      releaseDate: releaseDate,
      rating: rawRating is num ? rawRating.toDouble() : 0,
      genre: genres.join(', '),
      platforms: platforms,
      imageUrl: posterPath.isEmpty ? '' : '$_imageBaseUrl$posterPath',
      category: category,
    );
  }

  Exception _translateError(FirebaseFunctionsException error, String fallback) {
    switch (error.code) {
      case 'unauthenticated':
        return Exception('Faça login para pesquisar no catálogo.');
      case 'unavailable':
        return Exception('Serviço indisponível. Verifique se o Firebase Emulator está ativo.');
      case 'invalid-argument':
        return Exception(error.message ?? 'Informe um termo válido para a pesquisa.');
      default:
        return Exception(error.message ?? fallback);
    }
  }
}
