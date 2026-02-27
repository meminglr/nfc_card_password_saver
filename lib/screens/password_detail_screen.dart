import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/card_item.dart';
import '../providers/card_provider.dart';
import '../services/biometric_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/nfc_card_widget.dart';
import 'save_password_screen.dart';

class PasswordDetailScreen extends StatefulWidget {
  final String cardId;

  const PasswordDetailScreen({super.key, required this.cardId});

  @override
  State<PasswordDetailScreen> createState() => _PasswordDetailScreenState();
}

class _PasswordDetailScreenState extends State<PasswordDetailScreen>
    with SingleTickerProviderStateMixin {
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticated = false; // true if ALL required auth passes
  bool _isBiometricAuthenticating = false;
  bool _isNfcAuthenticating = false;
  String? _authError;
  late final CardProvider _cardProvider;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _cardProvider = context.read<CardProvider>();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkSettingsAndAuthenticate();
  }

  Future<void> _checkSettingsAndAuthenticate() async {
    final settingsProvider = context.read<SettingsProvider>();

    // Step 1: Check NFC First
    if (settingsProvider.requireNfc) {
      _authenticateNfc(
        onSuccess: () async {
          // If NFC passes, check Biometrics
          if (settingsProvider.requireBiometrics) {
            final bioSuccess = await _authenticateBiometrics();
            if (bioSuccess && mounted) {
              setState(() => _isAuthenticated = true);
            }
          } else {
            if (mounted) setState(() => _isAuthenticated = true);
          }
        },
      );
      return; // NFC handles the rest of the flow asynchronously
    }

    // Step 2: If NFC not required, check Biometrics directly
    if (settingsProvider.requireBiometrics) {
      final bioSuccess = await _authenticateBiometrics();
      if (!bioSuccess) return; // Error is handled in the method
    }

    // Step 3: No requirements or all succeeded
    if (mounted) {
      setState(() {
        _isAuthenticated = true;
      });
    }
  }

  Future<bool> _authenticateBiometrics() async {
    setState(() {
      _isBiometricAuthenticating = true;
      _authError = null;
    });

    try {
      final success = await _biometricService.authenticate(
        "Şifrenizi görüntülemek için doğrulama yapın",
      );

      if (mounted) {
        setState(() {
          _isBiometricAuthenticating = false;
          if (!success) {
            _authError =
                "Biyometrik doğrulama başarısız oldu veya iptal edildi.";
          }
        });
      }
      return success;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBiometricAuthenticating = false;
          _authError = "Biyometrik doğrulama hatası.";
        });
      }
      return false;
    }
  }

  void _authenticateNfc({required VoidCallback onSuccess}) {
    setState(() {
      _isNfcAuthenticating = true;
      _authError = null;
    });
    _pulseController.repeat(reverse: true);

    _cardProvider.startNfcSession(
      onDiscovered: (id) {
        if (!mounted) return;

        if (id == widget.cardId) {
          setState(() {
            _isNfcAuthenticating = false;
          });
          _pulseController.stop();
          onSuccess();
        } else {
          setState(() {
            _authError =
                "Hatalı kart! Lütfen bu şifrenin kayıtlı olduğu fiziksel kartı okutun.";
            _isNfcAuthenticating = false;
          });
          _pulseController.stop();
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _authError = "NFC Hatası: $error";
          _isNfcAuthenticating = false;
        });
        _pulseController.stop();
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    // Optionally stop session if user backs out during verification
    if (_isNfcAuthenticating) {
      _cardProvider.stopNfcSession();
    }
    super.dispose();
  }

  Future<void> _handleEditRequested(BuildContext context, CardItem card) async {
    final settings = context.read<SettingsProvider>();

    // Check if security is needed, and if the user hasn't already authenticated for this card view
    if (settings.requireBiometrics || settings.requireNfc) {
      if (!_isAuthenticated) {
        // Run the usual auth flow or prompt biometrics
        if (settings.requireBiometrics) {
          final success = await _authenticateBiometrics();
          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kimlik doğrulama başarısız oldu.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Düzenleme için kartı okutarak şifreyi görüntülemeniz gerekir.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SavePasswordScreen(existingCard: card),
        ),
      );
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
                    isDark: Theme.of(context).brightness == Brightness.dark,
                    showActions: true,
                    provider: provider,
                    onEditRequested: () => _handleEditRequested(context, card),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: card.colorCode != null
                        ? [
                            Color(card.colorCode!),
                            Color.lerp(
                              Color(card.colorCode!),
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black
                                  : Theme.of(context).colorScheme.primary,
                              0.4,
                            )!,
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
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstCurve: Curves.easeOutCubic,
                  secondCurve: Curves.easeOutCubic,
                  sizeCurve: Curves.easeOutCubic,
                  crossFadeState: _isNfcAuthenticating
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 48,
                      horizontal: 24,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Shimmer.fromColors(
                              baseColor: Colors.white.withValues(alpha: 0.8),
                              highlightColor: Colors.white,
                              child: const Icon(
                                Icons.nfc,
                                size: 120,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Shimmer.fromColors(
                            baseColor: Colors.white.withValues(alpha: 0.9),
                            highlightColor: Colors.white,
                            child: const Text(
                              'Kartınızı Yaklaştırın',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Şifrenizi görmek için fiziksel kartınızı\ntelefonun arkasına dokundurun.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  secondChild: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
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
                            _isAuthenticated
                                ? Icons.lock_open
                                : Icons.lock_outline,
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
                              if (_isBiometricAuthenticating)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.white.withValues(
                                      alpha: 0.5,
                                    ),
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
                                      onTap: _checkSettingsAndAuthenticate,
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
                              Clipboard.setData(
                                ClipboardData(text: card.password),
                              );
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
