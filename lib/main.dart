import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'gen_l10n/app_localizations.dart';
import 'core/ads/ad_manager.dart';
import 'core/api/streambert_api.dart';
import 'core/api/tomato_api.dart';
import 'core/notifications/notification_service.dart';
import 'core/state/app_controller.dart';
import 'core/state/theme_controller.dart';
import 'core/storage/app_database.dart';
import 'features/app_shell.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar gerenciador de anúncios (AdMob + Unity Ads)
  // PRODUÇÃO: useTestAds: false
  await AdManager().initialize(useTestAds: false);
  
  // Inicializar Notificações
  await NotificationService().initialize();
  
  // Inicializar Worker de Background
  await EpisodeCheckService.initialize();
  
  runApp(const TomatoStreamingApp());
}

class TomatoStreamingApp extends StatelessWidget {
  const TomatoStreamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => TomatoApi(),
          dispose: (_, api) => api.dispose(),
        ),
        Provider(
          create: (_) => StreambertApi(),
          dispose: (_, api) => api.dispose(),
        ),
        Provider(
          create: (_) => AppDatabase(),
          dispose: (_, database) {
            database.close();
          },
        ),
        ChangeNotifierProvider(
          create: (context) => AppController(
            api: context.read<TomatoApi>(),
            streambertApi: context.read<StreambertApi>(),
            database: context.read<AppDatabase>(),
          )..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Tomato',
            
            // Internacionalização
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('pt', ''), // Portuguese
            ],
            
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeController.mode,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
