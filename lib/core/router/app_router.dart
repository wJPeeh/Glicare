import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity_log/presentation/activity_register_page.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/dev/presentation/dev_index_page.dart';
import '../../features/evolution_charts/presentation/evolution_charts_page.dart';
import '../../features/glucose_log/presentation/glucose_register_page.dart';
import '../../features/login/presentation/login_page.dart';
import '../../features/meal_impact/presentation/meal_impact_page.dart';
import '../../features/meal_log/presentation/meal_history_page.dart';
import '../../features/meal_log/presentation/meal_log_page.dart';
import '../../features/medication_history/presentation/medication_history_page.dart';
import '../../features/medication_register/presentation/medication_register_page.dart';
import '../../features/privacy_policy/presentation/privacy_policy_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/signup/presentation/signup_page.dart';
import '../../features/smart_alerts/presentation/smart_alerts_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/sus_integration/presentation/sus_integration_page.dart';
import '../../features/terms/presentation/terms_page.dart';
import '../../features/welcome/presentation/welcome_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String medicationRegister = '/medication/register';
  static const String medicationHistory = '/medication/history';
  static const String glucoseRegister = '/glucose/register';
  static const String activityRegister = '/activity/register';
  static const String mealLog = '/meal/log';
  static const String mealHistory = '/meal/history';
  static const String mealImpact = '/meal/impact';
  static const String evolutionCharts = '/charts';
  static const String smartAlerts = '/alerts';
  static const String susIntegration = '/sus';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String dev = '/dev';

  static const Set<String> publicRoutes = {
    welcome,
    login,
    signup,
    terms,
    privacy,
    dev,
  };
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthRouterListenable(ref);
  ref.onDispose(listenable.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final location = state.matchedLocation;

      if (authState.isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final user = authState.asData?.value;
      final loggedIn = user != null;

      if (location == AppRoutes.splash) {
        return loggedIn ? AppRoutes.dashboard : AppRoutes.welcome;
      }

      final isPublic = AppRoutes.publicRoutes.contains(location);
      final isAuthScreen =
          location == AppRoutes.login || location == AppRoutes.signup;

      if (!loggedIn && !isPublic) {
        return AppRoutes.welcome;
      }
      if (loggedIn && isAuthScreen) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.medicationRegister,
        name: 'medicationRegister',
        builder: (context, state) => const MedicationRegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.medicationHistory,
        name: 'medicationHistory',
        builder: (context, state) => const MedicationHistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.glucoseRegister,
        name: 'glucoseRegister',
        builder: (context, state) => const GlucoseRegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.activityRegister,
        name: 'activityRegister',
        builder: (context, state) => const ActivityRegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.mealLog,
        name: 'mealLog',
        builder: (context, state) => const MealLogPage(),
      ),
      GoRoute(
        path: AppRoutes.mealHistory,
        name: 'mealHistory',
        builder: (context, state) => const MealHistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.mealImpact,
        name: 'mealImpact',
        builder: (context, state) => const MealImpactPage(),
      ),
      GoRoute(
        path: AppRoutes.evolutionCharts,
        name: 'evolutionCharts',
        builder: (context, state) => const EvolutionChartsPage(),
      ),
      GoRoute(
        path: AppRoutes.smartAlerts,
        name: 'smartAlerts',
        builder: (context, state) => const SmartAlertsPage(),
      ),
      GoRoute(
        path: AppRoutes.susIntegration,
        name: 'susIntegration',
        builder: (context, state) => const SusIntegrationPage(),
      ),
      GoRoute(
        path: AppRoutes.terms,
        name: 'terms',
        builder: (context, state) => const TermsPage(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        name: 'privacy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: AppRoutes.dev,
        name: 'dev',
        builder: (context, state) => const DevIndexPage(),
      ),
    ],
  );
});

class _AuthRouterListenable extends ChangeNotifier {
  _AuthRouterListenable(Ref ref) {
    _sub = ref.listen<AsyncValue<User?>>(
      authStateChangesProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
  }

  late final ProviderSubscription<AsyncValue<User?>> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
