import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/sms_permission/sms_permission_screen.dart';
import '../../features/parse_progress/parse_progress_screen.dart';
import '../../features/parse_progress/parsed_review_screen.dart';
import '../../features/onboarding/mode_choice_screen.dart';
import '../../features/auth/pin_setup_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/analysis/handoff_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/dashboard/scam_alerts_screen.dart';
import '../../features/scanner/scanner_screen.dart';
import '../../features/analysis/analysis_screen.dart';
import '../../features/transaction_detail/transaction_detail_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/blocklist_screen.dart';
import '../../features/settings/trustlist_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/pin_setup',
      builder: (context, state) => const PinSetupScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/sms_permission',
      builder: (context, state) => const SmsPermissionScreen(),
    ),
    GoRoute(
      path: '/parse_progress',
      builder: (context, state) => const ParseProgressScreen(),
    ),
    GoRoute(
      path: '/parsed_review',
      builder: (context, state) => const ParsedReviewScreen(),
    ),
    GoRoute(
      path: '/mode_choice',
      builder: (context, state) => const ModeChoiceScreen(),
    ),
    GoRoute(
      path: '/handoff',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final uri = extra?['upiUri'] as String?;
        final verdict = extra?['verdict'] as String?;
        return HandoffScreen(upiUri: uri, verdict: verdict);
      },
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final syncingUri = extra?['syncingUri'] as String?;
        return CustomTransitionPage(
          key: state.pageKey,
          child: DashboardScreen(syncingUri: syncingUri),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/scan',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ScannerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/analysis',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AnalysisScreen(
          mockAssessment: extra?['assessment'],
          upiUri: extra?['upiUri'],
        );
      },
    ),
    GoRoute(
      path: '/transaction_detail',
      builder: (context, state) => const TransactionDetailScreen(),
    ),
    GoRoute(
      path: '/history',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HistoryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/scam_alerts',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ScamAlertsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/blocklist',
      builder: (context, state) => const BlocklistScreen(),
    ),
    GoRoute(
      path: '/trustlist',
      builder: (context, state) => const TrustlistScreen(),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
  ],
);
