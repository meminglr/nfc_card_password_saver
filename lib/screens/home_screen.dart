import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../providers/card_provider.dart';
import '../providers/settings_provider.dart';
import '../models/card_item.dart';
import 'read_nfc_screen.dart';
import 'password_detail_screen.dart';
import 'settings_screen.dart';
import 'save_password_screen.dart';

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
                      ? Icons.view_list_rounded
                      : Icons.credit_card_rounded,
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
            icon: const Icon(Icons.settings),
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
          final isDark = settings.isDarkMode;
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
                    final settingsProvider = context.read<SettingsProvider>();
                    if (settingsProvider.requireNfc) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReadNfcScreen(
                            expectedId: card.id,
                            cardName: card.name,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PasswordDetailScreen(cardId: card.id),
                        ),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isCardView ? 24 : 16),
                      gradient: LinearGradient(
                        colors: card.colorCode != null
                            ? [
                                Color(card.colorCode!),
                                Color(card.colorCode!).withValues(alpha: 0.6),
                              ]
                            : [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isCardView
                                ? (isDark ? 0.5 : 0.2)
                                : (isDark ? 0.3 : 0.1),
                          ),
                          blurRadius: isCardView ? 12 : 6,
                          offset: Offset(0, isCardView ? 8 : 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isCardView ? 24 : 16),
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        firstCurve: Curves.easeOutCubic,
                        secondCurve: Curves.easeOutCubic,
                        sizeCurve: Curves.easeInOutCubic,
                        crossFadeState: isCardView
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        layoutBuilder:
                            (
                              topChild,
                              topChildKey,
                              bottomChild,
                              bottomChildKey,
                            ) {
                              return Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    key: bottomChildKey,
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: bottomChild,
                                  ),
                                  Positioned(key: topChildKey, child: topChild),
                                ],
                              );
                            },
                        firstChild: SizedBox(
                          key: const ValueKey('card_view'),
                          height: 200,
                          child: _buildPhysicalCard(
                            context,
                            card,
                            isDark,
                            provider,
                          ),
                        ),
                        secondChild: SizedBox(
                          key: const ValueKey('list_view'),
                          height: 88,
                          child: _buildListTile(
                            context,
                            card,
                            isDark,
                            provider,
                          ),
                        ),
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

  Widget _buildListTile(
    BuildContext context,
    CardItem card,
    bool isDark,
    CardProvider provider,
  ) {
    return Center(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(
          Icons.credit_card,
          color: Colors.white.withOpacity(0.8),
          size: 32,
        ),
        title: Text(
          card.name.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            card.description ?? 'Açıklama yok',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontStyle: card.description == null
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
        ),
        trailing: PullDownButton(
          itemBuilder: (context) => [
            PullDownMenuItem(
              title: 'Düzenle',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SavePasswordScreen(existingCard: card),
                  ),
                );
              },
              icon: Icons.edit_outlined,
            ),
            PullDownMenuItem(
              title: 'Sil',
              onTap: () => _showDeleteConfirm(context, provider, card.id),
              icon: Icons.delete_outline,
              isDestructive: true,
            ),
          ],
          buttonBuilder: (context, showMenu) => IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.5)),
            onPressed: showMenu,
          ),
        ),
      ),
    );
  }

  Widget _buildPhysicalCard(
    BuildContext context,
    CardItem card,
    bool isDark,
    CardProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.contactless_outlined,
                color: Colors.white.withOpacity(0.8),
                size: 32,
              ),
              Icon(
                Icons.credit_card,
                color: Colors.white.withOpacity(0.5),
                size: 32,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.description?.toUpperCase() ?? 'AÇIKLAMA YOK',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  letterSpacing: 2,
                  fontStyle: card.description == null
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      card.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PullDownButton(
                    itemBuilder: (context) => [
                      PullDownMenuItem(
                        title: 'Düzenle',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SavePasswordScreen(existingCard: card),
                            ),
                          );
                        },
                        icon: Icons.edit_outlined,
                      ),
                      PullDownMenuItem(
                        title: 'Sil',
                        onTap: () =>
                            _showDeleteConfirm(context, provider, card.id),
                        icon: Icons.delete_outline,
                        isDestructive: true,
                      ),
                    ],
                    buttonBuilder: (context, showMenu) => IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      onPressed: showMenu,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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
            child: Text(
              'İptal',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
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
