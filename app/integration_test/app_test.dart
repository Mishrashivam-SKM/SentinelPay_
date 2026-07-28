import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sentinelpay_ai/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap through onboarding and verify dashboard',
        (tester) async {
      app.main();
      
      // Pump initial frame
      await tester.pump();

      // Wait 4 seconds for Splash Screen to navigate away
      // We use pump instead of pumpAndSettle because Splash has an infinite rotation animation
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();

      // Now we should be on OnboardingScreen. Tap 'Skip'
      final skipButton = find.text('Skip');
      expect(skipButton, findsOneWidget);
      await tester.tap(skipButton);
      
      // Wait for navigation transition
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Now on SmsPermissionScreen. Tap 'Not now (Use Demo Mode)'
      final notNowBtn = find.text('Not now (Use Demo Mode)');
      expect(notNowBtn, findsOneWidget);
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(notNowBtn);
      
      // Wait for navigation to ParseProgressScreen
      await tester.pump(const Duration(seconds: 1));
      
      // ParseProgressScreen has a progress bar and then navigates to ParsedReviewScreen automatically
      // We just pump for a long time to let it finish (e.g. 10 seconds)
      await tester.pump(const Duration(seconds: 10));
      await tester.pump();

      // Now on ParsedReviewScreen. Tap 'Looks Good'
      final looksGoodBtn = find.text('Looks Good');
      if (looksGoodBtn.evaluate().isNotEmpty) {
         await tester.tap(looksGoodBtn);
         await tester.pump(const Duration(seconds: 1));
      }

      // Now on ModeChoiceScreen. Tap 'Protect My Payments'
      final protectModeBtn = find.text('Protect My Payments');
      if (protectModeBtn.evaluate().isNotEmpty) {
         await tester.tap(protectModeBtn);
         await tester.pump(const Duration(seconds: 1));
      }
      
      // Now on Dashboard. Look for a widget that belongs to the Dashboard.
      expect(find.textContaining('Recent Scans'), findsWidgets);
      
    });
  });
}
