import 'package:connectly/features/auth/domain/usecases/login_usecase.dart';
import 'package:connectly/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  //"bu Cubit-in state-ləri, yalnız AuthState-in alt-tipləri ola bilər" (yəni AuthInitial, AuthLoading, AuthSuccess, AuthFailure).
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit(this.registerUseCase, this.loginUseCase, this.logoutUseCase)
    : super(AuthInitial());

  Future<void> register({
    //register methodu read ile burani tapiriq,nese qaytarmir bu method voiddir,amma vaxt aparır (Future), çünki içində Firebase sorğusu var.
    required String email,
    required String password,
  }) async {
    emit(AuthLoading()); //baslyanda spinner gorunsun
    try {
      //try/catch — xəta idarəetməsi. Firebase sorğusu uğursuz ola bilər (məsələn email artıq mövcuddursa, ya şəbəkə problemi)
      final user = await registerUseCase(email: email, password: password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(
        email: email,
        password: password,
      ); //Burada user artıq Repository-dən gələn UserEntity olur.
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    await logoutUseCase();
    emit(AuthInitial());
  }
}

/*AuthCubit(this.registerUseCase) : super(AuthInitial()); bunun acilis beledir

AuthCubit(RegisterUseCase registerUseCase) : super(AuthInitial()) {
  this.registerUseCase = registerUseCase; // əl ilə təyin etmək
}
numune:
final RegisterUseCase registerUseCase; // "mənim bir qutum var, adı `registerUseCase`, içi boşdur"
AuthCubit(this.registerUseCase);        // "kimsə bu qutunu doldursun, mən onu daxilimdə saxlayıram"
-----------------------------------------------------------------------------------------------
injections.dart:
  AuthCubit( getIt<RegisterUseCase>() )
             └──────────┬──────────┘
                   bu DƏYƏR, "çöldən" gəlir
                        ↓
auth_cubit.dart:
  AuthCubit( this.registerUseCase )
             └───────┬──────────┘
              bu PARAMETR, yuxarıdakı dəyəri QƏBUL EDİR
              və öz sahəsinə (this.registerUseCase) yazır
              */
