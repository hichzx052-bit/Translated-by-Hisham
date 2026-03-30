import '../utils/constants.dart';

class LanguageModel {
  final String code;
  final String name;
  final String flag;
  final bool isRtl;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.flag,
    this.isRtl = false,
  });

  // Alias for compatibility with widgets
  String get nativeName => name;

  factory LanguageModel.fromCode(String code) {
    return LanguageModel(
      code: code,
      name: AppConstants.supportedLanguages[code] ?? code.toUpperCase(),
      flag: AppConstants.languageFlags[code] ?? '🌍',
      isRtl: AppConstants.isRtl(code),
    );
  }

  // Alias used by screens
  static List<LanguageModel> get supportedLanguages => allWithAuto;

  static List<LanguageModel> get all {
    return AppConstants.supportedLanguages.entries
        .where((e) => e.key != 'auto')
        .map((e) => LanguageModel(
              code: e.key,
              name: e.value,
              flag: AppConstants.languageFlags[e.key] ?? '🌍',
              isRtl: AppConstants.isRtl(e.key),
            ))
        .toList();
  }

  static List<LanguageModel> get allWithAuto {
    return AppConstants.supportedLanguages.entries
        .map((e) => LanguageModel(
              code: e.key,
              name: e.value,
              flag: AppConstants.languageFlags[e.key] ?? '🌍',
              isRtl: AppConstants.isRtl(e.key),
            ))
        .toList();
  }

  static LanguageModel get autoDetect => const LanguageModel(
        code: 'auto',
        name: 'Auto Detect',
        flag: '🌍',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  // Alias getters for screens compatibility
  static List<LanguageModel> get supportedLanguages => allWithAuto;

  @override
  String toString() => 'LanguageModel($code: $name)';
}
