import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _functions = functions ??
            FirebaseFunctions.instanceFor(
              region: 'southamerica-east1',
            ),
        _auth = auth ?? FirebaseAuth.instance {
    // SOMENTE PARA TESTES LOCAIS.
    _functions.useFunctionsEmulator('localhost', 5001);
    _auth.useAuthEmulator('localhost', 9099);
  }

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  /// Autentica as credenciais pelo backend e estabelece a sessão Firebase
  /// usando o Custom Token retornado pela Cloud Function signIn.
  Future<UserCredential> login(String email, String password) async {
    try {
      final result = await _functions.httpsCallable('signIn').call({
        'email': email.trim(),
        'password': password,
      });

      if (result.data is! Map) {
        throw Exception('O backend retornou uma resposta inesperada.');
      }

      final response = Map<String, dynamic>.from(result.data as Map);
      final token = response['token']?.toString();

      if (response['code'] != 200 || token == null || token.isEmpty) {
        throw Exception(
          response['message']?.toString() ??
              'Não foi possível realizar o login.',
        );
      }

      return await _auth.signInWithCustomToken(token);
    } on FirebaseFunctionsException catch (error) {
      throw Exception(_messageForFunction(error.code, error.message));
    } on FirebaseAuthException catch (error) {
      throw Exception(_messageForAuth(error));
    }
  }

  /// Cadastro permanece chamando a Cloud Function signUp.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final result = await _functions.httpsCallable('signUp').call({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'phoneNumber': phoneNumber.trim(),
      });

      if (result.data is! Map) {
        throw Exception('O backend retornou uma resposta inesperada.');
      }

      final response = Map<String, dynamic>.from(result.data as Map);

      if (response['code'] != 200) {
        throw Exception(
          response['message']?.toString() ??
              'Não foi possível realizar o cadastro.',
        );
      }

      return response;
    } on FirebaseFunctionsException catch (error) {
      throw Exception(_messageForFunction(error.code, error.message));
    }
  }

  String _messageForFunction(String code, String? backendMessage) {
    switch (code) {
      case 'invalid-argument':
        return backendMessage ?? 'Confira os dados informados.';
      case 'already-exists':
        return backendMessage ?? 'Este e-mail já está cadastrado.';
      case 'unauthenticated':
        return backendMessage ?? 'E-mail ou senha incorretos.';
      case 'unavailable':
        return 'Serviço indisponível. Tente novamente.';
      case 'internal':
        return backendMessage ?? 'Erro interno ao processar a solicitação.';
      default:
        return backendMessage ?? 'Não foi possível concluir a operação.';
    }
  }

  String _messageForAuth(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-custom-token':
      case 'custom-token-mismatch':
        return 'Não foi possível iniciar a sessão. Verifique a configuração do Firebase.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet.';
      default:
        return error.message ?? 'Não foi possível iniciar a sessão.';
    }
  }
}
