import '../entities/user_entity.dart'; //usecase ile cubite lazim olan isi veririk(login ucun login usecase ve s.)
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository
  repository; //domaindeki reponu cagirir ozu registeri nece edceyin bilmir

  RegisterUseCase(
    this.repository,
  ); //kenardan verdik - Constructor injection,UseCase özü AuthRepository() yaratmır, ona hazır verilir.

  Future<UserEntity> call({
    //Cubit usecaseni cagiranda burdaki call ise dusur,icindeki obyekti method kimi cagirmaga imkan verir call
    required String email,
    required String password,
  }) {
    return repository.register(
      //call repository.register() methodunu cagirir
      email: email,
      password: password,
    ); //call cagrilanda repo isi bitirib neticeni bize verir,return ile cubite otururuk
  }
}

//usecase register prosesini nece edeceyini bilmediyi ucun authrepoya muraciet edir
//Demeli Cubit deyir register etmeliyem bununcun register usecase cagirir ,register usecase ne edeceyini bilmediyi ucun authrepodan istifade edir,auth repodan implementasiya edir authrepoimplementation ve oda firebase ile elaqe saxlayir ve neticeni return ile cubite qaytaririlar.
//Burda userentity istifade etme sebebimiz bunu vermesek random bir sey qaytaracaqada tehlukesizliyi temin edirik
