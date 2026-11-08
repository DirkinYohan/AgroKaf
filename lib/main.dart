import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:agrokaf/core/router/app_router.dart';
import 'package:agrokaf/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(AgroKafApp.localeName);
  runApp(const ProviderScope(child: AgroKafApp()));
}

class AgroKafApp extends ConsumerWidget {
  const AgroKafApp({super.key});

  static const String localeName = 'es_CO';
  static const Locale _locale = Locale('es', 'CO');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'AgroKaf',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      routerConfig: router,
      locale: _locale,
      supportedLocales: const <Locale>[_locale, Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
