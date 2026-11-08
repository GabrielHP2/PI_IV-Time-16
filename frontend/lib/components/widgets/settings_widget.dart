import 'package:flutter/material.dart';
import '../../models/settings/setting_section.dart';

class SettingsWidget extends StatelessWidget {
  final SettingSection section;

  const SettingsWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            section.title,
            style: textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...section.items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3), width: 1),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              leading: Icon(item.icon, color: colors.primary),
              title: Text(
                item.title,
                style: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
              ),
              subtitle: item.subtitle != null 
                ? Text(item.subtitle!, style: textTheme.bodySmall) 
                : null,
              onTap: item.onTap,
            ),
          ),
        )),
        const SizedBox(height: 8),
      ],
    );
  }
}
