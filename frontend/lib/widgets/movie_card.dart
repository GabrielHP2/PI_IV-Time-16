import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MovieCard extends StatelessWidget {
  final double width;
  final double height;
  final bool hasArrow;

  const MovieCard({
    super.key,
    this.width = 120,
    this.height = 160,
    this.hasArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Aqui você pode adicionar lógica de navegação ou ação
        // Ex: Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsScreen(movieTitle: 'Título do Filme')));
      },
      child: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.darkPurple,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          if (hasArrow)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppColors.darkPurple,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}