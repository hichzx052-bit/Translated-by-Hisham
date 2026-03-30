import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/language_model.dart';
import '../widgets/glass_container.dart';
import '../widgets/language_selector.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final _controller = TextEditingController();
  String _translated = '';
  String _detectedLang = '';
  bool _isTranslating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    final state = Provider.of<AppState>(context, listen: false);
    try {
      final result = await state.translateText(_controller.text.trim());
      setState(() {
        _translated = result;
        _detectedLang = state.detectedLanguage;
      });
    } catch (e) {
      setState(() => _translated = 'خطأ في الترجمة');
    }
    setState(() => _isTranslating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0A1A),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white70, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'ترجمة نص',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Language row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: LanguageSelector(
                          selectedLanguage: state.sourceLanguage,
                          languages: LanguageModel.supportedLanguages,
                          onChanged: (l) => state.setSourceLanguage(l),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () => state.swapLanguages(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                            ),
                            child: const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                      Expanded(
                        child: LanguageSelector(
                          selectedLanguage: state.targetLanguage,
                          languages: LanguageModel.supportedLanguages,
                          onChanged: (l) => state.setTargetLanguage(l),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Input box
                        GlassContainer(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6366F1).withOpacity(0.1),
                              const Color(0xFF8B5CF6).withOpacity(0.03),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${state.sourceLanguage.flag} النص الأصلي',
                                    style: const TextStyle(color: Color(0xFF818CF8), fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  if (_detectedLang.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: const Color(0xFF818CF8).withOpacity(0.15),
                                      ),
                                      child: Text(
                                        'تم كشف: $_detectedLang',
                                        style: const TextStyle(color: Color(0xFF818CF8), fontSize: 10),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _controller,
                                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
                                maxLines: 5,
                                minLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'اكتب النص هنا...',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                                  border: InputBorder.none,
                                ),
                                onChanged: (_) {
                                  if (_controller.text.length > 2) _translate();
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _miniBtn(Icons.paste, () async {
                                    final data = await Clipboard.getData('text/plain');
                                    if (data?.text != null) {
                                      _controller.text = data!.text!;
                                      _translate();
                                    }
                                  }),
                                  const SizedBox(width: 8),
                                  _miniBtn(Icons.clear, () {
                                    _controller.clear();
                                    setState(() { _translated = ''; _detectedLang = ''; });
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Translate button
                        GestureDetector(
                          onTap: _translate,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isTranslating
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.translate, color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text('ترجم', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Output box
                        if (_translated.isNotEmpty)
                          GlassContainer(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF10B981).withOpacity(0.1),
                                const Color(0xFF059669).withOpacity(0.03),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${state.targetLanguage.flag} الترجمة',
                                      style: const TextStyle(color: Color(0xFF34D399), fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    const Spacer(),
                                    _miniBtn(Icons.copy, () {
                                      Clipboard.setData(ClipboardData(text: _translated));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('تم النسخ ✅'), duration: Duration(seconds: 1)),
                                      );
                                    }),
                                    const SizedBox(width: 8),
                                    _miniBtn(Icons.volume_up, () {
                                      state.speakText(_translated, state.targetLanguage.code);
                                    }),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SelectableText(
                                  _translated,
                                  style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.6),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.06),
        ),
        child: Icon(icon, color: Colors.white38, size: 16),
      ),
    );
  }
}
