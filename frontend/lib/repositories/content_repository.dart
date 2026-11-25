//Feito por Luis Felipe Pontes Mita RA - 25018740 

import 'package:cloud_functions/cloud_functions.dart';

import '../models/movie_model.dart';
import '../models/simple_movie_model.dart';

class ContentRepository {
  ContentRepository._();

  static Future<List<Movie>> getCatalogContent(int page) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('getRandomContent');
    final response = await callable.call({'page': page});

    final data = Map<String, dynamic>.from(response.data);
    final List<dynamic> jsonData = data['results'];

    return jsonData
        .map((json) => Movie.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

    static Future<Movie> getMovieDetails(SimpleMovie simple) async {
    final callable = FirebaseFunctions.instanceFor(
      region: 'southamerica-east1',
    ).httpsCallable('getMovieDetails'); // ajuste o nome, se for outro

    final response = await callable.call({
      'id': simple.id,
      'category': simple.category, // ou 'type', conforme o backend espera
    });

    final json = Map<String, dynamic>.from(response.data as Map);
    json['category'] ??= simple.category;

    return Movie.fromJson(json);
  }
}