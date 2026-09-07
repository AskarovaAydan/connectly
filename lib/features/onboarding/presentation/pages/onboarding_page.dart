import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/auth_wrapper.dart';
import 'package:connectly/core/constants/pref_keys.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  Future<void> _finishOnboarding(BuildContext context) async {
    //private method bu fayla ozel
    final prefs =
        await SharedPreferences.getInstance(); //Bu, GetIt və ya Cubit işlətmədən, birbaşa cihazın yaddaşına çıxış açır. await lazımdır, çünki bu, fiziki yaddaşa (diskə) müraciətdir, bir az vaxt aparır.
    await prefs.setBool(
      PrefsKeys.isFirstLaunch,
      false,
    ); //Cihazın yaddaşına daimi olaraq yazır — tətbiq bağlanıb açılsa belə, bu dəyər qalır (Firebase-dən fərqli olaraq, bu, tam lokaldır, internetə ehtiyac yoxdur).
    //Onboarding-in bitdiyini yadda saxlayırıq,Burada telefonda belə bir məlumat saxlayırıq:isFirstLaunch = false,Yəni:"İstifadəçi onboarding-i artıq keçib."
    if (context.mounted) {
      //ola bilsinki nese olub hemin widget ekrandan getmiyib, hemin hal ucun bu if statement yaziriq
      Navigator.of(context).pushReplacement(
        //pushReplace gore geri qayida bilmirik,cunki onboarding her acilanda yox ilk acilanda gorunmelidir
        MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
        ), //_ burada BuildContext-dir, amma bizə lazım olmadığı üçün _ yazırıq.
      ); //Burada AuthWrapper-a keçmək üçün route yaradırıq.,Yeni AuthWrapper widget-i yaradırıq.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_alt, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Connectly-ə xoş gəldin!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Dostlarınla paylaş, yeni insanlarla tanış ol.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _finishOnboarding(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                child: Text('Başla'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
Məsələn ilk dəfə tətbiq açıldığında:

isFirstLaunch = true

ola bilər.

İstifadəçi Başla düyməsinə basır:

setBool(..., false)

olur.

Növbəti dəfə tətbiq açıldığında artıq bilirik ki:

isFirstLaunch == false

və onboarding-i yenidən göstərmirik.




Onboarding-dən sonra tətbiqin əsas axınına keçmək lazımdır. AuthWrapper burada bir növ qapı nəzarətçisi kimi işləyir.
App açılır
   ↓
İlk dəfədir?
   ↓
OnboardingPage
   ↓
"Başla"
   ↓
isFirstLaunch = false
   ↓
AuthWrapper
   ↓
İstifadəçi login olub?
   ↙              ↘
Bəli              Xeyr
 ↓                 ↓
HomePage        LoginPage

yeni authwarpper ile onboaringden sonra hansi sehifeye kecid edeceyimizi bilirik
*/
