import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase (Placeholder keys to be replaced by user)
  try {
    await Supabase.initialize(
      url: 'https://placeholder-project.supabase.co',
      anonKey: 'placeholder-anon-key',
    );
  } catch (e) {
    debugPrint('Supabase init failed (probably placeholder keys)');
  }
  
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
