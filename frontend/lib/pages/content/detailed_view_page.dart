import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

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

  static const example = ContentDetail(
    title: 'Filme',
    synopsis: 'Uma breve sinopse do filme ou da série selecionada.',
    releaseDate: '15/07/2016',
    rating: 4.5,
    genre: 'Drama',
    platforms: ['Netflix'],
    similarTitles: ['Filme 1', 'Filme 2', 'Filme 3'],
  );
}

class DetailedViewPage extends StatefulWidget {
  const DetailedViewPage({super.key, this.content});

  final ContentDetail? content;

  @override
  State<DetailedViewPage> createState() => _DetailedViewPageState();
}

class _DetailedViewPageState extends State<DetailedViewPage> {
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    final content = widget.content ?? ContentDetail.example;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão detalhada'),
        leading: BackButton(onPressed: () => Navigator.maybePop(context)),
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
                    onPressed: () => setState(() => isSaved = !isSaved),
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
                    Text(content.title, style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Lançamento: ${content.releaseDate}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.button),
                        const SizedBox(width: 4),
                        Text('${content.rating}/5'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Gênero: ${content.genre}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Sinopse', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(content.synopsis),
          const SizedBox(height: 22),
          Text('Plataformas disponíveis', style: textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: content.platforms
                .map((platform) => Chip(label: Text(platform)))
                .toList(),
          ),
          const SizedBox(height: 22),
          Text('Filmes e séries similares', style: textTheme.titleMedium),
          const SizedBox(height: 10),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: content.similarTitles.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => Container(
                width: 130,
                padding: const EdgeInsets.all(12),
                alignment: Alignment.bottomLeft,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  content.similarTitles[index],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.onPrimaryContainer),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: AppColors.button,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // As telas de destino ainda não foram implementadas.
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Minha lista',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}