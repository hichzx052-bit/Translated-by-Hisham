import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/language_selector.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({Key? key}) : super(key: key);

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = '';
  String _detectedLanguage = '';
  bool _isTranslating = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    if (_textController.text.trim().isEmpty) return;
    
    setState(() => _isTranslating = true);
    
    final appState = Provider.of<AppState>(context, listen: false);
    
    try {
      final result = await appState.translateText(_textController.text.trim());
      setState(() {
        _translatedText = result['translation'] ?? '';
        _detectedLanguage = result['detectedLanguage'] ?? '';
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _translatedText = 'خطأ في الترجمة: $e';
        _isTranslating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F23),
          appBar: AppBar(
            title: const Text('ترجمة نصية ✍️'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Language selection
                Row(
                  children: [
                    Expanded(
                      child: LanguageSelector(
                        selectedLanguage: appState.sourceLanguage,
                        label: 'من',
                        onChanged: (lang) => appState.setSourceLanguage(lang),
                        showAutoDetect: true,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => appState.swapLanguages(),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                      ),
                    ),
                    Expanded(
                      child: LanguageSelector(
                        selectedLanguage: appState.targetLanguage,
                        label: 'إلى',
                        onChanged: (lang) => appState.setTargetLanguage(lang),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Input
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit, color: Color(0xFF8B5CF6), size: 18),
                            const SizedBox(width: 8),
                            const Text('النص الأصلي', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (_detectedLanguage.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('🔍 $_detectedLanguage', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            maxLines: null,
                            expands: true,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: 'اكتب النص هنا...',
                              hintStyle: TextStyle(color: Colors.white24),
                              border: InputBorder.none,
                            ),
                            onChanged: (_) {
                              if (_textController.text.length > 2) {
                                _translate();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Output
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.1),
                          const Color(0xFF8B5CF6).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.translate, color: Color(0xFF8B5CF6), size: 18),
                            const SizedBox(width: 8),
                            const Text('الترجمة', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (_translatedText.isNotEmpty) ...[
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: _translatedText));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم النسخ ✅'), duration: Duration(seconds: 1)),
                                  );
                                },
                                child: const Icon(Icons.copy, color: Colors.white38, size: 18),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => appState.speakText(_translatedText),
                                child: const Icon(Icons.volume_up, color: Colors.white38, size: 18),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _isTranslating
                              ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
                              : SingleChildScrollView(
                                  child: SelectableText(
                                    _translatedText.isEmpty ? 'الترجمة ستظهر هنا...' : _translatedText,
                                    style: TextStyle(
                                      color: _translatedText.isEmpty ? Colors.white24 : Colors.white,
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Translate button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _translate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('ترجم 🪶', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
