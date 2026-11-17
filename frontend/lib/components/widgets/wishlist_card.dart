import 'package:flutter/material.dart';
import '../../models/movie_model.dart';

class WishlistCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const WishlistCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: movie.imageUrl.isNotEmpty
                  ? Image.network(movie.imageUrl, fit: BoxFit.cover, width: double.infinity)
                  : Container(
                      color: colors.primary,
                      child: Icon(Icons.movie, color: colors.onPrimary, size: 32),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
