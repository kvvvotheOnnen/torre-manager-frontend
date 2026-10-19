import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  runApp(const TorreManagerApp());
}

class TorreManagerApp extends StatefulWidget {
  const TorreManagerApp({super.key});

  @override
  State<TorreManagerApp> createState() => _TorreManagerAppState();
}

class _TorreManagerAppState extends State<TorreManagerApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    final tokenStorage = SecureTokenStorage();
    final dio = DioClient(tokenStorage).dio;
    final remoteDataSource = AuthRemoteDataSource(dio);
    final repository = AuthRepositoryImpl(remoteDataSource, tokenStorage);
    final loginUseCase = LoginUseCase(repository);

    _authBloc = AuthBloc(loginUseCase);
    _router = buildRouter();
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'Torre Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
