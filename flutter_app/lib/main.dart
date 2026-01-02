import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'screens/workout_list_screen.dart';
import 'screens/template_list_screen.dart';
import 'screens/create_workout_screen.dart';
import 'screens/create_template_screen.dart';
import 'screens/workout_detail_screen.dart';
import 'services/api_service.dart';
import 'providers/workout_provider.dart';
import 'models/workout.dart';
import 'models/workout_template.dart';

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
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/workouts':
              return MaterialPageRoute(builder: (_) => const WorkoutListScreen());
            case '/templates':
              return MaterialPageRoute(builder: (_) => const TemplateListScreen());
            case '/create-workout':
              final args = settings.arguments as Map<String, dynamic>?;
              final workoutToEdit = args?['workoutToEdit'] as Workout?;
              final template = args?['template'] as WorkoutTemplate?;
              return MaterialPageRoute(
                builder: (_) => CreateWorkoutScreen(
                  workoutToEdit: workoutToEdit,
                  template: template,
                ),
              );
            case '/create-template':
              final args = settings.arguments as Map<String, dynamic>?;
              final templateToEdit = args?['templateToEdit'] as WorkoutTemplate?;
              return MaterialPageRoute(
                builder: (_) => CreateTemplateScreen(templateToEdit: templateToEdit),
              );
            case '/workout-detail':
              final args = settings.arguments as Map<String, dynamic>?;
              final workout = args?['workout'] as Workout?;
              if (workout == null) {
                // If no workout provided, navigate back or show error
                return MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Error')),
                    body: const Center(
                      child: Text('No workout data provided'),
                    ),
                  ),
                );
              }
              return MaterialPageRoute(
                builder: (_) => WorkoutDetailScreen(workout: workout),
              );
            default:
              return MaterialPageRoute(builder: (_) => const WorkoutListScreen());
          }
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
