import 'package:connectly/features/post/presentation/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/di/injections.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/profile/domain/usecases/get_profile_usecase.dart';
import '../features/profile/presentation/pages/profile_page.dart';
/*Bu widget sayəsində, tətbiq hər açılanda:
authwrapper-appin vezeyetini idare edir ona uygun page goster,di-usecase i get it etsen avtomatik elaqeleri qurur useacaseni cubit cagirib usecase cagirir authrepo ve s .

Firebase, əvvəlki sessiyanı yoxlayır (lokal saxlanılıb)
Login olunubsa → avtomatik Home-a keçir
Olunmayıbsa → Login səhifəsini göstərir
login veziyyetini qorumaq ucun istifade edirik

AuthWrapper
    ↓
login olmayıbsa → LoginPage
    ↓
login olubsa → Firestore-da profili yoxla
    ↓
profil yoxdursa → ProfilePage (profil yarat)
    ↓
profil varsa → Home (müvəqqəti mətn, Mərhələ 4-də Posts olacaq)
*/

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(), //Bu, BlocBuilder-ə bənzəyir, amma Cubit yox, birbaşa Stream dinləyir. Firebase-in authStateChanges() streami, User? tipində (nullable — login olmayanda null) məlumat göndərir, dəyişəndə avtomatik builder-i təzədən çağırır.
      builder: (context, snapshot) {
        //Stream — bu, abunəlik kimidir. Youtube kanalına abunə olursan, hər dəfə yeni video çıxanda sənə xəbər gəlir — bu, davamlıdır, dəfələrlə baş verə bilər.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ), //Firebase hələ "kim login olub" yoxlayır (bir neçə millisaniyə) → spinner göstər
          );
        }

        if (!snapshot.hasData) {
          //Heç biri deyilsə (yəni data yoxdur) → LoginPage göstər
          return const LoginPage();
        }

        //Buraya çatdıqsa, deməli login olunub (snapshot.hasData true-dur)
        //İndi login olan istifadəçinin PROFİLİ Firestore-da varmı, onu yoxlamalıyıq
        final uid = snapshot.data!.uid; //login olmuş istifadəçinin uid-i

        return FutureBuilder(
          //FutureBuilder işlədirik, çünki Firestore sorğusu bir dəfəlik nəticə verir (Stream kimi davamlı deyil)
          future: getIt<GetProfileUseCase>().call(
            uid, //Future — bu, bir dəfəlik sifariş kimidir. Restoranda yemək sifariş edirsən, gözləyirsən, bir dəfə yemək gəlir, hekayə bitir.
          ), //GetIt-dən UseCase-i çağırırıq, uid ilə profili axtarırıq
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ), //Firestore sorğusu gedişindədir → spinner göstər
              );
            }

            if (profileSnapshot.hasError) {
              //Xəta gəlibsə (bizim getProfile-da throw Exception('Profil tapılmadı') yazmışdıq)
              //deməli bu istifadəçi hələ profil yaratmayıb → ProfilePage-ə göndər
              return const ProfilePage();
            }

            //Xəta yoxdursa, deməli profil Firestore-da var → Home-a keçirik
            return const HomePage();
          },
        );
      },
    );
  }
}
 /*
 1. authStateChanges() — niyə Stream?

dart
stream: FirebaseAuth.instance.authStateChanges(),

Bu, davamlı məlumat göndərir, çünki login vəziyyəti dəfələrlə dəyişə bilər:

Tətbiq açılır → "kim login olub" yoxlanır → (1-ci siqnal: null, ya user)
İstifadəçi login olur → (2-ci siqnal: user)
İstifadəçi logout edir → (3-cü siqnal: null)
İstifadəçi yenidən login olur → (4-cü siqnal: user)

Hər dəfə bu siqnallardan biri gələndə, StreamBuilder avtomatik yenidən qurulur (builder təzədən çağrılır).


2. getProfile(uid) — niyə Future?

dart
future: getIt<GetProfileUseCase>().call(uid),

Bu, bir dəfəlik sorğudur — "bu uid-ə aid profili Firestore-dan gətir". Bu sorğu:

Göndərilir → gözlənilir → NƏTİCƏ GƏLİR (bir dəfə) → bitir

Bir daha "yeni siqnal" gözlənilmir — sorğu bitəndə, iş tamamlanmış sayılır. FutureBuilder, bu tək nəticəni göstərmək üçündür.

Niyə getProfile-i Stream yox, Future etdik?

Çünki profil məlumatı tez-tez dəyişmir — sadəcə bir dəfə yoxlamaq kifayətdir: "bu istifadəçinin profili varmı?". Əgər profili canlı izləmək istəsəydik (məsələn başqası profili dəyişəndə avtomatik yenilənsin), onda Stream işlədərdik — amma bizim indiki ehtiyacımız bu deyil.

3 Cubitle stream ferqi
Sən bu Stream-i yaratmırsan — Firebase artıq "arxa planda" yaradıb, sənə sadəcə dinləmək
Cubit isə sənin özün yazdığın, flutter_bloc paketinin verdiyi bir classdır — sən onun daxilində öz state-lərini təyin edirsən (AuthLoading, AuthSuccess və s.) və öz məntiqini yazırsan (register(), login() metodları).

*/