import 'package:flutter/material.dart';
import '../models/language_model.dart';

class LanguageSelector extends StatelessWidget {
  final LanguageModel selectedLanguage;
  final String label;
  final Function(LanguageModel) onChanged;
  final bool showAutoDetect;

  const LanguageSelector({
    Key? key,
    required this.selectedLanguage,
    required this.label,
    required this.onChanged,
    this.showAutoDetect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLanguagePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(selectedLanguage.flag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedLanguage.nameAr,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white30, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final languages = LanguageModel.supportedLanguages;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A3E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = languages.where((l) {
              if (searchQuery.isEmpty) return true;
              return l.nameAr.contains(searchQuery) ||
                  l.nameEn.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  l.code.contains(searchQuery);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'اختر اللغة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'بحث...',
                          hintStyle: const TextStyle(color: Colors.white30),
                          prefixIcon: const Icon(Icons.search, color: Colors.white30),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) => setModalState(() => searchQuery = val),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (showAutoDetect)
                      ListTile(
                        leading: const Text('🔍', style: TextStyle(fontSize: 22)),
                        title: const Text('تلقائي', style: TextStyle(color: Colors.white)),
                        subtitle: const Text('اكتشاف تلقائي', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        onTap: () {
                          onChanged(LanguageModel.autoDetect);
                          Navigator.pop(context);
                        },
                      ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final lang = filtered[index];
                          final isSelected = lang.code == selectedLanguage.code;
                          return ListTile(
                            leading: Text(lang.flag, style: const TextStyle(fontSize: 22)),
                            title: Text(
                              lang.nameAr,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(lang.nameEn, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF8B5CF6)) : null,
                            onTap: () {
                              onChanged(lang);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
