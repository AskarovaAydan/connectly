import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSource(this.firebaseAuth);
  //Register
  Future<UserEntity> register({
    //register adli yeni funksiya yaradirik ki gelecekde Userentity qaytaracaq
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      //Firebase cagirisidir
      email: email,
      password: password,
    ); //asinxron funksiyadir vaxt ala biler firebase

    final user = credential
        .user; //ve credential obyektinin daxilindəki .user sahəsini götürürük.

    if (user == null) {
      throw Exception('Qeydiyyat uğursuz oldu'); //null dursa xeta atiriq
    }

    return UserEntity(
      //Firebase in user obyekti null deyilse onu domainin tandigi yeni UserEntity qaytaririq ve doamindeki userentity deyerlerine bu yeni deyerleri qoyuruq
      uid: user.uid,
      email:
          user.email ??
          email, //user null deyilse user inki null dursa ehtiyat emaili yaziriq
      name:
          null, //register merhelesinde hele ad null olur,hele ad daxil edilmir
    );
  }

  //Login
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Giriş uğursuz oldu');
    }

    return UserEntity(uid: user.uid, email: user.email ?? email, name: null);
  }

  //Logout
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
}
//UI → Cubit → UseCase → AuthRepository (contract)  → AuthRepositoryImpl (bədən) → RemoteDataSource → Firebase
//Firebase → RemoteDataSource (UserEntity yaradır)  → AuthRepositoryImpl → UseCase → Cubit (emit AuthSuccess(user))