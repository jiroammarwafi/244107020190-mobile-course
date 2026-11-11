import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';

final container = ProviderContainer();

class AuthListenable extends ChangeNotifier {
  AuthListenable(ProviderContainer container) {
    container.listen(authStateProvider, (prev, next) => notifyListeners());
  }
}

final router = GoRouter(
  refreshListenable: AuthListenable(container),
  redirect: (context, state) {
    final loggedIn = container.read(authStateProvider).value ?? false;
    final goingLogin = state.matchedLocation == '/login';

    if (!loggedIn && !goingLogin) return '/login';
    if (loggedIn && goingLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/pengumuman/:id',
      builder: (context, state) =>
          AnnouncementPage(id: state.pathParameters['id'] ?? ''),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inisialisasi notifikasi lokal & minta izin pengguna
  try {
    await requestNotificationPermission();
    await initLocalNotifications();
  } catch (e) {
    debugPrint('Gagal inisialisasi notifikasi: $e');
  }

  // Ambil FCM Token dan daftarkan topik
  try {
    await initFcmToken(onToken: (token) async {
      debugPrint('=== FCM TOKEN MAHASISWA ===\n$token\n===========================');
      // Jika backend API kampus sudah aktif, Anda dapat mengaktifkan:
      // final dio = container.read(dioProvider);
      // await dio.post('/devices', data: {'fcm_token': token, 'platform': 'android'});
    });
  } catch (e) {
    debugPrint('=== FCM TOKEN GAGAL DIGENERATE ===');
    debugPrint('Penyebab: $e');
    debugPrint('Catatan: Emulator Anda saat ini belum memiliki Google Play Services (AOSP).');
    debugPrint('Gunakan Emulator dengan logo Google Play Store atau gunakan HP fisik.');
    debugPrint('==================================');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
