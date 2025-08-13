class AppConfig {
  static const String sendbirdAppId = String.fromEnvironment(
    'SENDBIRD_APP_ID',
    defaultValue: '',
  );

  static bool get isConfigured => sendbirdAppId.isNotEmpty;
}
