import 'package:connectly/app/auth_wrapper.dart';
import 'package:connectly/core/constants/pref_keys.dart';
import 'package:connectly/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:connectly/features/post/data/models/post_hive_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/di/injections.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //BU flutter deyirki Firebase kimi native plugin cagiracaq hazir olsun ve bunu yazmasaq xeta olar biler firebase cagirisinda
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //currentPlatform - oldugum emeliyyat sistemine uygunlas

  await Hive.initFlutter(); // ← Hive-ı başlat//Bu, Hive-a deyir: "Flutter mühitində işə hazırlaş" — cihazda, Hive-ın data saxlayacağı fiziki qovluğu tapır/yaradır.
  Hive.registerAdapter(
    PostHiveModelAdapter(),
  ); // ← Adapter-i qeyd et//Bu, Hive-a deyir: "bu tip class gələndə (PostHiveModel), onu bu tərcüməçi (PostHiveModelAdapter) ilə oxu/yaz".

  setupInjections(); //Bu sadəcə dependency-ləri qeydiyyatdan keçirən funksiyadır.
  final prefs =
      await SharedPreferences.getInstance(); //Bura, məhz Firebase.initializeApp()-ə bənzər məntiqlə işləyir — tətbiq UI göstərməzdən əvvəl, "ilk açılışdırmı" sualını öncədən cavablandırırıq.ona gore bunlari da runApp den evvel yaziriq
  final isFirstLaunch =
      prefs.getBool(PrefsKeys.isFirstLaunch) ??
      true; //tetbiq ilk acilanda hele deyer teyin edilmemiis ola biler yeni null ola biler ona gore ?? yaziriq
  runApp(MyApp(isFirstLaunch: isFirstLaunch));
} //firebase qosulana kimi ise dusmur gozleyir ui

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;

  const MyApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connectly',
      debugShowCheckedModeBanner: false,
      home: isFirstLaunch ? const OnboardingPage() : const AuthWrapper(),
    );
  }
}

/*
Tətbiq açılır
    ↓
Firebase.initializeApp() (gözlənilir)
    ↓
setupInjections() (GetIt qurulur)
    ↓
SharedPreferences-dən "isFirstLaunch" oxunur
    ↓
   ├── true (ilk dəfə) → OnboardingPage göstərilir
   │         ↓
   │    "Başla" düyməsinə basılır
   │         ↓
   │    isFirstLaunch = false yazılır
   │         ↓
   │    AuthWrapper-ə keçilir
   │
   └── false (artıq açılıb) → birbaşa AuthWrapper göstərilir
   */
