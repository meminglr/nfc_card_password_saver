import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Güvenlik Ayarları')),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(context, "Görünüm"),
              _buildThemeSwitch(provider, context),
              const SizedBox(height: 16),
              _buildSectionHeader(context, "Kimlik Doğrulama"),
              _buildAuthentication(provider, context),

              _buildInfoFooter(context),
            ],
          );
        },
      ),
    );
  }

  Card _buildAuthentication(SettingsProvider provider, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(
                'NFC Kart Okutma Zorunluluğu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Kart şifrelerini görebilmek için fiziksel NFC kartını telefona okutmanız gerekir.',
              ),
              value: provider.requireNfc,
              onChanged: (val) => provider.setRequireNfc(val),
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
            const Divider(height: 16),
            SwitchListTile(
              title: const Text(
                'Biyometrik Doğrulama Zorunluluğu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Şifreyi ekranda görebilmek için Face ID, Touch ID veya cihaz şifresi gerekir.',
              ),
              value: provider.requireBiometrics,
              onChanged: (val) => provider.setRequireBiometrics(val),
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSwitch(SettingsProvider provider, BuildContext context) {
    String themeText;
    IconData themeIcon;
    switch (provider.themeMode) {
      case ThemeMode.light:
        themeText = 'Açık';
        themeIcon = Icons.light_mode_outlined;
        break;
      case ThemeMode.dark:
        themeText = 'Karanlık';
        themeIcon = Icons.dark_mode_outlined;
        break;
      case ThemeMode.system:
        themeText = 'Sisteme Göre';
        themeIcon = Icons.brightness_auto_outlined;
        break;
    }

    return Card(
      child: ListTile(
        leading: Icon(Icons.palette_outlined),
        title: const Text(
          'Tema Görünümü',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        trailing: PullDownButton(
          routeTheme: PullDownMenuRouteTheme(
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          itemBuilder: (context) => [
            PullDownMenuItem(
              title: 'Açık',
              onTap: () => provider.setThemeMode(ThemeMode.light),
              icon: Icons.light_mode_outlined,
            ),
            PullDownMenuItem(
              title: 'Karanlık',
              onTap: () => provider.setThemeMode(ThemeMode.dark),
              icon: Icons.dark_mode_outlined,
            ),
            PullDownMenuItem(
              title: 'Sisteme Göre',
              onTap: () => provider.setThemeMode(ThemeMode.system),
              icon: Icons.brightness_auto_outlined,
            ),
          ],
          buttonBuilder: (context, showMenu) => TextButton(
            onPressed: showMenu,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(themeIcon, size: 18),
                const SizedBox(width: 8),
                Text(themeText),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'En yüksek güvenlik için her iki özelliğin de açık kalması önerilir. Kapatılması durumunda telefonunuza erişen kişiler şifrelerinizi kolayca kopyalayabilir.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
