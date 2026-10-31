import 'package:flutter/material.dart';
import '../widgets/top_search_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/movie_card.dart';
import '../widgets/carousel_slider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopSearchBar(),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Lançamentos'),
              const HomeCarousel(),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Populares'),
              Center(
                child: SizedBox(
                  height: 160,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return MovieCard(
                        hasArrow: index == 4,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Pra você'),
              Center(
                child: SizedBox(
                  height: 160,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return MovieCard(
                        hasArrow: index == 4,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Só na Netflix'),
              Center(
                child: SizedBox(
                  height: 160,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return MovieCard(
                        hasArrow: index == 4,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Só no Disney+'),
              Center(
                child: SizedBox(
                  height: 160,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return MovieCard(
                        hasArrow: index == 4,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}