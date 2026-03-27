class Language {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  
  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
  
  @override
  String toString() => '$flag $nativeName';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language &&
          runtimeType == other.runtimeType &&
          code == other.code;
  
  @override
  int get hashCode => code.hashCode;
  
  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'nativeName': nativeName,
    'flag': flag,
  };
  
  factory Language.fromJson(Map<String, dynamic> json) => Language(
    code: json['code'],
    name: json['name'],
    nativeName: json['nativeName'],
    flag: json['flag'],
  );
}

class SupportedLanguages {
  static const List<Language> all = [
    Language(code: 'auto', name: 'Auto Detect', nativeName: 'تلقائي', flag: '🔍'),
    Language(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
    Language(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    Language(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    Language(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    Language(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    Language(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷'),
    Language(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳'),
    Language(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
    Language(code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
    Language(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
    Language(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹'),
    Language(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹'),
    Language(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    Language(code: 'ur', name: 'Urdu', nativeName: 'اردو', flag: '🇵🇰'),
    Language(code: 'fa', name: 'Persian', nativeName: 'فارسی', flag: '🇮🇷'),
    Language(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', flag: '🇮🇩'),
    Language(code: 'th', name: 'Thai', nativeName: 'ไทย', flag: '🇹🇭'),
    Language(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt', flag: '🇻🇳'),
    Language(code: 'nl', name: 'Dutch', nativeName: 'Nederlands', flag: '🇳🇱'),
    Language(code: 'pl', name: 'Polish', nativeName: 'Polski', flag: '🇵🇱'),
    Language(code: 'sv', name: 'Swedish', nativeName: 'Svenska', flag: '🇸🇪'),
    Language(code: 'no', name: 'Norwegian', nativeName: 'Norsk', flag: '🇳🇴'),
    Language(code: 'da', name: 'Danish', nativeName: 'Dansk', flag: '🇩🇰'),
    Language(code: 'fi', name: 'Finnish', nativeName: 'Suomi', flag: '🇫🇮'),
  ];
  
  static Language getByCode(String code) {
    return all.firstWhere(
      (lang) => lang.code == code,
      orElse: () => all.first,
    );
  }
  
  static List<Language> getPopular() {
    return all.where((lang) => [
      'ar', 'en', 'fr', 'es', 'de', 'tr', 'zh', 'ja', 'ko', 'ru'
    ].contains(lang.code)).toList();
  }
  
  static List<Language> getAllExceptAuto() {
    return all.where((lang) => lang.code != 'auto').toList();
  }
}