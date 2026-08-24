enum Environment { dev, staging, prod }

class AppConfig {
  final Environment environment;
  final String appName;
  final String apiBaseUrl;
  final String verificationBaseUrl;
  final String privacyPolicyUrl;
  final String termsUrl;
  final bool enableDebugLogs;

  const AppConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.verificationBaseUrl,
    required this.privacyPolicyUrl,
    required this.termsUrl,
    required this.enableDebugLogs,
  });

  static const AppConfig current = AppConfig(
    environment: Environment.prod,
    appName: 'Techaa Purinjikoo',
    apiBaseUrl: 'https://techaa-purinjikoo.onrender.com/api/v1',
    verificationBaseUrl: 'https://techaa-purinjikoo.onrender.com/api/v1/certificates/verify',
    privacyPolicyUrl: 'https://techaa-purinjikoo.vercel.app/privacy',
    termsUrl: 'https://techaa-purinjikoo.vercel.app/terms',
    enableDebugLogs: false,
  );
}
