class ApiConfig {
  ApiConfig._();

  /// OpenAI API Key for Dhanda AI SaaS.
  /// Provide at build/run time via `--dart-define=OPENAI_API_KEY=...`
  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static const String openAiChatEndpoint =
      'https://api.openai.com/v1/chat/completions';
  static const String openAiModel = 'gpt-4o-mini';

  /// Google Business Profile (GMB) OAuth 2.0 Scope for Multi-Tenant SaaS users
  static const String gmbManageScope =
      'https://www.googleapis.com/auth/business.manage';

  /// Official Google Business Profile API Base URLs
  static const String gmbAccountManagementBaseUrl =
      'https://mybusinessaccountmanagement.googleapis.com/v1';
  static const String gmbBusinessInfoBaseUrl =
      'https://mybusinessbusinessinformation.googleapis.com/v1';
  static const String gmbV4BaseUrl = 'https://mybusiness.googleapis.com/v4';
  static const String gmbPerformanceBaseUrl =
      'https://businessprofileperformance.googleapis.com/v1';
}
