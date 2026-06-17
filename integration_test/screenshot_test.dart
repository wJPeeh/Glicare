// Integration test que captura screenshots de todas as telas do Glicare.
//
// Como rodar (precisa de um device/emulador conectado):
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshot_test.dart
//
// As imagens são salvas em ./screenshots/<nome>.png pelo driver.
//
// Observações sobre a estratégia:
//  * O `redirect` do app_router redireciona usuário LOGADO que tenta abrir
//    /login ou /signup para o /dashboard. Por isso as telas "públicas"
//    (welcome/login/signup) são capturadas numa fase DESLOGADA, e o restante
//    numa fase LOGADA + onboarded. Assim nenhuma tela é perdida.
//  * Não usamos `pumpAndSettle`: telas com CircularProgressIndicator têm
//    animação infinita e fariam o pumpAndSettle estourar o timeout. Em vez
//    disso bombeamos frames com durações fixas.

import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:glicare/core/router/app_router.dart';
import 'package:glicare/core/theme/app_theme.dart';
import 'package:glicare/features/auth/presentation/auth_providers.dart';
import 'package:glicare/features/profile/data/user_profile.dart';
import 'package:glicare/features/profile/presentation/profile_providers.dart';
import 'package:glicare/features/splash/presentation/splash_page.dart';
import 'package:glicare/firebase_options.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // O app real depende do Firebase (Realtime Database, Storage etc.). Sem
    // inicializar, os providers de dados lançam exceção e as telas não montam.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await initializeDateFormatting('pt_BR');
  });

  testWidgets('captura screenshots de todas as telas do Glicare',
      (tester) async {
    // No Android é obrigatório converter a surface do Flutter para imagem
    // antes de chamar takeScreenshot. Em iOS/web não é necessário.
    if (!kIsWeb && Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    // ------------------------------------------------------------------
    // Fase 1 — Telas públicas (usuário DESLOGADO)
    // ------------------------------------------------------------------
    final loggedOut = ProviderContainer(
      overrides: [
        authStateChangesProvider
            .overrideWith((ref) => Stream<User?>.value(null)),
        userProfileProvider
            .overrideWith((ref) => Stream.value(const UserProfile())),
      ],
    );
    addTearDown(loggedOut.dispose);

    await _pumpApp(tester, loggedOut);
    final publicRouter = loggedOut.read(appRouterProvider);

    // ignore: avoid_print
    print('[DIAG] auth=${loggedOut.read(authStateChangesProvider)} '
        'profile=${loggedOut.read(userProfileProvider)} '
        'loc=${publicRouter.routerDelegate.currentConfiguration.uri} '
        'splash=${find.byType(SplashPage).evaluate().isNotEmpty}');

    const publicScreens = <(String, String)>[
      (AppRoutes.welcome, '00_welcome'),
      (AppRoutes.login, '01_login'),
      (AppRoutes.signup, '02_signup'),
    ];
    for (final (route, name) in publicScreens) {
      await _capture(tester, binding, publicRouter, route, name);
    }

    // ------------------------------------------------------------------
    // Fase 2 — Telas autenticadas (usuário LOGADO + onboarded)
    // ------------------------------------------------------------------
    final mockUser = MockUser(
      uid: 'screenshot-uid',
      email: 'teste@glicare.app',
      displayName: 'Paciente Teste',
    );
    final loggedIn = ProviderContainer(
      overrides: [
        authStateChangesProvider
            .overrideWith((ref) => Stream<User?>.value(mockUser)),
        // notificationsOnboarded: true para o redirect não prender a navegação
        // na tela de onboarding de notificações.
        userProfileProvider.overrideWith(
          (ref) => Stream.value(
            const UserProfile(notificationsOnboarded: true),
          ),
        ),
      ],
    );
    addTearDown(loggedIn.dispose);

    await _pumpApp(tester, loggedIn);
    final router = loggedIn.read(appRouterProvider);

    const authedScreens = <(String, String)>[
      (AppRoutes.dev, '03_dev_index'),
      (AppRoutes.dashboard, '04_dashboard'),
      (AppRoutes.medicationRegister, '05_medication_register'),
      (AppRoutes.medicationHistory, '06_medication_history'),
      (AppRoutes.mealLog, '07_meal_log'),
      (AppRoutes.mealImpact, '08_meal_impact'),
      (AppRoutes.evolutionCharts, '09_evolution_charts'),
      (AppRoutes.smartAlerts, '10_smart_alerts'),
      (AppRoutes.susIntegration, '11_sus_integration'),
      (AppRoutes.glucoseRegister, '12_glucose_register'),
      (AppRoutes.activityRegister, '13_activity_register'),
      (AppRoutes.profile, '14_profile'),
      (AppRoutes.terms, '15_terms'),
      (AppRoutes.privacy, '16_privacy'),
    ];
    for (final (route, name) in authedScreens) {
      await _capture(tester, binding, router, route, name);
    }
  });
}

/// Monta o app usando um container do Riverpod já com os overrides aplicados.
Future<void> _pumpApp(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        title: 'Glicare',
        theme: AppTheme.light(),
        themeMode: ThemeMode.light,
        routerConfig: container.read(appRouterProvider),
      ),
    ),
  );

  // Os StreamProviders sobrescritos (`Stream.value`) só saem de AsyncLoading
  // quando o event loop REAL roda. Nem `pump` nem `runAsync` sozinhos disparam
  // a microtask de emissão; awaitar o `.future` do provider dentro de runAsync
  // força a assinatura a emitir. Sem isso o `redirect` fica eternamente na
  // SplashPage (que mostra "isLoading"). A assinatura é mantida viva pelo
  // _AuthRouterListenable do router, então o valor persiste como `data`.
  await tester.runAsync(() async {
    await container.read(authStateChangesProvider.future);
    await container.read(userProfileProvider.future);
  });

  await _settle(tester);
}

/// Navega para [route], deixa a tela estabilizar e tira a screenshot [name].
Future<void> _capture(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  GoRouter router,
  String route,
  String name,
) async {
  router.go(route);
  await _settle(tester);
  await binding.takeScreenshot(name);
}

/// Estabiliza a tela antes da screenshot.
///
/// Usa [WidgetTester.runAsync] para deixar o event loop REAL rodar — sem isso
/// os streams sobrescritos (auth/profile via `Stream.value`) e as chamadas
/// async do Firebase não emitem, e o `redirect` do router fica preso na
/// SplashPage (que mostra "isLoading").
///
/// Não usa `pumpAndSettle`: telas com CircularProgressIndicator têm animação
/// infinita e estourariam o timeout. Em vez disso bombeia frames manualmente.
Future<void> _settle(WidgetTester tester) async {
  // Deixa microtasks/timers/I-O reais concluírem (emissão de streams, redirect,
  // carregamento inicial de dados) + o delay de 1500ms pedido por tela.
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
  });
  // Renderiza o estado resultante em alguns frames.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}
