import 'package:flutter/material.dart';
import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/router/app_router.dart';
import 'package:agrokaf/core/theme/app_theme.dart';

void main() {
  runApp(const AgroKafApp());
}

class AgroKafApp extends StatelessWidget {
  const AgroKafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroKaf',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
