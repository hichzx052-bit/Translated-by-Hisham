class VoiceModel {
  final String id;
  final String name;
  final String nameAr;
  final String gender;
  final String locale;
  final String description;
  final String emoji;

  const VoiceModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.gender,
    required this.locale,
    required this.description,
    required this.emoji,
  });

  static List<VoiceModel> get availableVoices => defaultVoices;
  static List<VoiceModel> get defaultVoices => [
        const VoiceModel(
          id: 'male_deep',
          name: 'Deep Voice',
          nameAr: 'صوت عميق',
          gender: 'male',
          locale: 'en-US',
          description: 'Deep, authoritative male voice',
          emoji: '🎙️',
        ),
        const VoiceModel(
          id: 'male_clear',
          name: 'Clear Voice',
          nameAr: 'صوت واضح',
          gender: 'male',
          locale: 'en-US',
          description: 'Clear, professional male voice',
          emoji: '🔊',
        ),
        const VoiceModel(
          id: 'female_soft',
          name: 'Soft Voice',
          nameAr: 'صوت ناعم',
          gender: 'female',
          locale: 'en-US',
          description: 'Soft, warm female voice',
          emoji: '🌸',
        ),
        const VoiceModel(
          id: 'female_clear',
          name: 'Crystal Voice',
          nameAr: 'صوت كريستال',
          gender: 'female',
          locale: 'en-US',
          description: 'Clear, crisp female voice',
          emoji: '💎',
        ),
        const VoiceModel(
          id: 'neutral',
          name: 'Neutral Voice',
          nameAr: 'صوت محايد',
          gender: 'neutral',
          locale: 'en-US',
          description: 'Gender-neutral, balanced voice',
          emoji: '⚡',
        ),
        const VoiceModel(
          id: 'arabic_male',
          name: 'Arabic Male',
          nameAr: 'عربي ذكر',
          gender: 'male',
          locale: 'ar-SA',
          description: 'Native Arabic male voice',
          emoji: '🌙',
        ),
        const VoiceModel(
          id: 'arabic_female',
          name: 'Arabic Female',
          nameAr: 'عربية أنثى',
          gender: 'female',
          locale: 'ar-SA',
          description: 'Native Arabic female voice',
          emoji: '🌹',
        ),
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'gender': gender,
        'locale': locale,
        'description': description,
        'emoji': emoji,
      };

  factory VoiceModel.fromJson(Map<String, dynamic> json) => VoiceModel(
        id: json['id'],
        name: json['name'],
        nameAr: json['nameAr'],
        gender: json['gender'],
        locale: json['locale'],
        description: json['description'],
        emoji: json['emoji'],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
