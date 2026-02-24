import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/card_provider.dart';
import '../services/biometric_service.dart';

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
    _authenticate();
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _isAuthenticated ? Icons.lock_open : Icons.lock_outline,
                      size: 80,
                      color: _isAuthenticated
                          ? Colors.greenAccent
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isAuthenticated ? 'Gizli Şifreniz' : 'Şifre Kilitli',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isAuthenticating)
                      const CircularProgressIndicator()
                    else if (_authError != null)
                      Column(
                        children: [
                          Text(
                            _authError!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _authenticate,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tekrar Dene'),
                          ),
                        ],
                      )
                    else if (_isAuthenticated)
                      SelectableText(
                        card.password,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              if (_isAuthenticated)
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: card.password));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Şifre kopyalandı!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Kopyala'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 64),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Geri Dön',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
