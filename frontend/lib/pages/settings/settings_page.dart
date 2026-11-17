
// Adições e modificações por Felipe Batista Bastos - 25005337

import 'package:flutter/material.dart';

import '../../repositories/personalization_repository.dart';
import '../../routes.dart';
import '../../theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = false;

  static const Color _headerColor = Color(0xFFA476B8);
  static const Color _dividerColor = Color(0xFFD9C3E3);

  void _showAccountInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dados da conta'),
        content: const Text(
          'As informações de nome, e-mail e telefone serão exibidas aqui '
          'quando o cadastro e a autenticação estiverem conectados ao backend.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _openPasswordRecovery() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  String _formatCurrency(double? value) {
    if (value == null) return 'Não informado';
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _showPlanningSummary() {
    final currentSpend = PersonalizationRepository.currentMonthlySpend.value;
    final desiredSpend = PersonalizationRepository.desiredMonthlySpend.value;
    final platforms = PersonalizationRepository.subscribedPlatforms.value;
    final ongoingContents = PersonalizationRepository.ongoingContents.value;
    final desiredContents = PersonalizationRepository.desiredContents.value;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Meu planejamento'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _planningLine('Gasto atual', _formatCurrency(currentSpend)),
              _planningLine('Gasto desejado', _formatCurrency(desiredSpend)),
              _planningLine(
                'Plataformas',
                platforms.isEmpty ? 'Nenhuma selecionada' : platforms.join(', '),
              ),
              _planningLine('Conteúdos em andamento', '${ongoingContents.length}'),
              _planningLine('Conteúdos desejados', '${desiredContents.length}'),
              const SizedBox(height: 8),
              Text(
                PersonalizationRepository.isPlanRegistered.value
                    ? 'Planejamento registrado nesta sessão.'
                    : 'O planejamento ainda não foi registrado.',
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _planningLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }

  void _editPlanning() {
    Navigator.pushNamed(context, AppRoutes.platforms);
  }

  void _onNavigationTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.wishlist,
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
        break;
      case 2:
        // A tela de configurações já está selecionada.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _headerColor,
        foregroundColor: AppColors.onDark,
        leadingWidth: 62,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(8, 7, 4, 7),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.logoCircle,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              kLogoAsset,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
        children: [
          _buildSectionTitle('Conta'),
          _buildActionTile(
            icon: Icons.person_outline,
            title: 'Dados da conta',
            subtitle: 'Visualizar suas informações pessoais',
            onTap: _showAccountInfo,
          ),
          _buildActionTile(
            icon: Icons.email_outlined,
            title: 'E-mail e telefone',
            subtitle: 'Consultar seus dados de contato',
            onTap: _showAccountInfo,
          ),
          _buildActionTile(
            icon: Icons.lock_outline,
            title: 'Redefinir senha',
            subtitle: 'Alterar sua senha de acesso',
            onTap: _openPasswordRecovery,
          ),
          _buildDivider(),
          _buildSectionTitle('Notificação'),
          _buildSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: 'Notificações push',
            subtitle: 'Receber avisos sobre conteúdos e plataformas',
            value: _pushNotificationsEnabled,
            onChanged: (value) {
              setState(() => _pushNotificationsEnabled = value);
            },
          ),
          _buildSwitchTile(
            icon: Icons.mark_email_unread_outlined,
            title: 'E-mails de novidades',
            subtitle: 'Receber novidades e recomendações por e-mail',
            value: _emailNotificationsEnabled,
            onChanged: (value) {
              setState(() => _emailNotificationsEnabled = value);
            },
          ),
          _buildDivider(),
          _buildSectionTitle('Planejamento'),
          _buildActionTile(
            icon: Icons.calendar_month_outlined,
            title: 'Visualizar planejamento',
            subtitle: 'Consultar gastos, plataformas e conteúdos',
            onTap: _showPlanningSummary,
          ),
          _buildActionTile(
            icon: Icons.edit_calendar_outlined,
            title: 'Ajustar planejamento',
            subtitle: 'Atualizar suas plataformas e preferências',
            onTap: _editPlanning,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _headerColor,
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: AppColors.button,
        unselectedItemColor: AppColors.button,
        onTap: _onNavigationTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Minha lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.button,
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
            activeIcon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.button,
              child: Icon(Icons.person, color: Colors.white),
            ),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Divider(color: _dividerColor, thickness: 1),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.logoCircle,
        borderRadius: BorderRadius.circular(9),
      ),
      child: ListTile(
        minVerticalPadding: 8,
        leading: CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.button,
          child: Icon(icon, color: Colors.white, size: 19),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 11,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white70,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.logoCircle,
        borderRadius: BorderRadius.circular(9),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        secondary: CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.button,
          child: Icon(icon, color: Colors.white, size: 19),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 11,
          ),
        ),
        value: value,
        activeThumbColor: AppColors.button,
        activeTrackColor: AppColors.background,
        inactiveThumbColor: Colors.white70,
        inactiveTrackColor: Colors.white24,
        onChanged: onChanged,
      ),
    );
  }
}
