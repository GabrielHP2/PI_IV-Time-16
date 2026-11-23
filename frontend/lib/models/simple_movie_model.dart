// Feito por Felipe Batista Bastos - 25005337
// Correções por Luis Felipe Pontes Mita RA - 25018740

class SimpleMovie {
  final int id;
  final String banner_path;
  final String poster_path;

  SimpleMovie ({
    required this.id,
    required this.banner_path,
    required this.poster_path,
  });

  factory SimpleMovie.fromJson(Map<String, dynamic> json) {
    return SimpleMovie(
      id: json['id'],
      banner_path: json['banner_path'],
      poster_path: json['poster_path'],
    );
  }
}