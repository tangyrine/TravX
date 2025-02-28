import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'bus_info_page.dart';
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Tracking App',
      initialRoute: '/home',
      routes: {
        '/': (context) => AuthenticationWrapper(),
        '/home': (context) => HomePage(),
        '/map': (context) => MapPage(),
        '/busInfo': (context) => BusInfoPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
      },
    );
  }
}
