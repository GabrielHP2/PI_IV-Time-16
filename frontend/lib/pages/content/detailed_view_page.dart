import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DetailsScreen extends StatelessWidget {
  final String movieTitle;
  const DetailsScreen({Key? key, required this.movieTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movieTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, size: 100),
            const SizedBox(height: 20),
            Text('Detalhes do filme: $movieTitle'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica de navegação ou ação
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}