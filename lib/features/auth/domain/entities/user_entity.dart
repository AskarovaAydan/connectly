import 'package:equatable/equatable.dart'; //domain qatinda oldugu ucun sirf dart classi dir firebaseden xeberi yoxdur

class UserEntity extends Equatable {
  final String uid; //final-bir defe teyin olunur ve run time da hesablanir
  final String email;
  final String? name;

  const UserEntity({
    required this.uid,
    required this.email,
    this.name,
  }); //const compile time zamani deyer teyin olunur ve hec vaxt deyismez

  @override
  List<Object?> get props => [uid, email, name]; //tutaqki iki dene user1 ve user2 obyektim var equatable ve props ile deyiriki bunlari 3 saheye esasen muqayise et ve eyni obyekt kimi algila ve ui ni tezden build etme
}
/*

AuthCubit
   ↓
LoginUseCase
   ↓
AuthRepository        ← Domain layer (interface/abstract)
   ↓
AuthRepositoryImpl    ← Data layer (implementation)
   ↓
AuthRemoteDataSource
   ↓
API artiq sondaki user imiz userentitydeki son deyerleri alir

*/