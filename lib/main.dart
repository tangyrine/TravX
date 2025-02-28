import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: "AIzaSyBFwOrZUiMrCXz6LWQ0wEfmlt8_qWTgtks",
      appId: "1:722133009908:web:a1f557a260aa0927f5e5a1",
      messagingSenderId: "722133009908",
      projectId: "menuvista-cebae",
      authDomain: "menuvista-cebae.firebaseapp.com",
      storageBucket: "menuvista-cebae.appspot.com",
    ));
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SignUpPage(),
    );
  }
}
