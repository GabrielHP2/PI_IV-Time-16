// Adições e modificações por Felipe Batista Bastos - 25005337
// Correções por Luis Felipe Pontes Mita RA - 25018740

import 'dart:math' as math;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

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
  final callable = FirebaseFunctions.instance.httpsCallable('getMovieDetails'); // ajuste
  final response = await callable.call({
    'id': simple.id,
    'type': simple.category,
  });

  final json = Map<String, dynamic>.from(response.data);
  json['media_type'] ??= simple.category;

  return Movie.fromJson(json);
}

Future<List<SimpleMovie>> getLaunchingContent(int page) async {
  final callable = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  ).httpsCallable('getLaunchingContent');

  final response = await callable.call({'page': page});
  final data = Map<String, dynamic>.from(response.data as Map);
  final results = List<dynamic>.from(data['results'] as List);

  return results
      .map((json) => SimpleMovie.fromJson(
            Map<String, dynamic>.from(json as Map),
          ))
      .toList();
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
      randomContent.add(
        SimpleMovie.fromJson(Map<String, dynamic>.from(json)),
      );
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
  int _currentLaunch = 0;

  List<SimpleMovie> lancamentos = [];
  List<SimpleMovie> populares = [];
  bool isLoading = true;
  
  Future<void> carregarFilmes() async {
    try {
      final resultados = await Future.wait<List<SimpleMovie>>([
        getLaunchingContent(1),
        getRandomContent(1),
      ]);

      if (!mounted) return;

      setState(() {
        lancamentos = resultados[0];
        populares = resultados[1];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint('Erro ao carregar filmes: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    carregarFilmes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showPendingMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openMovie(SimpleMovie movie) {
    Navigator.pushNamed(
      context,
      AppRoutes.detailedView,
      arguments: movie,
    );
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
      body: isLoading ? const Center(
          child: CircularProgressIndicator(),)
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
          child: PageView.builder(
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
      child: ListView.builder(
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
    );
  }
}
