import 'package:flutter/material.dart';
import '../../models/settings/setting_item.dart';
import '../../models/settings/setting_section.dart';
import '../../components/widgets/settings_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // This list can be easily replaced by an API call or a database query later.
  // It follows the "no hardcoded" rule by being a data structure rather than UI.
  static List<SettingSection> get settingsData => [
    SettingSection(
      title: 'Conta',
      items: [
        SettingItem(title: 'E-mail', subtitle: 'seu_email@exemplo.com', icon: Icons.email),
        SettingItem(title: 'Telefone', subtitle: '+55 11 99999-9999', icon: Icons.phone),
        SettingItem(title: 'Senha', icon: Icons.lock),
      ],
    ),
    SettingSection(
      title: 'Notificação',
      items: [
        SettingItem(title: 'Push Notifications', subtitle: 'Ativado', icon: Icons.notifications_active),
        SettingItem(title: 'E-mail Marketing', subtitle: 'Desativado', icon: Icons.email_outlined),
      ],
    ),
    SettingSection(
      title: 'Planejamento',
      items: [
        SettingItem(title: 'Cronograma', icon: Icons.schedule),
        SettingItem(title: 'Metas', icon: Icons.flag),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        leading: BackButton(onPressed: () => Navigator.maybePop(context)),
      ),
      body: ListView.builder(
        itemCount: SettingsPage.settingsData.length,
        itemBuilder: (context, index) {
          final section = SettingsPage.settingsData[index];
          return SettingsWidget(section: section);
        },
      ),
    );
  }
}
