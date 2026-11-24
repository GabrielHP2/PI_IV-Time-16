import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../components/widgets/movie_card.dart';
import '../../components/widgets/notification_panel.dart';
import '../../models/app_notification.dart';
import '../../models/simple_movie_model.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/personalization_repository.dart';
import '../../routes.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();
  final ContentService _contentService = ContentService();

  int _currentLaunch = 0;
  int _page = 1;
  List<SimpleMovie> _launches = [];
  List<SimpleMovie> _popular = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadContent(1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadContent(int page) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final results = await Future.wait<List<SimpleMovie>>([
        _contentService.getLaunchingContent(page),
        _contentService.getRandomContent(page),
      ]);

      if (!mounted) return;

      setState(() {
        _launches = results[0];
        _popular = results[1];
        _page = page;
        _currentLaunch = 0;
        _isLoading = false;
      });

      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadNextPage() {
    final nextPage = _page % 5 + 1;
    return _loadContent(nextPage);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openMovie(SimpleMovie simpleMovie) async {
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
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
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
            onPressed: () => _showMessage('A pesquisa será implementada.'),
            icon: const Icon(Icons.search),
          ),
          _buildNotificationAction(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _buildLoadError()
              : RefreshIndicator(
                  onRefresh: _loadNextPage,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                        _buildHorizontalList(_popular),
                        const SizedBox(height: 40),
                      ],
                    ),
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

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 42),
            const SizedBox(height: 12),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _loadContent(_page),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    if (_launches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('Nenhum lançamento disponível no momento.'),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _launches.length,
            onPageChanged: (index) {
              setState(() => _currentLaunch = index);
            },
            itemBuilder: (context, index) {
              final movie = _launches[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SimpleMovieCard(
                  movie: movie,
                  isLarge: true,
                  onTap: () => _openMovie(movie),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _launches.length,
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
    if (movies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Nenhum conteúdo popular disponível.'),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SimpleMovieCard(
              movie: movie,
              onTap: () => _openMovie(movie),
            ),
          );
        },
      ),
    );
  }
}
