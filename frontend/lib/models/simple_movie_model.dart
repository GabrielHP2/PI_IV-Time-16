/// Modelo resumido retornado pelas funções getLaunchingContent e getRandomContent.
///
/// O backend envia apenas ID e caminhos das imagens; a categoria vem no objeto
/// que agrupa os resultados (movie ou tv).
class SimpleMovie {
  const SimpleMovie({
    required this.id,
    required this.bannerPath,
    required this.posterPath,
    required this.category,
  });

  final int id;
  final String bannerPath;
  final String posterPath;
  final String category;

  factory SimpleMovie.fromMap(
    Map<String, dynamic> json, {
    String defaultCategory = 'movie',
  }) {
    final rawId = json['id'];
    final parsedId = rawId is num ? rawId.toInt() : int.tryParse('$rawId');

    if (parsedId == null || parsedId < 1) {
      throw const FormatException('O conteúdo retornado não possui um ID válido.');
    }

    final rawCategory = json['category']?.toString() ?? defaultCategory;
    final category =
        rawCategory == 'tv' ? 'tv' : 'movie';

    return SimpleMovie(
      id: parsedId,
      bannerPath: json['banner_path']?.toString() ?? '',
      posterPath: json['poster_path']?.toString() ?? '',
      category: category,
    );
  }

  String get identity => '$category:$id';

  String imageUrl({bool large = false}) {
    final path = large
        ? (bannerPath.isNotEmpty ? bannerPath : posterPath)
        : (posterPath.isNotEmpty ? posterPath : bannerPath);

    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final size = large ? 'w780' : 'w500';
    return 'https://image.tmdb.org/t/p/$size$path';
  }
}
