import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  //AuthRepositoryImpl, AuthRepository-ni implement edir və onun metodlarını @override ilə yenidən yazır (bədən verir).
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override //override cunki authrepodan override edib implementasiya edirik
  Future<UserEntity> register({
    required String email,
    required String password,
  }) {
    return remoteDataSource.register(
      email: email,
      password: password,
    ); //govdesi
  }

  @override
  Future<UserEntity> login({required String email, required String password}) {
    return remoteDataSource.login(email: email, password: password);
  } //login funksiyasinu cagiran yere return edir yeni loginusecase sonra cubit

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }
}//Bura ise bir nece datasource ni birlesdiren yerdir, ona gore data sourceden elave authrepoimpl yaziriq
//Bura bir nece authu birlesdiren yerdir diger repo contractdir hecneyi birlesdirmir
//Hemcinin datasource- firebase dilinde anlayir
//Bu repo ise- usecase/cubit/authrepo(domain) diline uygun isleyir