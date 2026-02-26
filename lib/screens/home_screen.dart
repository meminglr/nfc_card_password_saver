import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/card_provider.dart';
import '../providers/settings_provider.dart';
import 'read_nfc_screen.dart';
import 'password_detail_screen.dart';
import 'settings_screen.dart';
import '../widgets/nfc_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _draggingIndex;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortFilterBottomSheet(BuildContext context, CardProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer<CardProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sıralama ve Filtreleme',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sıralama',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('A-Z'),
                        selected: provider.sortOption == SortOption.aToZ,
                        onSelected: (selected) {
                          if (selected) {
                            provider.setSortOption(SortOption.aToZ);
                          } else {
                            provider.setSortOption(SortOption.custom);
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Z-A'),
                        selected: provider.sortOption == SortOption.zToA,
                        onSelected: (selected) {
                          if (selected) {
                            provider.setSortOption(SortOption.zToA);
                          } else {
                            provider.setSortOption(SortOption.custom);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Renk Filtresi',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (provider.filterColorCode != null)
                        TextButton(
                          onPressed: () {
                            provider.setFilterColorCode(null);
                            Navigator.pop(context);
                          },
                          child: const Text('Temizle'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          [
                            0xFF1976D2, // Blue
                            0xFFE53935, // Red
                            0xFF00897B, // Teal
                            0xFF8E24AA, // Purple
                            0xFFF4511E, // Deep Orange
                            0xFF43A047, // Green
                            0xFF3949AB, // Indigo
                            0xFFF06292, // Pink
                            0xFF795548, // Brown
                            0xFF607D8B, // Blue Grey
                          ].map((colorValue) {
                            final isSelected =
                                provider.filterColorCode == colorValue;
                            return GestureDetector(
                              onTap: () {
                                provider.setFilterColorCode(
                                  isSelected ? null : colorValue,
                                );
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Color(colorValue),
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          width: 3,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(
                                        colorValue,
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

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

          final displayCards = provider.filteredAndSortedCards;
          final canReorder =
              provider.searchQuery.isEmpty && provider.filterColorCode == null;

          return Column(
            children: [
              // Search and Filter Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => provider.setSearchQuery(value),
                        decoration: InputDecoration(
                          hintText: 'Kart ara...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.setSearchQuery('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: provider.filterColorCode != null
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: provider.filterColorCode != null
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () =>
                            _showSortFilterBottomSheet(context, provider),
                        tooltip: 'Sırala ve Filtrele',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.cards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.nfc,
                              size: 80,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.24),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz kayıtlı kartınız yok.\nYeni bir kart eklemek için tarama yapın.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : displayCards.isEmpty
                    ? const Center(
                        child: Text(
                          'Arama veya filtreleme ile eşleşen kart bulunamadı.',
                        ),
                      )
                    : canReorder
                    ? ReorderableListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayCards.length,
                        onReorderStart: (index) {
                          setState(() => _draggingIndex = index);
                        },
                        onReorderEnd: (index) {
                          setState(() => _draggingIndex = null);
                        },
                        onReorder: (oldIndex, newIndex) {
                          provider.reorderCards(oldIndex, newIndex);
                        },
                        proxyDecorator:
                            (
                              Widget child,
                              int index,
                              Animation<double> animation,
                            ) {
                              return Material(
                                type: MaterialType.transparency,
                                child: child,
                              );
                            },
                        itemBuilder: (context, index) {
                          final card = displayCards[index];

                          // Scaling logic
                          final isDragging = _draggingIndex != null;
                          final isThisCardDragging = _draggingIndex == index;
                          final scale = (isDragging && !isThisCardDragging)
                              ? 0.95
                              : 1.0;

                          return AnimatedScale(
                            key: ValueKey(card.id),
                            scale: scale,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: isCardView ? 24.0 : 16.0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PasswordDetailScreen(cardId: card.id),
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
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayCards.length,
                        itemBuilder: (context, index) {
                          final card = displayCards[index];
                          return Padding(
                            key: ValueKey(card.id),
                            padding: EdgeInsets.only(
                              bottom: isCardView ? 24.0 : 16.0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PasswordDetailScreen(cardId: card.id),
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
                      ),
              ),
            ],
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
