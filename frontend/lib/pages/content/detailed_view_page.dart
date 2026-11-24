import 'package:flutter/material.dart';

import '../../components/widgets/movie_card.dart';
import '../../models/movie_model.dart';
import '../../models/simple_movie_model.dart';
import '../../repositories/wishlist_repository.dart';
import '../../routes.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';

/// Mantido para compatibilidade com chamadas antigas da tela.
class ContentDetail {
  const ContentDetail({
    required this.title,
    required this.synopsis,
    required this.releaseDate,
    required this.rating,
    required this.platforms,
    required this.similarTitles,
    this.genre = 'Não informado',
  });

  final String title;
  final String synopsis;
  final String releaseDate;
  final double rating;
  final List<String> platforms;
  final List<String> similarTitles;
  final String genre;
}

class DetailedViewPage extends StatefulWidget {
  const DetailedViewPage({super.key, this.content});

  final ContentDetail? content;

  @override
  State<DetailedViewPage> createState() => _DetailedViewPageState();
}

class _DetailedViewPageState extends State<DetailedViewPage> {
  final ContentService _contentService = ContentService();

  Movie? _movie;
  bool _isSaving = false;
  bool _isSaved = false;
  bool _initialized = false;

  String get _title => _movie?.title ?? widget.content?.title ?? 'Conteúdo';
  String get _synopsis =>
      _movie?.synopsis ?? widget.content?.synopsis ?? 'Sinopse não disponível.';
  String get _releaseDate =>
      _movie?.releaseDate ?? widget.content?.releaseDate ?? 'Não informado';
  double get _rating =>
      _movie?.rating ?? widget.content?.rating ?? 0.0;
  String get _genre =>
      _movie?.genre ?? widget.content?.genre ?? 'Não informado';
  List<String> get _platforms =>
      _movie?.platforms ?? widget.content?.platforms ?? const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Movie) {
      _movie = arguments;
    } else if (widget.content != null) {
      final content = widget.content!;
      _movie = Movie(
        // Conteúdos legados sem ID real não poderão ser enviados à Wishlist.
        id: 'legacy:${content.title}',
        title: content.title,
        synopsis: content.synopsis,
        releaseDate: content.releaseDate,
        rating: content.rating,
        genre: content.genre,
        platforms: content.platforms,
        imageUrl: '',
      );
    }

    _initialized = true;
    if (_movie != null) {
      _loadSavedState();
    }
  }

  Future<void> _loadSavedState() async {
    try {
      await WishlistRepository.load();
      final movie = _movie;
      if (mounted && movie != null) {
        setState(() {
          _isSaved = WishlistRepository.contains(movie.id);
        });
      }
    } catch (_) {
      // A tela continua acessível; uma falha será exibida ao salvar/remover.
    }
  }

  Future<void> _toggleWishlist() async {
    final movie = _movie;
    if (movie == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      await WishlistRepository.toggle(movie);
      if (!mounted) return;

      setState(() {
        _isSaved = WishlistRepository.contains(movie.id);
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _isSaved
                  ? 'Adicionado à sua lista!'
                  : 'Removido da sua lista!',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _openSimilar(SimpleMovie simpleMovie) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final movie = await _contentService.getContentDetails(simpleMovie);
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushNamed(
        context,
        AppRoutes.detailedView,
        arguments: movie,
      );
    } catch (error) {
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void _onNavigationTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.wishlist);
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
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
    final movie = _movie;
    final similar = movie?.similarContents ?? const <SimpleMovie>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão detalhada'),
        leading: BackButton(
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 112,
                    height: 160,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: movie != null && movie.imageUrl.isNotEmpty
                        ? Image.network(
                            movie.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _posterPlaceholder(colors),
                          )
                        : _posterPlaceholder(colors),
                  ),
                  IconButton(
                    tooltip: _isSaved
                        ? 'Remover da lista de desejos'
                        : 'Adicionar à lista de desejos',
                    onPressed: _isSaving ? null : _toggleWishlist,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          ),
                    color: colors.onPrimaryContainer,
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lançamento: ${_releaseDate.isEmpty ? 'Não informado' : _releaseDate}',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.button),
                        const SizedBox(width: 4),
                        Text(
                          '${_rating.toStringAsFixed(1)}/10',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Gênero: $_genre', style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Sinopse',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(_synopsis, style: textTheme.bodyMedium),
          const SizedBox(height: 22),
          Text(
            'Plataformas disponíveis',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (_platforms.isEmpty)
            const Text('Nenhuma plataforma disponível no momento.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _platforms
                  .map(
                    (platform) => Chip(
                      label: Text(platform),
                      backgroundColor: colors.secondaryContainer,
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 22),
          Text(
            'Filmes e séries similares',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (similar.isEmpty)
            const Text('Nenhum conteúdo similar encontrado.')
          else
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: similar.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = similar[index];
                  return SimpleMovieCard(
                    movie: item,
                    onTap: () => _openSimilar(item),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: AppColors.button,
        unselectedItemColor: Colors.grey,
        onTap: _onNavigationTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
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

  Widget _posterPlaceholder(ColorScheme colors) {
    return Center(
      child: Icon(
        Icons.movie_outlined,
        color: colors.onPrimaryContainer,
        size: 42,
      ),
    );
  }
}
