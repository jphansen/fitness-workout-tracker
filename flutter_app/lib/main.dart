import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'screens/login_screen.dart';
import 'screens/workout_list_screen.dart';
import 'screens/exercise_list_screen.dart';
import 'screens/create_workout_screen.dart';
import 'screens/workout_detail_screen.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'providers/workout_provider.dart';
import 'models/workout.dart';

void main() {
  runApp(const FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
          dispose: (_, authService) => authService.dispose(),
        ),
        Provider<ApiService>(
          create: (context) => ApiService(
            authService: Provider.of<AuthService>(context, listen: false),
          ),
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
        home: Consumer<AuthService>(
          builder: (context, authService, child) {
            // Check if user is logged in
            if (authService.isLoggedIn) {
              return const WorkoutListScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/workouts':
              return MaterialPageRoute(builder: (_) => const WorkoutListScreen());
            case '/exercises':
              return MaterialPageRoute(builder: (_) => const ExerciseListScreen());
            case '/create-workout':
              final args = settings.arguments as Map<String, dynamic>?;
              final workoutToEdit = args?['workoutToEdit'] as Workout?;
              return MaterialPageRoute(
                builder: (_) => CreateWorkoutScreen(
                  workoutToEdit: workoutToEdit,
                ),
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
              return MaterialPageRoute(builder: (_) => const LoginScreen());
          }
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
