// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SentinelPay AI';

  @override
  String get dashboardTitle => 'Security Dashboard';

  @override
  String get secureVault => 'Secure Vault';

  @override
  String get scamAlerts => 'Scam Alerts';

  @override
  String get paymentAnalysis => 'Payment Analysis';

  @override
  String get aiVerdictBreakdown => 'AI VERDICT BREAKDOWN';

  @override
  String get paySecurely => 'Pay Securely';

  @override
  String get returnToDashboard => 'Return to Dashboard';

  @override
  String get blockPayee => 'Block Payee';

  @override
  String get payeeBlockedSuccess => 'Payee blocked successfully.';

  @override
  String addedToTrustlist(String payee) {
    return 'Added $payee to Trustlist';
  }

  @override
  String get proceedAnyway => 'Proceed Anyway (I trust this)';

  @override
  String get cancelPayment => 'Cancel Payment';
}
