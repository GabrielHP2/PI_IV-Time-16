import 'package:cloud_functions/cloud_functions.dart';

/// Comunicação com as Cloud Functions responsáveis pela redefinição de senha.
/// As funções do backend não são modificadas.
class PasswordService {
  PasswordService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  final FirebaseFunctions _functions;

  Future<String> validateEmail(String email) async {
    try {
      final callable = _functions.httpsCallable('resetPassword');
      final result = await callable.call<Map<String, dynamic>>({
        'email': email.trim(),
      });

      final uid = result.data['uid'];
      if (uid is! String || uid.isEmpty) {
        throw Exception('Não foi possível identificar a conta.');
      }

      return uid;
    } on FirebaseFunctionsException catch (error) {
      throw Exception(_messageFor(error));
    }
  }

  Future<void> changePassword({
    required String uid,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final callable = _functions.httpsCallable('changePassword');
      await callable.call({
        'uid': uid,
        'password': password,
        'confirmPassword': confirmPassword,
      });
    } on FirebaseFunctionsException catch (error) {
      throw Exception(_messageFor(error));
    }
  }

  String _messageFor(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'invalid-argument':
        return error.message ?? 'Verifique os dados informados.';
      case 'not-found':
        return 'Conta não encontrada.';
      case 'unavailable':
        return 'Serviço indisponível. Tente novamente.';
      case 'deadline-exceeded':
        return 'A solicitação demorou demais. Tente novamente.';
      default:
        return error.message ?? 'Não foi possível concluir a operação.';
    }
  }
}
