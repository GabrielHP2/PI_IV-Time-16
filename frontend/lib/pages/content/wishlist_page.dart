// Feito por Felipe Batista Bastos - 25005337

import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_theme.dart';
import '../../models/movie_model.dart';
import '../../components/widgets/wishlist_card.dart';
import '../../repositories/wishlist_repository.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openContent(Movie movie) {
    Navigator.pushNamed(
      context,
      AppRoutes.detailedView,
      arguments: movie,
    );
  }

  void _onNavigationTap(int index) {
    switch (index) {
      case 0:
        // Já estamos na Minha Lista.
        break;

      case 1:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
        );
        break;

      case 2:
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho
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

                  // Pesquisa
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar conteúdo',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: AppColors.button,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Notificações
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

            // Título
            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                22,
                18,
                12,
              ),
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

            // Conteúdos salvos
            Expanded(
              child: ValueListenableBuilder<List<Movie>>(
                valueListenable: WishlistRepository.items,
                builder: (context, movies, child) {
                  final filteredMovies = movies.where((movie) {
                    return movie.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
                  }).toList();

                  if (movies.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 64,
                              color: Colors.white70,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Sua lista está vazia.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Adicione filmes e séries que deseja assistir.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (filteredMovies.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum conteúdo encontrado.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      0,
                      12,
                      12,
                    ),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colors.surfaceContainerHighest,
        selectedItemColor: AppColors.button,
        unselectedItemColor: AppColors.button,
        currentIndex: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavigationTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF923DB4),
              child: Icon(
                Icons.bookmark,
                color: Colors.white,
              ),
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
