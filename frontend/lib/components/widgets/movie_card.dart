import 'package:flutter/material.dart';
import '../../models/movie_model.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isLarge;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    this.isLarge = false,
    required this.onTap,
  });

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
            children: [
              // Placeholder for image
              Container(
                color: colors.primaryContainer,
                child: const Center(
                  child: Icon(Icons.movie, color: Colors.white),
                ),
              ),
              // Text Overlay
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 4, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
