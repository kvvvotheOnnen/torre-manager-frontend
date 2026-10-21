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
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/infraestructura/data/datasources/infraestructura_remote_data_source.dart';
import 'features/infraestructura/data/repositories/infraestructura_repository_impl.dart';
import 'features/infraestructura/domain/usecases/asignar_unidad_accesoria_usecase.dart';
import 'features/infraestructura/domain/usecases/crear_unidad_accesoria_usecase.dart';
import 'features/infraestructura/domain/usecases/obtener_arbol_infraestructura_usecase.dart';
import 'features/infraestructura/domain/usecases/obtener_proyecto_del_usuario_usecase.dart';
import 'features/infraestructura/domain/usecases/registrar_agrupacion_en_cascada_usecase.dart';
import 'features/infraestructura/presentation/bloc/infraestructura_bloc.dart';

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
  late final InfraestructuraBloc _infraestructuraBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    final tokenStorage = SecureTokenStorage();
    final dio = DioClient(tokenStorage).dio;

    final authDataSource = AuthRemoteDataSource(dio);
    final authRepository = AuthRepositoryImpl(authDataSource, tokenStorage);
    final loginUseCase = LoginUseCase(authRepository);

    _authBloc = AuthBloc(loginUseCase, authRepository);
    _authBloc.add(const AuthCheckRequested());

    final infraestructuraDataSource = InfraestructuraRemoteDataSource(dio);
    final infraestructuraRepository =
        InfraestructuraRepositoryImpl(infraestructuraDataSource);

    _infraestructuraBloc = InfraestructuraBloc(
      obtenerArbolUseCase: ObtenerArbolInfraestructuraUseCase(infraestructuraRepository),
      registrarAgrupacionUseCase: RegistrarAgrupacionEnCascadaUseCase(
        infraestructuraRepository,
      ),
      crearUnidadAccesoriaUseCase:
          CrearUnidadAccesoriaUseCase(infraestructuraRepository),
      asignarUnidadAccesoriaUseCase:
          AsignarUnidadAccesoriaUseCase(infraestructuraRepository),
      obtenerProyectoUseCase:
          ObtenerProyectoDelUsuarioUseCase(infraestructuraRepository),
    );

    _router = buildRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _infraestructuraBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _infraestructuraBloc),
      ],
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
