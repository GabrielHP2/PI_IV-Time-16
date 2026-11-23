import 'package:cloud_functions/cloud_functions.dart';

import '../models/platform_model.dart';

class PersonalizationService {
  PersonalizationService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(
              region: 'southamerica-east1',
            );

  final FirebaseFunctions _functions;

  /// Busca as plataformas disponíveis no catálogo do backend.
  ///
  /// A Cloud Function getPlatforms exige um usuário autenticado.
  Future<List<PlatformModel>> getPlatforms() async {
    try {
      final result = await _functions.httpsCallable('getPlatforms').call();

      if (result.data is! List) {
        throw Exception(
          'O backend retornou uma lista de plataformas em formato inválido.',
        );
      }

      final rawPlatforms = result.data as List<dynamic>;

      return rawPlatforms.map((item) {
        if (item is! Map) {
          throw const FormatException(
            'Uma plataforma foi retornada em formato inválido.',
          );
        }

        return PlatformModel.fromMap(
          Map<String, dynamic>.from(item),
        );
      }).where((platform) => platform.name.isNotEmpty).toList();
    } on FirebaseFunctionsException catch (error) {
      switch (error.code) {
        case 'unauthenticated':
          throw Exception(
            'Faça login para carregar as plataformas disponíveis.',
          );
        case 'unavailable':
          throw Exception(
            'Serviço indisponível. Verifique se o Firebase Emulator está ativo.',
          );
        default:
          throw Exception(
            error.message ?? 'Não foi possível carregar as plataformas.',
          );
      }
    } on FormatException catch (error) {
      throw Exception(error.message);
    }
  }
}
