import 'package:complaintnow/pages/authpage.dart';
import 'package:complaintnow/services/databaseprovider.dart'; // Import your DatabaseProvider
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugDefaultTargetPlatformOverride = TargetPlatform.android;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DatabaseProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Authpage(), // Your AuthPage or Homepage
    );
  }
}
