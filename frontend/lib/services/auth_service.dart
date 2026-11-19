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
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  // Mantido para a integração de Login (#27).
  // O método de login será ajustado na etapa correspondente.
  Future<UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Chama a Cloud Function signUp e retorna a resposta do backend.
  /// A regra de negócio e a persistência continuam no backend.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final callable = _functions.httpsCallable('signUp');
      final result = await callable.call({
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
      throw Exception(
        error.message ?? _messageForFunction(error.code),
      );
    }
  }

  String _messageForFunction(String code) {
    switch (code) {
      case 'invalid-argument':
        return 'Confira os dados informados.';
      case 'already-exists':
        return 'Este e-mail já está cadastrado.';
      case 'unavailable':
        return 'Serviço indisponível. Tente novamente.';
      default:
        return 'Não foi possível realizar o cadastro.';
    }
  }
}
