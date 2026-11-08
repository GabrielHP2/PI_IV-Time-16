import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../components/widgets/movie_card.dart';
import '../../theme/app_theme.dart';
import '../../routes.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  final List<Movie> lancamentos = const [
    Movie(id: '1', title: 'Filme 1', synopsis: '...', releaseDate: '2023', rating: 4.5, genre: 'Ação', platforms: ['Netflix'], imageUrl: ''),
    Movie(id: '2', title: 'Filme 2', synopsis: '...', releaseDate: '2023', rating: 4.0, genre: 'Drama', platforms: ['Netflix'], imageUrl: ''),
    Movie(id: '3', title: 'Filme 3', synopsis: '...', releaseDate: '2023', rating: 4.9, genre: 'Comédia', platforms: ['Netflix'], imageUrl: ''),
    Movie(id: '4', title: 'Filme 4', synopsis: '...', releaseDate: '2023', rating: 4.2, genre: 'Terror', platforms: ['Netflix'], imageUrl: ''),
    Movie(id: '5', title: 'Filme 5', synopsis: '...', releaseDate: '2023', rating: 4.7, genre: 'Sci-Fi', platforms: ['Netflix'], imageUrl: ''),
  ];

  final List<Movie> praVoce = const [
    Movie(id: '6', title: 'Filme 6', synopsis: '...', releaseDate: '2022', rating: 4.0, genre: 'Drama', platforms: ['Netflix'], imageUrl: ''),
    Movie(id: '7', title: 'Filme 7', synopsis: '...', releaseDate: '2022', rating: 3.8, genre: 'Ação', platforms: ['Netflix'], imageUrl: ''),
    Movie(id: '8', title: 'Filme 8', synopsis: '...', releaseDate: '2022', rating: 4.1, genre: 'Comédia', platforms: ['Netflix'], imageUrl: ''),
    Movie(id: '9', title: 'Filme 9', synopsis: '...', releaseDate: '2022', rating: 4.3, genre: 'Terror', platforms: ['Netflix'], imageUrl: ''),
  ];

  final List<Movie> soNaNetflix = const [
    Movie(id: '10', title: 'Netflix Original', synopsis: '...', releaseDate: '2023', rating: 4.5, genre: 'Drama', platforms: ['Netflix'], imageUrl: ''),
    Movie(id: '11', title: 'Netflix Original 2', synopsis: '...', releaseDate: '2023', rating: 4.2, genre: 'Ação', platforms: ['Netflix'], imageUrl: ''),
    Movie(id: '12', title: 'Netflix Original 3', synopsis: '...', releaseDate: '2023', rating: 4.6, genre: 'Sci-Fi', platforms: ['Netflix'], imageUrl: ''),
  ];

  final List<Movie> soNoDisney = const [
    Movie(id: '13', title: 'Disney Plus 1', synopsis: '...', releaseDate: '2023', rating: 4.8, genre: 'Ficção', platforms: ['Disney+'], imageUrl: ''),
    Movie(id: '14', title: 'Disney Plus 2', synopsis: '...', releaseDate: '2023', rating: 4.4, genre: 'Animação', platforms: ['Disney+'], imageUrl: ''),
    Movie(id: '15', title: 'Disney Plus 3', synopsis: '...', releaseDate: '2023', rating: 4.7, genre: 'Drama', platforms: ['Disney+'], imageUrl: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mainpage'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Lançamentos',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            _buildCarousel(),
            const SizedBox(height: 32),
            _buildSectionTitle('Pra você'),
            const SizedBox(height: 16),
            _buildHorizontalList(praVoce),
            const SizedBox(height: 32),
            _buildSectionTitle('Só na Netflix'),
            const SizedBox(height: 16),
            _buildHorizontalList(soNaNetflix),
            const SizedBox(height: 32),
            _buildSectionTitle('Só no Disney+'),
            const SizedBox(height: 16),
            _buildHorizontalList(soNoDisney),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.button,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {},
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Minha lista'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            itemCount: lancamentos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MovieCard(
                  movie: lancamentos[index],
                  isLarge: true,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.detailedView, arguments: lancamentos[index]);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(lancamentos.length, (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: index == 0 ? Colors.white : Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHorizontalList(List<Movie> movies) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: MovieCard(
              movie: movies[index],
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.detailedView, arguments: movies[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
