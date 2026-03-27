class Voice {
  final String name;
  final String locale;
  final String language;
  final String? country;
  final double? pitch;
  final double? rate;
  final bool isDefault;
  
  const Voice({
    required this.name,
    required this.locale,
    required this.language,
    this.country,
    this.pitch,
    this.rate,
    this.isDefault = false,
  });
  
  @override
  String toString() => name;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Voice &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          locale == other.locale;
  
  @override
  int get hashCode => name.hashCode ^ locale.hashCode;
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'locale': locale,
    'language': language,
    'country': country,
    'pitch': pitch,
    'rate': rate,
    'isDefault': isDefault,
  };
  
  factory Voice.fromJson(Map<String, dynamic> json) => Voice(
    name: json['name'],
    locale: json['locale'],
    language: json['language'],
    country: json['country'],
    pitch: json['pitch']?.toDouble(),
    rate: json['rate']?.toDouble(),
    isDefault: json['isDefault'] ?? false,
  );
  
  Voice copyWith({
    String? name,
    String? locale,
    String? language,
    String? country,
    double? pitch,
    double? rate,
    bool? isDefault,
  }) {
    return Voice(
      name: name ?? this.name,
      locale: locale ?? this.locale,
      language: language ?? this.language,
      country: country ?? this.country,
      pitch: pitch ?? this.pitch,
      rate: rate ?? this.rate,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class VoicePreferences {
  final Map<String, Voice> languageVoices;
  final double globalPitch;
  final double globalRate;
  final bool autoSelectVoice;
  
  const VoicePreferences({
    this.languageVoices = const {},
    this.globalPitch = 1.0,
    this.globalRate = 0.5,
    this.autoSelectVoice = true,
  });
  
  Map<String, dynamic> toJson() => {
    'languageVoices': languageVoices.map(
      (key, voice) => MapEntry(key, voice.toJson()),
    ),
    'globalPitch': globalPitch,
    'globalRate': globalRate,
    'autoSelectVoice': autoSelectVoice,
  };
  
  factory VoicePreferences.fromJson(Map<String, dynamic> json) {
    final languageVoicesJson = json['languageVoices'] as Map<String, dynamic>? ?? {};
    final languageVoices = languageVoicesJson.map(
      (key, value) => MapEntry(key, Voice.fromJson(value as Map<String, dynamic>)),
    );
    
    return VoicePreferences(
      languageVoices: languageVoices,
      globalPitch: json['globalPitch']?.toDouble() ?? 1.0,
      globalRate: json['globalRate']?.toDouble() ?? 0.5,
      autoSelectVoice: json['autoSelectVoice'] ?? true,
    );
  }
  
  VoicePreferences copyWith({
    Map<String, Voice>? languageVoices,
    double? globalPitch,
    double? globalRate,
    bool? autoSelectVoice,
  }) {
    return VoicePreferences(
      languageVoices: languageVoices ?? this.languageVoices,
      globalPitch: globalPitch ?? this.globalPitch,
      globalRate: globalRate ?? this.globalRate,
      autoSelectVoice: autoSelectVoice ?? this.autoSelectVoice,
    );
  }
  
  Voice? getVoiceForLanguage(String languageCode) {
    return languageVoices[languageCode];
  }
  
  VoicePreferences setVoiceForLanguage(String languageCode, Voice voice) {
    final newLanguageVoices = Map<String, Voice>.from(languageVoices);
    newLanguageVoices[languageCode] = voice;
    
    return copyWith(languageVoices: newLanguageVoices);
  }
}