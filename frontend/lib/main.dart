import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_nav_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const CivicWorksApp());
}

class CivicWorksApp extends StatelessWidget {
  const CivicWorksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, ApiService>(
          create: (_) => ApiService(),
          update: (_, auth, api) => api!..updateAuth(auth.currentUser),
        ),
      ],
      child: MaterialApp(
        title: 'Civic Works',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          textTheme: GoogleFonts.latoTextTheme(),
          inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    if (auth.isAuthenticated) {
      return const MainNavScreen();
    }
    return const LoginScreen();
  }
}
