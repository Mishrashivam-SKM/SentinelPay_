// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'सेंटिनलपे एआई';

  @override
  String get dashboardTitle => 'सुरक्षा डैशबोर्ड';

  @override
  String get secureVault => 'सुरक्षित तिजोरी';

  @override
  String get scamAlerts => 'स्कैम अलर्ट';

  @override
  String get paymentAnalysis => 'भुगतान विश्लेषण';

  @override
  String get aiVerdictBreakdown => 'एआई निर्णय विवरण';

  @override
  String get paySecurely => 'सुरक्षित रूप से भुगतान करें';

  @override
  String get returnToDashboard => 'डैशबोर्ड पर वापस जाएं';

  @override
  String get blockPayee => 'प्राप्तकर्ता को ब्लॉक करें';

  @override
  String get payeeBlockedSuccess =>
      'प्राप्तकर्ता को सफलतापूर्वक ब्लॉक किया गया।';

  @override
  String addedToTrustlist(String payee) {
    return '$payee को ट्रस्टलिस्ट में जोड़ा गया';
  }

  @override
  String get proceedAnyway => 'फिर भी आगे बढ़ें (मुझे इस पर भरोसा है)';

  @override
  String get cancelPayment => 'भुगतान रद्द करें';
}
