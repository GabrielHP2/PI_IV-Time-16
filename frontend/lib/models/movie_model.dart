// Feito por Felipe Batista Bastos - 25005337
// Correções por Luis Felipe Pontes Mita RA - 25018740

class Movie {
  final int id;
  final String title;
  final String? synopsis;
  final String? release_date;
  final double rating;
  final List<String> genre;
  final List<String>? platform;
  final List<Movie> similar;
  final String banner_path;
  final String poster_path;

  Movie ({
    required this.id,
    required this.banner_path,
    required this.poster_path,
    required this.title,
    required this.synopsis,
    required this.release_date,
    required this.rating,
    required this.genre,
    required this.platform,
    required this.similar,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      banner_path: json['banner_path'],
      poster_path: json['poster_path'],
      title: json['title'],
      synopsis: json['synopsis'],
      release_date: json['release_date'],
      rating: json['rating'],
      genre: List<String>.from(json['genre']),
      platform: json['platform'] != null ? List<String>.from(json['platform']) : null,
      similar: List<Movie>.from(json['similar'].map((x) => Movie.fromJson(x))),
    );
  }
}