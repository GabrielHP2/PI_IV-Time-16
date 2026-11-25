// Feito por Felipe Batista Bastos - 25005337

import 'dart:async';

import 'package:flutter/material.dart';

import '../../components/widgets/primary_button.dart';
import '../../models/movie_model.dart';
import '../../repositories/personalization_repository.dart';
import '../../routes.dart';
import '../../services/personalization_service.dart';
import '../../theme/app_theme.dart';

// Etapa para informar quais filmes e séries o usuário já está acompanhando.
class OngoingContentPage extends StatefulWidget {
  const OngoingContentPage({super.key});

  @override
  State<OngoingContentPage> createState() => _OngoingContentPageState();
}

// Gerencia pesquisa, resultados e seleção dos conteúdos em andamento.
class _OngoingContentPageState extends State<OngoingContentPage> {
  final TextEditingController _searchController = TextEditingController();
  final PersonalizationService _personalizationService = PersonalizationService();
  Timer? _searchDebounce;

  List<Movie> _availableContents = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Aguarda uma pausa na digitação antes de realizar outra pesquisa.
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    setState(() {
      _searchQuery = query;
      _errorMessage = null;
      if (query.length < 2) {
        _availableContents = [];
        _isLoading = false;
      } else {
        _isLoading = true;
      }
    });

    if (query.length < 2) return;
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      // Busca conteúdos no serviço e atualiza a lista de resultados da tela.
      _searchContent(query);
    });
  }

  Future<void> _searchContent(String query) async {
    try {
      final results = await _personalizationService.searchContent(query);
      if (!mounted || query != _searchQuery) return;
      setState(() {
        _availableContents = results;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted || query != _searchQuery) return;
      setState(() {
        _availableContents = [];
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // Finaliza a seleção de conteúdos em andamento e avança no fluxo.
  void _continue() {
    Navigator.pushNamed(context, AppRoutes.desiredContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Personalização'),
        leading: BackButton(onPressed: () => Navigator.maybePop(context)),
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
                      onChanged: _onSearchChanged,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(color: AppColors.button, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Buscar filmes e séries',
                        hintStyle: const TextStyle(color: AppColors.button),
                        prefixIcon: const Icon(Icons.search, color: AppColors.button, size: 20),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Limpar busca',
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                                icon: const Icon(Icons.close, color: AppColors.button, size: 18),
                              ),
                        filled: true,
                        fillColor: AppColors.fieldFill,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                          borderSide: const BorderSide(color: AppColors.button, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Movie>>(
                // Consulta e altera a seleção persistida temporariamente durante o fluxo de personalização.
                valueListenable: PersonalizationRepository.ongoingContents,
                builder: (context, selectedContents, child) {
                  if (_isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.onDark),
                        ),
                      ),
                    );
                  }
                  if (_searchQuery.length < 2) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Digite pelo menos 2 caracteres para pesquisar filmes e séries.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.onDark),
                        ),
                      ),
                    );
                  }
                  if (_availableContents.isEmpty) {
                    return const Center(
                      child: Text('Nenhum conteúdo encontrado.', style: TextStyle(color: AppColors.onDark)),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(22, 2, 22, 12),
                    itemCount: _availableContents.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemBuilder: (context, index) {
                      final movie = _availableContents[index];
                      final isSelected = selectedContents.any((item) => item.id == movie.id);
                      return _OngoingContentCard(
                        movie: movie,
                        isSelected: isSelected,
                        onTap: () => PersonalizationRepository.toggleOngoingContent(movie),
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
                        style: const TextStyle(color: AppColors.onDark, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(text: 'Avançar', onPressed: _continue),
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
    required this.movie,
    required this.isSelected,
    required this.onTap,
  });

  final Movie movie;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: movie.title,
      child: Material(
        color: const Color(0xFF4B1B60),
        borderRadius: BorderRadius.circular(13),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
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
              fit: StackFit.expand,
              children: [
                if (movie.imageUrl.isNotEmpty)
                  Image.network(
                    movie.imageUrl,
                    fit: BoxFit.cover,
                    // Apresenta um espaço alternativo caso a imagem do pôster não esteja disponível.
                    errorBuilder: (context, error, stackTrace) => _posterFallback(),
                  )
                else
                  _posterFallback(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 24, 8, 9),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                    child: Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Positioned(
                  top: 7,
                  left: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      movie.category == 'tv' ? 'SÉRIE' : 'FILME',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (isSelected)
                  const Positioned(
                    top: 7,
                    right: 7,
                    child: Icon(Icons.check_circle, color: Colors.white, size: 22),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _posterFallback() {
    return const ColoredBox(
      color: Color(0xFF351343),
      child: Center(child: Icon(Icons.movie_outlined, color: Colors.white70, size: 42)),
    );
  }
}
