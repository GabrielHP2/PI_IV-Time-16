import 'package:flutter/material.dart';

import '../../components/widgets/primary_button.dart';
import '../../models/movie_model.dart';
import '../../repositories/personalization_repository.dart';
import '../../routes.dart';
import '../../theme/app_theme.dart';

class DesiredContentPage extends StatefulWidget {
  const DesiredContentPage({super.key});

  @override
  State<DesiredContentPage> createState() => _DesiredContentPageState();
}

class _DesiredContentPageState extends State<DesiredContentPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Conteúdo provisório até a integração com o catálogo/backend.
  // Os IDs são diferentes dos usados na tela de conteúdos em andamento,
  // pois as duas seleções representam informações distintas.
  static const List<Movie> _availableContents = [
    Movie(
      id: 'desired-1',
      title: 'Conteúdo 1',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'desired-2',
      title: 'Conteúdo 2',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'desired-3',
      title: 'Conteúdo 3',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'desired-4',
      title: 'Conteúdo 4',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'desired-5',
      title: 'Conteúdo 5',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'desired-6',
      title: 'Conteúdo 6',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'desired-7',
      title: 'Conteúdo 7',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'desired-8',
      title: 'Conteúdo 8',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'desired-9',
      title: 'Conteúdo 9',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'desired-10',
      title: 'Conteúdo 10',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'desired-11',
      title: 'Conteúdo 11',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'desired-12',
      title: 'Conteúdo 12',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.pushNamed(context, AppRoutes.currentSpend);
  }

  @override
  Widget build(BuildContext context) {
    final filteredContents = _availableContents.where((movie) {
      return movie.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Personalização'),
        leading: BackButton(
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
              child: Column(
                children: [
                  const Text(
                    'Quais filmes e séries você gostaria de assistir?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.onDark,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value.trim());
                      },
                      style: const TextStyle(
                        color: AppColors.button,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar',
                        hintStyle: const TextStyle(color: AppColors.button),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.button,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: AppColors.fieldFill,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.button,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Movie>>(
                valueListenable: PersonalizationRepository.desiredContents,
                builder: (context, selectedContents, child) {
                  if (filteredContents.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum conteúdo encontrado.',
                        style: TextStyle(color: AppColors.onDark),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(22, 2, 22, 12),
                    itemCount: filteredContents.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final movie = filteredContents[index];
                      final isSelected = selectedContents.any(
                        (item) => item.id == movie.id,
                      );

                      return _DesiredContentCard(
                        title: movie.title,
                        isSelected: isSelected,
                        onTap: () {
                          PersonalizationRepository.toggleDesiredContent(movie);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ValueListenableBuilder<List<Movie>>(
                valueListenable: PersonalizationRepository.desiredContents,
                builder: (context, selectedContents, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedContents.isEmpty
                            ? 'Selecione os conteúdos que gostaria de assistir.'
                            : '${selectedContents.length} conteúdo(s) selecionado(s)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.onDark,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        text: 'Avançar',
                        onPressed: _continue,
                      ),
                    ],
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

class _DesiredContentCard extends StatelessWidget {
  const _DesiredContentCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: title,
      child: Material(
        color: const Color(0xFF4B1B60),
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFF4B1B60),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: Stack(
              children: [
                if (isSelected)
                  const Positioned(
                    top: 7,
                    right: 7,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
