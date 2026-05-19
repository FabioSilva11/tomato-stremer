import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/tomato_api.dart';
import 'core/state/app_controller.dart';
import 'core/state/theme_controller.dart';
import 'core/storage/app_database.dart';
import 'features/app_shell.dart';
import 'theme/app_theme.dart';

void main() {
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
          create: (_) => AppDatabase(),
          dispose: (_, database) {
            database.close();
          },
        ),
        ChangeNotifierProvider(
          create: (context) => AppController(
            api: context.read<TomatoApi>(),
            database: context.read<AppDatabase>(),
          )..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'tomato',
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
