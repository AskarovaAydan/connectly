import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  //bu, "ana" state-dir, özü birbaşa işlədilmir, sadəcə digərlərinin əsasıdır
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial
    extends
        AuthState {} //tətbiq açılanda, heç nə baş verməmiş halda (başlanğıc)

class AuthLoading
    extends
        AuthState {} //register/login gedişində (UI-da spinner göstərmək üçün)

class AuthSuccess extends AuthState {
  //uğurlu oldu, içində UserEntity var (UI bunu istifadə edib başqa səhifəyə keçə bilər)
  final UserEntity user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user]; //AuthLoading ve AuthSuccess ferqli oldugu ucun ui tezden qurulur
}

class AuthFailure extends AuthState {
  //xəta oldu, içində xəta mesajı var (UI-da qırmızı mətn göstərmək üçün)
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message]; //eyni xeta gelse ui ni tezden qurmur
}
