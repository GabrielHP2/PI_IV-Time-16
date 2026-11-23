// Feito por Luis Felipe Pontes Mita - 25018740

import 'package:flutter/material.dart';

// Funções de validação, usadas no parâmetro `validator` dos campos.

/// Campo não pode estar vazio.
String? validateRequired(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo obrigatório';
  }
  return null;
}

/// Valida a senha conforme os requisitos do servidor Java.
String? validatePassword(String? value) {
  final error = validateRequired(value);
  if (error != null) return error;

  final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&+=!*_?-])\S{6,126}$',
  );

  if (!passwordRegex.hasMatch(value!)) {
    return 'A senha não atende a todos os requisitos informados.';
  }

  return null;
}

/// Obrigatório e igual ao campo de senha original.
String? Function(String?) validateConfirmPassword(
  TextEditingController original,
) {
  return (value) {
    final error = validateRequired(value);
    if (error != null) return error;
    if (value != original.text) {
      return 'As senhas não conferem';
    }
    return null;
  };
}
