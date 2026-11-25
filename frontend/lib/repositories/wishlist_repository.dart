import 'package:flutter/foundation.dart';

import '../models/movie_model.dart';
import '../services/wishlist_service.dart';

/// Repositório da lista de desejos persistida no MongoDB via Cloud Functions.
class WishlistRepository {
  WishlistRepository._();

  static final WishlistService _service = WishlistService();

  // ValueNotifier permite que as telas sejam notificadas quando a lista local é substituída.
  static final ValueNotifier<List<Movie>> items =
      ValueNotifier<List<Movie>>(<Movie>[]);

  static bool _isLoaded = false;
  static Future<void>? _loading;

  static bool get isLoaded => _isLoaded;

  static bool contains(String movieId) {
    return items.value.any((movie) => movie.id == movieId);
  }

  // Faz o carregamento inicial apenas uma vez e reutiliza uma requisição que já esteja em andamento.
  static Future<void> load() async {
    if (_isLoaded) return;
    if (_loading != null) return _loading!;

    // Recupera os registros da conta autenticada e atualiza a lista usada pela interface.
    _loading = _loadFromServer();
    try {
      await _loading;
    } finally {
      _loading = null;
    }
  }

  // Solicita uma atualização explícita para refletir alterações feitas no servidor.
  static Future<void> refresh() async {
    await _loadFromServer();
  }

  static Future<void> _loadFromServer() async {
    final movies = await _service.getWishlist();
    items.value = List<Movie>.unmodifiable(movies);
    _isLoaded = true;
  }

  // Envia o conteúdo ao serviço remoto; a lista local só é atualizada após a operação concluir.
  static Future<void> add(Movie movie) async {
    if (contains(movie.id)) return;
    await _service.addToWishlist(movie);
    items.value = List<Movie>.unmodifiable([...items.value, movie]);
  }

  // Solicita a remoção remota e, após sucesso, retira o item da lista observável.
  static Future<void> remove(String movieId) async {
    final movie = items.value.where((item) => item.id == movieId).firstOrNull;
    if (movie == null) return;

    await _service.removeFromWishlist(movie);
    items.value = List<Movie>.unmodifiable(
      items.value.where((item) => item.id != movieId),
    );
  }

  // Decide entre adicionar ou remover o conteúdo de acordo com sua presença atual na lista.
  static Future<void> toggle(Movie movie) async {
    if (contains(movie.id)) {
      await remove(movie.id);
    } else {
      await add(movie);
    }
  }
}
