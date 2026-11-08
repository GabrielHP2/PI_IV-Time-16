import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../theme/app_theme.dart';
import '../../models/movie_model.dart';
import 'detailed_view_page.dart';
import '../../components/widgets/wishlist_card.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data using the Movie model
  final List<Movie> _movies = [
    Movie(id: '1', title: 'Filme 1', synopsis: '...', releaseDate: '2023', rating: 4.5, genre: 'Ação', platforms: ['Netflix'], imageUrl: ''),
    Movie(id: '2', title: 'Filme 2', synopsis: '...', releaseDate: '2023', rating: 4.0, genre: 'Drama', platforms: ['Netflix'], imageUrl: ''),
    Movie(id: '3', title: 'Filme 3', synopsis: '...', releaseDate: '2023', rating: 4.9, genre: 'Comédia', platforms: ['Netflix'], imageUrl: ''),
    Movie(id: '4', title: 'Filme 4', synopsis: '...', releaseDate: '2023', rating: 4.2, genre: 'Terror', platforms: ['Netflix'], imageUrl: ''),
    Movie(id: '5', title: 'Filme 5', synopsis: '...', releaseDate: '2023', rating: 4.7, genre: 'Sci-Fi', platforms: ['Netflix'], imageUrl: ''),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openContent(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DetailedViewPage(
          content: ContentDetail(
            title: movie.title,
            synopsis: movie.synopsis,
            releaseDate: movie.releaseDate,
            rating: movie.rating,
            genre: movie.genre,
            platforms: movie.platforms,
            similarTitles: [],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final filteredMovies = _movies
        .where(
          (movie) =>
              movie.title.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: colors.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      kLogoAsset,
                      width: 36,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar conteúdo',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: AppColors.button,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Notificações',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'O painel de notificações será implementado.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_none,
                      color: AppColors.button,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Minha lista',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredMovies.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum conteúdo encontrado.',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      itemCount: filteredMovies.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemBuilder: (context, index) {
                        final movie = filteredMovies[index];

                        return WishlistCard(
                          movie: movie,
                          onTap: () => _openContent(movie),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colors.surfaceContainerHighest,
        selectedItemColor: AppColors.button,
        unselectedItemColor: AppColors.button,
        currentIndex: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // As telas de destino ainda não foram implementadas.
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF923DB4),
              child: Icon(Icons.bookmark, color: Colors.white),
            ),
            label: 'Minha lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
