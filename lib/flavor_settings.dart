class FlavorSettings {
  final String apiBaseUrl;

  FlavorSettings.dev() : apiBaseUrl = 'https://dev.flutter-flavors.chwe.at';

  FlavorSettings.live() : apiBaseUrl = 'https://flutter-flavors.chwe.at';
}
