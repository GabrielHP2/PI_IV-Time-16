// Feito por Felipe Batista Bastos - 25005337


import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordService {
  PasswordService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _functions = functions ??
            FirebaseFunctions.instanceFor(
              region: 'southamerica-east1',
            ),
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  Future<void> requestPasswordReset(String email) async {
    final normalizedEmail = email.trim();

    try {
      // 1. Valida o e-mail através da Cloud Function publicada.
      await _functions.httpsCallable('resetPassword').call({
        'email': normalizedEmail,
      });

      // 2. Solicita ao Firebase Authentication o envio do link.
      await _auth.sendPasswordResetEmail(
        email: normalizedEmail,
      );
    } on FirebaseFunctionsException catch (error) {
      throw Exception(
        error.message ?? 'Não foi possível validar o e-mail.',
      );
    } on FirebaseAuthException catch (error) {
      throw Exception(_messageForAuth(error));
    }
  }

  String _messageForAuth(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'O endereço de e-mail é inválido.';
      case 'user-not-found':
        return 'Nenhuma conta encontrada com este e-mail.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet.';
      case 'too-many-requests':
        return 'Muitas solicitações. Aguarde um pouco.';
      default:
        return error.message ??
            'Não foi possível enviar o e-mail de redefinição.';
    }
  }
}
