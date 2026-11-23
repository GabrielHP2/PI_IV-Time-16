// Feito por Felipe Batista Bastos - 25005337
// Correções por Luis Felipe Pontes Mita RA - 25018740

class SimpleMovie {
  final int id;
  final String banner_path;
  final String poster_path;
  final String category;

  SimpleMovie ({
    required this.id,
    required this.banner_path,
    required this.poster_path,
    required this.category,
  });

  factory SimpleMovie.fromJson(Map<String, dynamic> json) {
    return SimpleMovie(
      id: json['id'],
      banner_path: json['banner_path'],
      poster_path: json['poster_path'],
      category: json['category'],
    );
  }

  String parseMediaType(Map<String, dynamic> json) {
  final category = json['category'];
  if (category == 'tv') return 'tv';
  if (category == 'movie') return 'movie';

  return 'movie'; // padrão, se vier ausente ou com outro valor
}

}