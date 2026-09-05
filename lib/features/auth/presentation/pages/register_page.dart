import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injections.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterPage extends StatefulWidget {
  //TextField-lərin yazdığın mətni saxlamaq üçün TextEditingController lazımdır, bu da State-ə ehtiyac duyur (StatelessWidget-də ola bilməz).
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController =
      TextEditingController(); //Hər TextField-in yazdığın mətni "yaddaşda saxlayan" obyektlər. dispose()-da onları təmizləyirik (yaddaş sızmasının qarşısını almaq üçün — səhifə bağlananda).
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<
            AuthCubit
          >(), //Bu, AuthCubit-i yaradır və onu bu widget ağacının (child-in) altındakı hər yerdə əlçatan edir. getIt<AuthCubit>() — yadına gəlsin, bu, injections.dart-da qeyd etdiyimiz Factory-dir, hər dəfə təzə Cubit yaradır.
      child: Scaffold(
        appBar: AppBar(title: const Text('Qeydiyyat')),
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Qeydiyyat uğurlu oldu!')),
              ); //snackbar kimi bir defelik mesajlar ucun listener islenilir
              //BlocBuilder-dən fərqli olaraq, BlocListener UI qurmur, sadəcə state dəyişəndə bir hərəkət edir (burada: SnackBar göstərir). Uğur/xəta mesajı göstərmək üçün idealdır — çünki bunu "yenidən qurmaq" yox, "bir dəfə göstərmək" istəyirik.
            }
            if (state is AuthFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifrə',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthCubit, AuthState>(
                  //state dəyişəndə UI-ı yenidən quran hissədir. AuthLoading olanda spinner göstərir, əks halda düyməni göstərir.
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: () {
                        context.read<AuthCubit>().register(
                          //Düyməyə basanda, AuthCubit-i tapıb (context.read), onun register() metodunu çağırırıq — bu, bütün zənciri (UseCase → Repository → DataSource → Firebase) işə salır.
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Qeydiyyatdan keç'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
