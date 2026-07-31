import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workmanager/workmanager.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/ml/behaviour_intelligence.dart';
import 'features/ml/retrain_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final bi = BehaviourIntelligence();
      // In a real app we'd load the serialized model state from secure storage here.
      // For this audit remediation, we just trigger a force retrain in the background
      // to keep the model weights fresh.
      final retrainService = RetrainService(bi);
      await retrainService.forceRetrain();
      
      // Save model state to secure storage
      const storage = FlutterSecureStorage();
      await storage.write(key: 'bi_model_state', value: jsonEncode(bi.toMap()));
      
      return Future.value(true);
    } catch (err) {
      debugPrint(err.toString());
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase using environment variables
  try {
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    
    if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
    } else {
      debugPrint('Supabase init skipped: SUPABASE_URL or SUPABASE_ANON_KEY not provided via --dart-define');
    }
  } catch (e) {
    debugPrint('Supabase init failed: $e');
  }
  
  try {
    Workmanager().initialize(
      callbackDispatcher,
    );
    // Register periodic task every 24 hours
    Workmanager().registerPeriodicTask(
      "1",
      "incremental_retrain_task",
      frequency: const Duration(hours: 24),
    );
  } catch (e) {
    debugPrint('Workmanager init failed: $e');
  }
  
  runApp(
    const ProviderScope(
      child: SentinelPayApp(),
    ),
  );
}

class SentinelPayApp extends StatefulWidget {
  const SentinelPayApp({super.key});

  @override
  State<SentinelPayApp> createState() => _SentinelPayAppState();
}

class _SentinelPayAppState extends State<SentinelPayApp> with WidgetsBindingObserver {
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedTime != null) {
        final diff = DateTime.now().difference(_pausedTime!);
        if (diff.inSeconds > 30) {
          appRouter.go('/auth');
        }
        _pausedTime = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SentinelPay AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // AMO-LED first dark mode
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
      ],
      routerConfig: appRouter,
    );
  }
}
