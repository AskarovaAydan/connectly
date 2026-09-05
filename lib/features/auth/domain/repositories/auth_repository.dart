import '../entities/user_entity.dart'; //burda register login logout ola biler her birine ayri usecase yaziriq istesek

abstract class AuthRepository {
  //obyekti yaradila bilmeyen class contract kimi istifade edilir basqa class datadakki authrepimpl bundan implement edib imzalayib real kodu yazacaq
  Future<UserEntity> register({
    //Future-netice gelecekde hazir olacaq demekdi(şəbəkə sorğusu — Firebase-ə müraciət)
    required String
    email, //bu methoddur adi register qaytardigi tip userentity ve bu methodun govdesi yoxdur bunu Authrepoimplementde yazacyiq
    required String
    password, //bize email ve passwordla registeri temin edecek plugin lazimdir ama hansi bunu domain qati bilmir
  });
  Future<UserEntity> login({required String email, required String password});

  Future<void> logout(); //logout sadece cixisdir hecne qaytarmir
}
