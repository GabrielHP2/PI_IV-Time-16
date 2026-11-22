// Feito por Felipe Batista Bastos - 25005337
// Correções por Luis Felipe Pontes Mita RA - 25018740

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../components/widgets/primary_button.dart';
import '../../models/movie_model.dart';
import '../../repositories/personalization_repository.dart';
import '../../routes.dart';
import '../../theme/app_theme.dart';

Future<List<Movie>> getCatalogContent(int page) async {
  final callable =
      FirebaseFunctions.instance.httpsCallable('getRandomContent'); // ajuste o nome
  final response = await callable.call({'page': page});

  final data = Map<String, dynamic>.from(response.data);
  final List<dynamic> jsonData = data['results'];

  return jsonData
      .map((json) => Movie.fromJson(Map<String, dynamic>.from(json)))
      .toList();
}

class OngoingContentPage extends StatefulWidget {
  const OngoingContentPage({super.key});

  @override
  State<OngoingContentPage> createState() => _OngoingContentPageState();
}

class _OngoingContentPageState extends State<OngoingContentPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

final ScrollController _scrollController = ScrollController();

List<Movie> _availableContents = [];
bool _isLoading = true;
bool _isLoadingMore = false;
bool _hasMore = true;
String? _error;
int _page = 1;

@override
void initState() {
  super.initState();
  _scrollController.addListener(_onScroll);
  _loadContents();
}

@override
void dispose() {
  _scrollController.dispose();
  _searchController.dispose();
  super.dispose();
}

void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    _loadMore();
  }
}

Future<void> _loadContents() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final movies = await getCatalogContent(1);
    if (!mounted) return;

    setState(() {
      _availableContents = movies;
      _page = 1;
      _hasMore = movies.isNotEmpty;
      _isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;
    debugPrint('Erro ao carregar conteúdos: $e');

    setState(() {
      _error = 'Não foi possível carregar os conteúdos.';
      _isLoading = false;
    });
  }
}

Future<void> _loadMore() async {
  if (_isLoading || _isLoadingMore || !_hasMore || _error != null) return;

  setState(() => _isLoadingMore = true);

  try {
    final movies = await getCatalogContent(_page + 1);
    if (!mounted) return;

    final existingIds = _availableContents.map((m) => m.id).toSet();
    final newMovies =
        movies.where((m) => !existingIds.contains(m.id)).toList();

    setState(() {
      _page++;
      _availableContents = [..._availableContents, ...newMovies];
      _hasMore = newMovies.isNotEmpty;
      _isLoadingMore = false;
    });
  } catch (e) {
    if (!mounted) return;
    debugPrint('Erro ao carregar mais conteúdos: $e');
    setState(() => _isLoadingMore = false);
  }
}

  void _continue() {
    Navigator.pushNamed(context, AppRoutes.desiredContent);
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
              child: Builder(
                builder: (context) {
                  if (_isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_error != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(color: AppColors.onDark),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _loadContents,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ValueListenableBuilder<List<Movie>>(
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
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(22, 2, 22, 12),
                        itemCount: filteredContents.length + (_isLoadingMore ? 1 : 0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          if (index >= filteredContents.length) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final movie = filteredContents[index];
                          final isSelected =
                            selectedContents.any((item) => item.id == movie.id);

                          return _OngoingContentCard(
                            title: movie.title,
                            poster_path: movie.poster_path,
                            isSelected: isSelected,
                            onTap: () {
                              PersonalizationRepository.toggleOngoingContent(movie);
                            },
                          );
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
    required this.poster_path,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String poster_path;
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
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      poster_path,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.movie_outlined, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
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