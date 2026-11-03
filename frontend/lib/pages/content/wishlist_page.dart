
import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_theme.dart';
import 'detailed_view_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Conteúdos provisórios até a integração com o catálogo.
  final List<String> _contents = List.generate(
    9,
    (index) => 'Conteúdo ${index + 1}',
  );

  static const _backgroundColor = Color(0xFFD77AF0);
  static const _headerColor = Color(0xFFF7B0F5);
  static const _cardColor = Color(0xFF873DA8);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openContent(String title) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DetailedViewPage(
          content: ContentDetail(
            title: title,
            synopsis: 'Sinopse do conteúdo selecionado.',
            releaseDate: 'Não informado',
            rating: 0.0,
            platforms: const [],
            similarTitles: const [],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filteredContents = _contents
        .where(
          (title) =>
              title.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: _headerColor,
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
              child: filteredContents.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum conteúdo encontrado.',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      itemCount: filteredContents.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemBuilder: (context, index) {
                        final title = filteredContents[index];

                        return Tooltip(
                          message: title,
                          child: InkWell(
                            onTap: () => _openContent(title),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _cardColor,
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _headerColor,
        selectedItemColor: AppColors.button,
        unselectedItemColor: AppColors.button,
        currentIndex: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // As telas Início e Perfil ainda não foram implementadas.
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
            icon: Icon(Icons.home_outlined),
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
