import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/card_provider.dart';
import 'save_password_screen.dart';
import 'password_detail_screen.dart';

class ReadNfcScreen extends StatefulWidget {
  final String? expectedId;
  final String? cardName;

  const ReadNfcScreen({super.key, this.expectedId, this.cardName});

  @override
  State<ReadNfcScreen> createState() => _ReadNfcScreenState();
}

class _ReadNfcScreenState extends State<ReadNfcScreen> {
  bool _isChecking = true;
  String? _statusMessage;
  bool _isLarge = false;
  late final CardProvider _cardProvider;

  @override
  void initState() {
    super.initState();
    _cardProvider = context.read<CardProvider>();
    _startNfcReading();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isLarge = true);
    });
  }

  void _startNfcReading() {
    final provider = context.read<CardProvider>();
    setState(() {
      _statusMessage = "NFC Kartınızı yaklaştırın...";
      _isChecking = true;
    });

    provider.startNfcSession(
      onDiscovered: (id) {
        if (!mounted) return;

        if (widget.expectedId != null) {
          if (widget.expectedId == id) {
            _navigateToDetail(id);
          } else {
            setState(() {
              _statusMessage =
                  "Hatalı kart! Lütfen ${widget.cardName} adlı kartı okutun.";
              _isChecking = false;
            });
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) _startNfcReading();
            });
          }
        } else {
          final existingCard = provider.cards
              .where((c) => c.id == id)
              .firstOrNull;
          if (existingCard != null) {
            _navigateToDetail(id);
          } else {
            _navigateToSave(id);
          }
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _statusMessage = "Hata: $error";
          _isChecking = false;
        });
      },
    );
  }

  void _navigateToDetail(String id) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PasswordDetailScreen(cardId: id)),
    );
  }

  void _navigateToSave(String id) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SavePasswordScreen(nfcId: id)),
    );
  }

  @override
  void dispose() {
    _cardProvider.stopNfcSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC Okunuyor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: _isLarge ? 1.3 : 0.8,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              onEnd: () {
                if (mounted) setState(() => _isLarge = !_isLarge);
              },
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.nfc,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 64),
            Text(
              _statusMessage ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (widget.expectedId != null && _isChecking)
              Text(
                'Bekleniyor: ${widget.cardName}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
