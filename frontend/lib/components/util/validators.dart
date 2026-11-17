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

/// Obrigatório e com mais de 8 e menos de 16 caracteres (9 a 15).
String? validatePassword(String? value) {
  final error = validateRequired(value);
  if (error != null) return error;
  if (value!.length < 8 || value.length > 16) {
    return 'A senha deve ter entre 8 e 16 caracteres';
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
