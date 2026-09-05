import 'package:connectly/app/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/di/injections.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //BU flutter deyirki Firebase kimi native plugin cagiracaq hazir olsun ve bunu yazmasaq xeta olar biler firebase cagirisinda
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //currentPlatform - oldugum emeliyyat sistemine uygunlas
  setupInjections(); //Bu sadəcə dependency-ləri qeydiyyatdan keçirən funksiyadır.
  runApp(const MyApp()); //firebase qosulana kimi ise dusmur gozleyir ui
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connectly',
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}
