import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/card_provider.dart';
import '../providers/settings_provider.dart';
import 'read_nfc_screen.dart';
import 'password_detail_screen.dart';
import 'settings_screen.dart';
import '../widgets/nfc_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıtlı Kartlarım'),
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return IconButton(
                icon: Icon(
                  settings.isCardViewEnabled
                      ? Icons.view_list_outlined
                      : Icons.credit_card_outlined,
                ),
                onPressed: () {
                  settings.setIsCardViewEnabled(!settings.isCardViewEnabled);
                },
                tooltip: settings.isCardViewEnabled
                    ? 'Liste Görünümüne Geç'
                    : 'Kart Görünümüne Geç',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<CardProvider, SettingsProvider>(
        builder: (context, provider, settings, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final isCardView = settings.isCardViewEnabled;
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                provider.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          if (provider.cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.nfc,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.24),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz kayıtlı kartınız yok.\nYeni bir kart eklemek için tarama yapın.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.cards.length,
            itemBuilder: (context, index) {
              final card = provider.cards[index];
              return Padding(
                padding: EdgeInsets.only(bottom: isCardView ? 24.0 : 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PasswordDetailScreen(cardId: card.id),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'card_${card.id}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: NfcCardWidget(
                        card: card,
                        isCardView: isCardView,
                        isDark: isDark,
                        provider: provider,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReadNfcScreen()),
          );
        },
        icon: const Icon(Icons.nfc),
        label: const Text('Kart Okut / Ekle'),
      ),
    );
  }
}
