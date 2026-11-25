
import 'package:cloud_functions/cloud_functions.dart';

import '../models/movie_model.dart';
import '../models/simple_movie_model.dart';

/// Comunicação com as Cloud Functions responsáveis pelo catálogo de conteúdos.
class ContentService {
  ContentService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  final FirebaseFunctions _functions;

  Future<List<SimpleMovie>> getLaunchingContent(int page) async {
    final response = await _call('getLaunchingContent', {'page': page});
    if (response is! Map) {
      throw Exception('O servidor retornou lançamentos em formato inválido.');
    }

    final data = Map<String, dynamic>.from(response);
    final category = data['category']?.toString() ?? 'movie';
    final rawResults = data['results'];
    if (rawResults is! List) {
      throw Exception('O servidor não retornou a lista de lançamentos.');
    }

    return _parseSimpleResults(rawResults, category);
  }

  Future<List<SimpleMovie>> getRandomContent(int page) async {
    final response = await _call('getRandomContent', {'page': page});
    if (response is! List) {
      throw Exception('O servidor retornou conteúdos populares em formato inválido.');
    }

    final results = <SimpleMovie>[];
    for (final rawGroup in response) {
      if (rawGroup is! Map) continue;

      final group = Map<String, dynamic>.from(rawGroup);
      final category = group['category']?.toString() ?? 'movie';
      final rawResults = group['results'];
      if (rawResults is! List) continue;

      results.addAll(_parseSimpleResults(rawResults, category));
    }

    return results;
  }

  /// Busca os detalhes completos de um item resumido do catálogo.
  Future<Movie> getContentDetails(SimpleMovie simpleMovie) async {
    final response = await _call(
      'getContentDetails',
      {
        'id': simpleMovie.id,
        'category': simpleMovie.category,
      },
    );

    if (response is! Map) {
      throw Exception('O servidor retornou detalhes em formato inválido.');
    }

    return Movie.fromApiMap(
      Map<String, dynamic>.from(response),
      category: simpleMovie.category,
    );
  }

  Future<dynamic> _call(
    String functionName,
    Map<String, dynamic> payload,
  ) async {
    try {
      final result =
          await _functions.httpsCallable(functionName).call(payload);
      return result.data;
    } on FirebaseFunctionsException catch (error) {
      switch (error.code) {
        case 'unauthenticated':
          throw Exception('Faça login para consultar o catálogo.');
        case 'unavailable':
          throw Exception(
            'Serviço indisponível. Verifique se os emuladores Firebase estão ativos.',
          );
        case 'not-found':
          throw Exception('A função "$functionName" não foi encontrada.');
        default:
          throw Exception(
            error.message ?? 'Falha ao consultar o catálogo.',
          );
      }
    }
  }

  List<SimpleMovie> _parseSimpleResults(
    List<dynamic> rawResults,
    String category,
  ) {
    final parsed = <SimpleMovie>[];

    for (final rawItem in rawResults) {
      if (rawItem is! Map) continue;

      try {
        parsed.add(
          SimpleMovie.fromMap(
            Map<String, dynamic>.from(rawItem),
            defaultCategory: category,
          ),
        );
      } on FormatException {
        // O backend pode descartar resultados sem pôster ou banner.
        continue;
      }
    }

    return parsed;
  }
}
