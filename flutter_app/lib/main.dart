import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'screens/workout_list_screen.dart';
import 'services/api_service.dart';
import 'providers/workout_provider.dart';

void main() {
  runApp(const FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, apiService) => apiService.dispose(),
        ),
        ChangeNotifierProvider<WorkoutProvider>(
          create: (context) => WorkoutProvider(
            apiService: Provider.of<ApiService>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Fitness Workout Tracker',
        theme: FlexColorScheme.dark(
          scheme: FlexScheme.deepBlue,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 15,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 20,
            blendOnColors: false,
            useTextTheme: true,
            useM2StyleDividerInM3: true,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
        ).toTheme,
        darkTheme: FlexColorScheme.dark(
          scheme: FlexScheme.deepBlue,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 15,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 20,
            blendOnColors: false,
            useTextTheme: true,
            useM2StyleDividerInM3: true,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
        ).toTheme,
        themeMode: ThemeMode.dark,
        home: const WorkoutListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
