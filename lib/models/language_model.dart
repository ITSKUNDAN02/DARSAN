class LanguageModel {
  final String name;
  final String code;

  const LanguageModel({required this.name, required this.code});
}

const List<LanguageModel> languages = [
  LanguageModel(name: 'English', code: 'en'),
  LanguageModel(name: 'Nepali', code: 'ne'),
  LanguageModel(name: 'Hindi', code: 'hi'),
  LanguageModel(name: 'Chinese', code: 'zh'),
  LanguageModel(name: 'Japanese', code: 'ja'),
  LanguageModel(name: 'Korean', code: 'ko'),
  LanguageModel(name: 'French', code: 'fr'),
  LanguageModel(name: 'German', code: 'de'),
  LanguageModel(name: 'Spanish', code: 'es'),
  LanguageModel(name: 'Arabic', code: 'ar'),
];
