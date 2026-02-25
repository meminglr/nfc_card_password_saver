import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              _buildSectionHeader(context, "Kimlik Doğrulama"),
              _buildAuthentication(provider, context),
              _buildSectionHeader(context, "Görünüm"),
              _buildThemeSwitch(provider, context),
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
              activeThumbColor: Theme.of(context).colorScheme.secondary,
            ),
            const Divider(height: 32),
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
              activeThumbColor: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSwitch(SettingsProvider provider, BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: const Text(
          'Karanlık Tema',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Uygulamanın genel görünüm arayüzünü değiştirir.'),
        value: provider.isDarkMode,
        onChanged: (val) => provider.setIsDarkMode(val),
        activeThumbColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 5),
      child: Center(
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
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
