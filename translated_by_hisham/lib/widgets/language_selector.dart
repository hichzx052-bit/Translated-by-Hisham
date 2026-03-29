import 'package:flutter/material.dart';
import '../models/language_model.dart';
import 'glass_container.dart';

class LanguageSelector extends StatelessWidget {
  final LanguageModel selectedLanguage;
  final List<LanguageModel> languages;
  final ValueChanged<LanguageModel> onChanged;
  final String label;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.languages,
    required this.onChanged,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLanguagePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedLanguage.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              selectedLanguage.nativeName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, color: Colors.white.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _LanguagePickerSheet(
        languages: languages,
        selected: selectedLanguage,
        onSelect: (lang) {
          onChanged(lang);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _LanguagePickerSheet extends StatefulWidget {
  final List<LanguageModel> languages;
  final LanguageModel selected;
  final ValueChanged<LanguageModel> onSelect;

  const _LanguagePickerSheet({
    required this.languages,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  String _search = '';

  List<LanguageModel> get _filtered => _search.isEmpty
      ? widget.languages
      : widget.languages.where((l) =>
          l.name.toLowerCase().contains(_search.toLowerCase()) ||
          l.nativeName.contains(_search) ||
          l.code.toLowerCase().contains(_search.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'اختر اللغة',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث عن لغة...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final lang = _filtered[index];
                final isSelected = lang.code == widget.selected.code;
                return ListTile(
                  onTap: () => widget.onSelect(lang),
                  leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    lang.nativeName,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF818CF8) : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    lang.name,
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF818CF8))
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
