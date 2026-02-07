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
import 'providers/exercise_provider.dart';
import 'models/workout.dart';

void main() {
  runApp(const FitnessTrackerApp());
}

class FitnessTrackerApp extends StatefulWidget {
  const FitnessTrackerApp({super.key});

  @override
  State<FitnessTrackerApp> createState() => _FitnessTrackerAppState();
}

class _FitnessTrackerAppState extends State<FitnessTrackerApp> {
  bool _isInitializing = true;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Create auth service and initialize it to load cached credentials
    _authService = AuthService();
    await _authService.init();
    
    setState(() {
      _isInitializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF1A237E),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'Loading Fitness Tracker...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => _authService,
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
        ChangeNotifierProvider<ExerciseProvider>(
          create: (context) => ExerciseProvider(
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