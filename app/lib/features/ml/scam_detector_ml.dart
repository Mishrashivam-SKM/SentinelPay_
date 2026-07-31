import '../../core/data/models/scam_message.dart';
import 'package:uuid/uuid.dart';

class ScamDetectorML {
  static final _uuid = const Uuid();

  // Keyword patterns for scam heuristics
  static final _phishingPatterns = [
    RegExp(r'kyc.*suspended', caseSensitive: false),
    RegExp(r'account.*blocked', caseSensitive: false),
    RegExp(r'pan.*update', caseSensitive: false),
    RegExp(r'aadhar.*link', caseSensitive: false),
    RegExp(r'electricity.*disconnect', caseSensitive: false),
    RegExp(r'click.*link.*http', caseSensitive: false),
    RegExp(r'won.*lottery', caseSensitive: false),
    RegExp(r'claim.*prize', caseSensitive: false),
  ];

  static final _otpPatterns = [
    RegExp(r'otp', caseSensitive: false),
    RegExp(r'one\s?time\s?password', caseSensitive: false),
    RegExp(r'never.*share', caseSensitive: false),
  ];

  static final _suspiciousSenderPatterns = [
    RegExp(r'^\+?\d+$'), // Pure numeric senders not typical for banks
    RegExp(r'^BX-'), // Random bulk SMS senders sometimes used for spam
  ];

  /// Evaluates an SMS and returns a ScamMessage if it crosses the threshold.
  ScamMessage? evaluateMessage(String sender, String body, DateTime timestamp) {
    double scamScore = 0.0;
    String scamType = 'unknown';

    final lowerBody = body.toLowerCase();
    
    // Check phishing patterns
    for (final pattern in _phishingPatterns) {
      if (pattern.hasMatch(lowerBody)) {
        scamScore += 0.5;
        scamType = 'phishing';
      }
    }

    // Check OTP patterns combined with suspicious context
    bool hasOtp = false;
    for (final pattern in _otpPatterns) {
      if (pattern.hasMatch(lowerBody)) {
        hasOtp = true;
        break;
      }
    }

    if (hasOtp) {
      // OTPs alone are not scams, but OTPs from unknown/numeric numbers or containing URLs are risky
      if (lowerBody.contains('http')) {
        scamScore += 0.6;
        scamType = 'otp_trap';
      }
      for (final pattern in _suspiciousSenderPatterns) {
        if (pattern.hasMatch(sender)) {
          scamScore += 0.4;
          scamType = 'otp_trap';
        }
      }
    }

    // Normalize score
    scamScore = scamScore > 1.0 ? 1.0 : scamScore;

    // Threshold for flagging
    if (scamScore >= 0.5) {
      return ScamMessage(
        id: _uuid.v4(),
        sender: sender,
        body: body,
        timestamp: timestamp,
        scamType: scamType,
        confidenceScore: scamScore,
      );
    }

    return null;
  }
}
