import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:twich_clone/resource/auth_meth.dart';
import 'package:twich_clone/screens/Home_screen.dart';
import 'package:twich_clone/screens/signin_screen.dart';
import 'package:twich_clone/screens/signup_screen.dart';

import 'firebase_options.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ///Network needed
  await AuthMeth().setInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ).copyWith(
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: const TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      routes: {
        '/onBoarding': (context) => const OnBoardingScreen(),
        '/signup': (context) => const SignupScreen(),
        '/signin': (context) => const SigninScreen(),
      },
      home: SafeArea(
        child: StreamBuilder(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!snap.hasData) {
                return const OnBoardingScreen();
              } else {
                return const HomeScreen();
              }
            }),
      ),
    );
  }
}
