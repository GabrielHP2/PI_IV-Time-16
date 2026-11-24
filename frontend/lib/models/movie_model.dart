import 'simple_movie_model.dart';

/// Modelo completo utilizado pelas telas de detalhes, personalização e Wishlist.
///
/// O ID é textual e inclui a categoria, por exemplo "movie:123" ou "tv:123".
/// Esse formato evita colisões entre IDs de filmes e séries e é utilizado
/// pelos serviços de Wishlist e planejamento.
class Movie {
  final String id;
  final String title;
  final String synopsis;
  final String releaseDate;
  final double rating;
  final String genre;
  final List<String> platforms;
  final String imageUrl;
  final String category;
  final List<SimpleMovie> similarContents;

  const Movie({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.releaseDate,
    required this.rating,
    required this.genre,
    required this.platforms,
    required this.imageUrl,
    this.category = 'movie',
    this.similarContents = const [],
  });

  /// Converte o formato DetailedContentType retornado por getContentDetails.
  factory Movie.fromApiMap(
    Map<String, dynamic> json, {
    required String category,
  }) {
    if (category != 'movie' && category != 'tv') {
      throw const FormatException('Categoria de conteúdo inválida.');
    }

    final rawId = json['id'];
    final contentId =
        rawId is num ? rawId.toInt() : int.tryParse('$rawId');

    if (contentId == null || contentId < 1) {
      throw const FormatException('O conteúdo retornado não possui um ID válido.');
    }

    final title =
        (json['title'] ?? json['name'] ?? '').toString().trim();
    if (title.isEmpty) {
      throw const FormatException('O conteúdo retornado não possui título.');
    }

    final rawGenres = json['genre'];
    final genres = rawGenres is List
        ? rawGenres
            .map((item) => item.toString())
            .where((item) => item.isNotEmpty)
            .toList()
        : <String>[];

    final rawPlatforms = json['platform'];
    final platforms = rawPlatforms is List
        ? rawPlatforms.map((item) {
            if (item is Map) {
              return item['name']?.toString() ?? '';
            }
            return item.toString();
          }).where((name) => name.isNotEmpty).toList()
        : <String>[];

    final rawSimilar = json['similar'];
    final similar = <SimpleMovie>[];
    if (rawSimilar is List) {
      for (final item in rawSimilar) {
        if (item is! Map) continue;
        try {
          similar.add(
            SimpleMovie.fromMap(
              Map<String, dynamic>.from(item),
              defaultCategory: category,
            ),
          );
        } on FormatException {
          // Ignora apenas recomendações com dados incompletos.
        }
      }
    }

    final posterPath = (json['poster_path'] ?? json['banner_path'] ?? '')
        .toString();
    final imageUrl = posterPath.isEmpty
        ? ''
        : (posterPath.startsWith('http://') ||
                posterPath.startsWith('https://')
            ? posterPath
            : 'https://image.tmdb.org/t/p/w500$posterPath');

    final rawRating = json['rating'] ?? json['vote_average'];
    final rating = rawRating is num
        ? rawRating.toDouble()
        : double.tryParse('$rawRating') ?? 0.0;

    return Movie(
      id: '$category:$contentId',
      title: title,
      synopsis: json['synopsis']?.toString() ?? '',
      releaseDate: (json['release_date'] ??
              json['first_air_date'] ??
              '')
          .toString(),
      rating: rating,
      genre: genres.join(', '),
      platforms: platforms,
      imageUrl: imageUrl,
      category: category,
      similarContents: similar,
    );
  }

  factory Movie.example() => const Movie(
        id: 'movie:1',
        title: 'Exemplo de Filme',
        synopsis: 'Esta é uma sinopse de exemplo para o filme.',
        releaseDate: '15/07/2021',
        rating: 4.8,
        genre: 'Drama',
        platforms: ['Netflix'],
        imageUrl: 'https://via.placeholder.com/150',
      );
}
