//Feito por Luis Felipe Pontes Mita RA - 25018740 

import 'package:cloud_functions/cloud_functions.dart';

import '../models/movie_model.dart';

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
}