import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SentinelPayApp(),
    ),
  );
}

class SentinelPayApp extends StatelessWidget {
  const SentinelPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SentinelPay AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // AMO-LED first dark mode
      routerConfig: appRouter,
    );
  }
}
