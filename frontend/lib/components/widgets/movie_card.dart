import 'package:flutter/material.dart';

import '../../models/movie_model.dart';
import '../../models/simple_movie_model.dart';

/// Card usado pela Main Page, que recebe apenas ID e imagens da API.
class SimpleMovieCard extends StatelessWidget {
  const SimpleMovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.isLarge = false,
  });

  final SimpleMovie movie;
  final VoidCallback onTap;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final imageUrl = movie.imageUrl(large: isLarge);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isLarge ? 300 : 140,
        height: isLarge ? 200 : 180,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imageUrl.isEmpty
              ? _placeholder(colors)
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      _placeholder(colors),
                ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      color: colors.primaryContainer,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          color: colors.onPrimaryContainer,
          size: 36,
        ),
      ),
    );
  }
}

/// Mantido para telas que exibem um Movie completo.
class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.isLarge = false,
  });

  final Movie movie;
  final VoidCallback onTap;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isLarge ? 300 : 140,
        height: isLarge ? 200 : 180,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (movie.imageUrl.isNotEmpty)
                Image.network(
                  movie.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _placeholder(colors),
                )
              else
                _placeholder(colors),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      color: colors.primaryContainer,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          color: colors.onPrimaryContainer,
          size: 36,
        ),
      ),
    );
  }
}
