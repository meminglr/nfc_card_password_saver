import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/card_provider.dart';
import '../services/biometric_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/nfc_card_widget.dart';

class PasswordDetailScreen extends StatefulWidget {
  final String cardId;

  const PasswordDetailScreen({super.key, required this.cardId});

  @override
  State<PasswordDetailScreen> createState() => _PasswordDetailScreenState();
}

class _PasswordDetailScreenState extends State<PasswordDetailScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticated = false;
  bool _isAuthenticating = true;
  String? _authError;

  @override
  void initState() {
    super.initState();
    _checkSettingsAndAuthenticate();
  }

  Future<void> _checkSettingsAndAuthenticate() async {
    final settingsProvider = context.read<SettingsProvider>();
    if (!settingsProvider.requireBiometrics) {
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
      }
      return;
    }
    await _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _authError = null;
    });

    try {
      final success = await _biometricService.authenticate(
        "Şifrenizi görüntülemek için doğrulama yapın",
      );

      if (mounted) {
        setState(() {
          _isAuthenticated = success;
          _isAuthenticating = false;
          if (!success) {
            _authError = "Doğrulama başarısız oldu veya iptal edildi.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _isAuthenticated = false;
          _authError = "Biyometrik doğrulama hatası.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CardProvider>();
    final card = provider.cards.where((c) => c.id == widget.cardId).firstOrNull;

    if (card == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: const Center(child: Text('Kart bulunamadı!')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(card.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Hero(
                tag: 'card_${card.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: NfcCardWidget(
                    card: card,
                    isCardView: true,
                    isDark: context.read<SettingsProvider>().isDarkMode,
                    showActions: false,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
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
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (card.colorCode != null
                                  ? Color(card.colorCode!)
                                  : Theme.of(context).colorScheme.primary)
                              .withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isAuthenticated ? Icons.lock_open : Icons.lock_outline,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isAuthenticated
                                ? 'Gizli Şifreniz'
                                : 'Şifre Kilitli',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          if (_isAuthenticating)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Shimmer.fromColors(
                                baseColor: Colors.white.withValues(alpha: 0.5),
                                highlightColor: Colors.white,
                                child: Container(
                                  height: 28,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            )
                          else if (_authError != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _authError!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _authenticate,
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.refresh,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Tekrar Dene',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else if (_isAuthenticated)
                            SizedBox(
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  card.password,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_isAuthenticated)
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: card.password));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Şifre kopyalandı!',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        color: Colors.white,
                        tooltip: 'Kopyala',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Geri Dön',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
