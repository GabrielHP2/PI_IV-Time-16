// Feito por Felipe Batista Bastos - 25005337
// Correções por Luis Felipe Pontes Mita RA - 25018740

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/movie_model.dart';
import '../../components/widgets/content_card.dart';
import '../../repositories/wishlist_repository.dart';
import '../../routes.dart';

class ContentDetail {
  const ContentDetail({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.releaseDate,
    required this.rating,
    required this.platforms,
    this.similar = const [],
    this.genre = 'Não informado',
  });

  final int id;
  final String title;
  final String synopsis;
  final String releaseDate;
  final double rating;
  final List<String> platforms;
  final List<Movie> similar;
  final String genre;
}

class DetailedViewPage extends StatefulWidget {
  const DetailedViewPage({super.key, this.content});

  final ContentDetail? content;

  @override
  State<DetailedViewPage> createState() => _DetailedViewPageState();
}

class _DetailedViewPageState extends State<DetailedViewPage> {
  bool isSaved = false;
  late ContentDetail _content;
  bool _contentInitialized = false;
  Movie? _movie;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_contentInitialized) return;

    if (widget.content != null) {
      final c = widget.content!;
      _content = c;

      _movie = Movie(
        id: c.id,
        banner_path: '',
        poster_path: '',
        title: c.title,
        synopsis: c.synopsis,
        release_date: c.releaseDate,
        rating: c.rating,
        genre: c.genre == 'Não informado' ? [] : [c.genre],
        platform: c.platforms,
        similar: c.similar,
      );
    } else {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is Movie) {
        _movie = args;
        _content = ContentDetail(
          id: args.id,
          title: args.title,
          synopsis: args.synopsis ?? 'Sinopse não disponível.',
          releaseDate: args.release_date ?? 'Não informado',
          rating: args.rating,
          genre: args.genre.isEmpty ? 'Não informado' : args.genre.join(', '),
          platforms: args.platform ?? const [],
          similar: args.similar,
        );
      }
}

    // O marcador começa de acordo com o estado real da lista compartilhada.
    if (_movie != null) {
      isSaved = WishlistRepository.contains(_movie!.id);
    }

    _contentInitialized = true;
  }

  void _toggleWishlist() {
    final movie = _movie;

    if (movie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar este conteúdo.'),
        ),
      );
      return;
    }

    setState(() {
      WishlistRepository.toggle(movie);
      isSaved = WishlistRepository.contains(movie.id);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isSaved
                ? 'Adicionado à sua lista!'
                : 'Removido da sua lista!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
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
                    child: Icon(
                      Icons.movie_outlined,
                      color: colors.onPrimaryContainer,
                      size: 42,
                    ),
                  ),
                  IconButton(
                    tooltip: isSaved
                        ? 'Remover da lista de desejos'
                        : 'Adicionar à lista de desejos',
                    onPressed: _toggleWishlist,
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
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
                      _content.title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lançamento: ${_content.releaseDate}',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.button,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_content.rating}/5',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gênero: ${_content.genre}',
                      style: textTheme.bodyMedium,
                    ),
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
          Text(_content.synopsis, style: textTheme.bodyMedium),
          const SizedBox(height: 22),
          Text(
            'Plataformas disponíveis',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _content.platforms
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
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _content.similar.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final similar = _content.similar[index];

                return ContentCard(
                  movie: similar,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.detailedView,
                    arguments: similar,
                  ),
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
}
