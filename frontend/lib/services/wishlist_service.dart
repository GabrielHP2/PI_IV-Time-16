import 'package:cloud_functions/cloud_functions.dart';

import '../models/movie_model.dart';

/// Integra a lista de desejos com as Cloud Functions do projeto.
class WishlistService {
  WishlistService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  final FirebaseFunctions _functions;

  Future<void> addToWishlist(Movie movie) async {
    final identity = _getIdentity(movie);
    await _call(
      'addToWishlist',
      <String, dynamic>{
        'id': identity.id,
        'category': identity.category,
      },
    );
  }

  Future<void> removeFromWishlist(Movie movie) async {
    final identity = _getIdentity(movie);
    await _call(
      'removeFromWishlist',
      <String, dynamic>{
        'id': identity.id,
        'category': identity.category,
      },
    );
  }

  Future<List<Movie>> getWishlist() async {
    final response = await _call('getWishlist', <String, dynamic>{});
    if (response is! Map) {
      throw Exception('O servidor retornou uma lista de desejos inválida.');
    }

    final rawWishlist = response['wishlist'];
    if (rawWishlist is! List) {
      throw Exception('O servidor não retornou os conteúdos salvos.');
    }

    final entries = <({int id, String category})>[];
    for (final item in rawWishlist) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final rawId = map['contentId'];
      final category = map['category']?.toString() ?? '';
      if (rawId is num &&
          rawId.toInt() > 0 &&
          (category == 'movie' || category == 'tv')) {
        entries.add((id: rawId.toInt(), category: category));
      }
    }

    final results = await Future.wait(
      entries.map((entry) => _getContentDetails(entry.id, entry.category)),
    );
    return results.whereType<Movie>().toList();
  }

  Future<dynamic> _call(
    String functionName,
    Map<String, dynamic> payload,
  ) async {
    try {
      final result = await _functions.httpsCallable(functionName).call(payload);
      return result.data;
    } on FirebaseFunctionsException catch (error) {
      switch (error.code) {
        case 'unauthenticated':
          throw Exception('Faça login para acessar sua lista de desejos.');
        case 'unavailable':
          throw Exception(
            'Serviço indisponível. Verifique os emuladores Firebase.',
          );
        case 'invalid-argument':
          throw Exception(error.message ?? 'Os dados enviados são inválidos.');
        case 'not-found':
          throw Exception('A função "$functionName" não foi encontrada.');
        default:
          throw Exception(error.message ?? 'Falha ao comunicar com o servidor.');
      }
    }
  }

  Future<Movie?> _getContentDetails(int id, String category) async {
    final response = await _call(
      'getContentDetails',
      <String, dynamic>{'id': id, 'category': category},
    );
    if (response is! Map) return null;

    try {
      return Movie.fromApiMap(
        Map<String, dynamic>.from(response),
        category: category,
      );
    } on FormatException {
      return null;
    }
  }

  ({int id, String category}) _getIdentity(Movie movie) {
    final parts = movie.id.split(':');
    final category = parts.length > 1 ? parts.first : movie.category;
    final idText = parts.length > 1 ? parts.last : movie.id;
    final id = int.tryParse(idText);

    if (id == null ||
        id < 1 ||
        (category != 'movie' && category != 'tv')) {
      throw FormatException(
        'Não foi possível identificar o filme ou série "${movie.title}".',
      );
    }

    return (id: id, category: category);
  }
}
