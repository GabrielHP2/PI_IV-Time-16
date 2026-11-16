
// Adições e modificações por Felipe Batista Bastos - 25005337

class Movie {
  final String id;
  final String title;
  final String synopsis;
  final String releaseDate;
  final double rating;
  final String genre;
  final List<String> platforms;
  final String imageUrl;

  const Movie({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.releaseDate,
    required this.rating,
    required this.genre,
    required this.platforms,
    required this.imageUrl,
  });

  factory Movie.example() => const Movie(
        id: '1',
        title: 'Exemplo de Filme',
        synopsis: 'Esta é uma sinopse de exemplo para o filme.',
        releaseDate: '15/07/2021',
        rating: 4.8,
        genre: 'Drama',
        platforms: ['Netflix'],
        imageUrl: 'https://via.placeholder.com/150',
      );
}
