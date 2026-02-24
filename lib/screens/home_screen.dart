import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/card_provider.dart';
import 'read_nfc_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıtlı Kartlarım')),
      body: Consumer<CardProvider>(
        builder: (context, provider, child) {
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
                  Icon(Icons.nfc, size: 80, color: Colors.white24),
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
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.credit_card,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      card.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Şifreyi görmek için karta tıklayın ve okutun',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        _showDeleteConfirm(context, provider, card.id);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReadNfcScreen(
                            expectedId: card.id,
                            cardName: card.name,
                          ),
                        ),
                      );
                    },
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

  void _showDeleteConfirm(
    BuildContext context,
    CardProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Silmek istediğinize emin misiniz?'),
        content: const Text('Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteCard(id);
              Navigator.pop(ctx);
            },
            child: Text(
              'Sil',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
