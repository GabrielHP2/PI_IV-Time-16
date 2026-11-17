import 'package:flutter/material.dart';

class SettingItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const SettingItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
  });
}
