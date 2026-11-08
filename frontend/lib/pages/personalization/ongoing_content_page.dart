import 'package:flutter/material.dart';

import '../../components/widgets/primary_button.dart';
import '../../models/movie_model.dart';
import '../../repositories/personalization_repository.dart';
import '../../theme/app_theme.dart';

class OngoingContentPage extends StatefulWidget {
  const OngoingContentPage({super.key});

  @override
  State<OngoingContentPage> createState() => _OngoingContentPageState();
}

class _OngoingContentPageState extends State<OngoingContentPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Conteúdo provisório para montar a interface enquanto o catálogo não é
  // carregado pelo backend. Os dados seguem o mesmo modelo Movie do projeto.
  static const List<Movie> _availableContents = [
    Movie(
      id: 'ongoing-1',
      title: 'Conteúdo 1',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'ongoing-2',
      title: 'Conteúdo 2',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'ongoing-3',
      title: 'Conteúdo 3',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'ongoing-4',
      title: 'Conteúdo 4',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'ongoing-5',
      title: 'Conteúdo 5',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'ongoing-6',
      title: 'Conteúdo 6',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'ongoing-7',
      title: 'Conteúdo 7',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'ongoing-8',
      title: 'Conteúdo 8',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'ongoing-9',
      title: 'Conteúdo 9',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'ongoing-10',
      title: 'Conteúdo 10',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'ongoing-11',
      title: 'Conteúdo 11',
      synopsis: '',
      releaseDate: '',
      rating: 0,
      genre: 'Não informado',
      platforms: [],
      imageUrl: '',
    ),
    Movie(
      id: 'ongoing-12',
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
    final selectedCount = PersonalizationRepository.ongoingContents.value.length;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            selectedCount == 1
                ? '1 conteúdo selecionado.'
                : '$selectedCount conteúdos selecionados.',
          ),
        ),
      );
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
                    'Quais filmes e séries você está assistindo atualmente?',
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
                valueListenable: PersonalizationRepository.ongoingContents,
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

                      return _OngoingContentCard(
                        title: movie.title,
                        isSelected: isSelected,
                        onTap: () {
                          PersonalizationRepository.toggleOngoingContent(movie);
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
                valueListenable: PersonalizationRepository.ongoingContents,
                builder: (context, selectedContents, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedContents.isEmpty
                            ? 'Selecione os conteúdos que está assistindo.'
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

class _OngoingContentCard extends StatelessWidget {
  const _OngoingContentCard({
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
