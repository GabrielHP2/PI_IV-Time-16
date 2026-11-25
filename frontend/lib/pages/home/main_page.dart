// Adições e modificações por Felipe Batista Bastos - 25005337
// Correções por Luis Felipe Pontes Mita RA - 25018740

import 'dart:math' as math;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../repositories/content_repository.dart';
import '../../models/simple_movie_model.dart';
import '../../models/movie_model.dart';
import '../../components/widgets/movie_card.dart';
import '../../components/widgets/notification_panel.dart';
import '../../theme/app_theme.dart';
import '../../models/app_notification.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/personalization_repository.dart';
import '../../routes.dart';

Future<Movie> getMovieDetails(SimpleMovie simple) async {
  final callable = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  ).httpsCallable('getMovieDetails'); // ajuste o nome, se for outro

  final response = await callable.call({
    'id': simple.id,
    'category': simple.category, // ou 'type', conforme o backend espera
  });

  final json = Map<String, dynamic>.from(response.data as Map);
  json['category'] ??= simple.category; // antes: 'media_type'

  return Movie.fromJson(json);
}

Future<List<SimpleMovie>> getLaunchingContent(int page) async {
  final callable = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  ).httpsCallable('getLaunchingContent');

  final response = await callable.call({'page': page});
  final data = Map<String, dynamic>.from(response.data as Map);
  final results = List<dynamic>.from(data['results'] as List);

  return results.map((json) {
    final item = Map<String, dynamic>.from(json as Map);
    item['category'] = data['category'];
    return SimpleMovie.fromJson(item);
  }).toList();
}

Future<List<SimpleMovie>> getRandomContent(int page) async {
  final callable = FirebaseFunctions.instanceFor(region: "southamerica-east1").httpsCallable('getRandomContent');
  final response = await callable.call({'page': page});

  final List<dynamic> groups = response.data as List<dynamic>;
  final List<SimpleMovie> randomContent = [];

  for (final group in groups) {
    // Cada grupo (movie ou tv) pode ser um mapa com 'results' ou uma lista direta.
    final List<dynamic> items = group is Map
        ? (group['results'] as List<dynamic>)
        : group as List<dynamic>;

    for (final json in items) {
      final item = Map<String, dynamic>.from(json);
      if (group is Map) {
        item['category'] = group['category'];
      }
      randomContent.add(SimpleMovie.fromJson(item));
    }
  }

  return randomContent;
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();
  final ScrollController _popularesController = ScrollController();
  int _currentLaunch = 0;

  List<SimpleMovie> lancamentos = [];
  List<SimpleMovie> populares = [];
  bool isLoading = true;

  int _launchPage = 1;
  int _popularPage = 1;
  bool _loadingLaunch = false;
  bool _loadingPopular = false;
  
  
  Future<void> carregarFilmes(int page) async {
    try {
      final resultados = await Future.wait<List<SimpleMovie>>([
        getLaunchingContent(page),
        getRandomContent(page),
      ]);

      if (!mounted) return;

      setState(() {
        lancamentos = resultados[0];
        populares = resultados[1];
        _launchPage = page;
        _popularPage = page;
        _currentLaunch = 0;
        isLoading = false;
      });

      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }

    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint('Erro ao carregar filmes: $e');
    }
  }

  Future<void> _mudarPaginaLancamentos(int delta) async {
    if (_loadingLaunch) return;

    // delta = +1 (próxima) ou -1 (anterior); cicla entre 1 e 5.
    final nova = (_launchPage - 1 + delta) % 5 + 1;

    setState(() => _loadingLaunch = true);

    try {
      final novos = await getLaunchingContent(nova);
      if (!mounted) return;

      setState(() {
        lancamentos = novos;
        _launchPage = nova;
        _currentLaunch = 0;
        _loadingLaunch = false;
      });

      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    } catch (e) {
      debugPrint('Erro ao carregar lançamentos (página $nova): $e');
      if (!mounted) return;

      setState(() => _loadingLaunch = false);
      _showPendingMessage('Não foi possível carregar os lançamentos.');
    }
  }

  Future<void> _mudarPaginaPopulares(int delta) async {
    if (_loadingPopular) return;

    final nova = (_popularPage - 1 + delta) % 5 + 1;

    setState(() => _loadingPopular = true);

    try {
      final novos = await getRandomContent(nova);
      if (!mounted) return;

      setState(() {
        populares = novos;
        _popularPage = nova;
        _loadingPopular = false;
      });

      if (_popularesController.hasClients) {
        _popularesController.jumpTo(0);
      }
    } catch (e) {
      debugPrint('Erro ao carregar populares (página $nova): $e');
      if (!mounted) return;

    setState(() => _loadingPopular = false);
      _showPendingMessage('Não foi possível carregar os populares.');
    }
  }

  Widget _buildArrow({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    carregarFilmes(1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _popularesController.dispose();
    super.dispose(); 
  }

  void _showPendingMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

Future<void> _openMovie(SimpleMovie simple) async {
  // Indicador de carregamento; também impede toques repetidos.
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
      final movie = await ContentRepository.getMovieDetails(simple);
    if (!mounted) return;

    Navigator.pop(context); // fecha o carregamento
    Navigator.pushNamed(
      context,
      AppRoutes.detailedView,
      arguments: movie, // agora é um Movie completo
    );
  } catch (e) {
    debugPrint('Erro ao carregar detalhes: $e');
    if (!mounted) return;

    Navigator.pop(context); // fecha o carregamento
    _showPendingMessage('Não foi possível carregar os detalhes.');
  }
}

  void _showNotifications() {
    final screenSize = MediaQuery.of(context).size;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar painel de notificações',
      barrierColor: Colors.black.withValues(alpha: 0.08),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: kToolbarHeight + 8,
                right: 12,
                child: NotificationPanel(
                  platforms:
                      PersonalizationRepository.subscribedPlatforms.value,
                  onClose: () => Navigator.of(dialogContext).pop(),
                  width: math.min(
                    340.0,
                    math.max(210.0, screenSize.width * 0.68),
                  ),
                  maxHeight: math.min(360.0, screenSize.height * 0.48),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.04),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildNotificationAction() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: PersonalizationRepository.subscribedPlatforms,
      builder: (context, platforms, child) {
        return ValueListenableBuilder<List<AppNotification>>(
          valueListenable: NotificationRepository.items,
          builder: (context, notifications, child) {
            final subscribedPlatforms = platforms.toSet();
            final hasUnread = notifications.any(
              (notification) =>
                  subscribedPlatforms.contains(notification.platform) &&
                  !notification.isRead,
            );

            return IconButton(
              tooltip: 'Notificações',
              onPressed: _showNotifications,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications),
                  if (hasUnread)
                    Positioned(
                      top: -1,
                      right: -2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE21D3D),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onNavigationTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.wishlist);
        break;
      case 1:
        // Já estamos na página inicial.
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mainpage'),
        actions: [
          IconButton(
            tooltip: 'Pesquisar',
            onPressed: () {
              _showPendingMessage('A pesquisa será implementada.');
            },
            icon: const Icon(Icons.search),
          ),
          _buildNotificationAction(),
        ],
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Lançamentos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCarousel(),
                const SizedBox(height: 32),
                _buildSectionTitle('Populares'),
                const SizedBox(height: 16),
                _buildHorizontalList(populares),
              ],
            ),
          ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.button,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
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

  Widget _buildCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: lancamentos.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentLaunch = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SimpleMovieCard(
                      movie: lancamentos[index],
                      isLarge: true,
                      onTap: () => _openMovie(lancamentos[index]),
                    ),
                  );
                },
              ),
              Positioned(
                left: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildArrow(
                    icon: Icons.chevron_left,
                    tooltip: 'Página anterior',
                    onPressed:
                    _loadingLaunch ? null : () => _mudarPaginaLancamentos(-1),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildArrow(
                    icon: Icons.chevron_right,
                    tooltip: 'Próxima página',
                    onPressed:
                    _loadingLaunch ? null : () => _mudarPaginaLancamentos(1),
                  ),
                ),
              ),
              if (_loadingLaunch)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            lancamentos.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: index == _currentLaunch
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<SimpleMovie> movies) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          ListView.builder(
            controller: _popularesController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SimpleMovieCard(
                  movie: movies[index],
                  onTap: () => _openMovie(movies[index]),
                ),
              );
            },
          ),
          Positioned(
            left: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildArrow(
                icon: Icons.chevron_left,
                tooltip: 'Página anterior',
                onPressed:
                  _loadingPopular ? null : () => _mudarPaginaPopulares(-1),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildArrow(
                icon: Icons.chevron_right,
                tooltip: 'Próxima página',
                onPressed:
                  _loadingPopular ? null : () => _mudarPaginaPopulares(1),
              ),
            ),
          ),
          if (_loadingPopular)
            const Positioned.fill(
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
