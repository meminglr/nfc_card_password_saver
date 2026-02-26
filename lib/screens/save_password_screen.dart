import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/card_provider.dart';
import '../models/card_item.dart';

class SavePasswordScreen extends StatefulWidget {
  final String? nfcId;
  final CardItem? existingCard;

  const SavePasswordScreen({super.key, this.nfcId, this.existingCard})
    : assert(nfcId != null || existingCard != null);

  @override
  State<SavePasswordScreen> createState() => _SavePasswordScreenState();
}

class _SavePasswordScreenState extends State<SavePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();
  int? _selectedColorCode;
  bool _isSaving = false;

  final List<Color> _availableColors = [
    const Color(0xFF1976D2), // Blue
    const Color(0xFF8E24AA), // Purple
    const Color(0xFFE53935), // Red
    const Color(0xFFF4511E), // Deep Orange
    const Color(0xFF00897B), // Teal
    const Color(0xFF43A047), // Green
    const Color(0xFF3949AB), // Indigo
    const Color(0xFFF06292), // Pink
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingCard != null) {
      _nameController.text = widget.existingCard!.name;
      _descriptionController.text = widget.existingCard!.description ?? '';
      _passwordController.text = widget.existingCard!.password;
      _selectedColorCode = widget.existingCard!.colorCode;
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        final idToSave = widget.existingCard?.id ?? widget.nfcId!;

        await context.read<CardProvider>().saveCard(
          idToSave,
          _nameController.text.trim(),
          _passwordController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          colorCode: _selectedColorCode,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.existingCard != null
                    ? 'Kart başarıyla güncellendi!'
                    : 'Kart başarıyla kaydedildi!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingCard != null ? 'Kartı Düzenle' : 'Yeni Kart Ekle',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.nfc,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kart ID / UID:',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            widget.existingCard?.id ?? widget.nfcId ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Kart Adı (örn: Kasa Anahtarı)',
                  prefixIcon: Icon(
                    Icons.label_outline,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Lütfen bir ad girin' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Kısa Açıklama (Opsiyonel)',
                  prefixIcon: Icon(
                    Icons.description_outlined,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                maxLength: 40,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Kart Şifresi / Eşleşen Parola',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Lütfen bir şifre girin'
                    : null,
              ),
              const SizedBox(height: 32),
              Text(
                'Kart Rengi Seçimi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableColors.length,
                  itemBuilder: (context, index) {
                    final color = _availableColors[index];
                    final isSelected = _selectedColorCode == color.value;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          // Allow toggling off the color
                          if (isSelected) {
                            _selectedColorCode = null;
                          } else {
                            _selectedColorCode = color.value;
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : Text(
                        widget.existingCard != null ? 'Güncelle' : 'Kaydet',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
