import 'package:flutter/material.dart';
import '../widgets/top_search_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/movie_card.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TopSearchBar(),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Minha lista'),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return const MovieCard(
                    width: double.infinity,
                    height: double.infinity,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
