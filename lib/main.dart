import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'core/tenant/proyecto_activo_store.dart';
import 'features/asistente/data/datasources/asistente_admin_remote_data_source.dart';
import 'features/asistente/data/datasources/asistente_remote_data_source.dart';
import 'features/asistente/data/repositories/asistente_admin_repository_impl.dart';
import 'features/asistente/data/repositories/asistente_repository_impl.dart';
import 'features/asistente/domain/usecases/consultar_asistente_use_case.dart';
import 'features/asistente/domain/usecases/eliminar_documento_use_case.dart';
import 'features/asistente/domain/usecases/obtener_documento_use_case.dart';
import 'features/asistente/domain/usecases/subir_documento_use_case.dart';
import 'features/asistente/presentation/bloc/asistente_admin_bloc.dart';
import 'features/asistente/presentation/bloc/asistente_bloc.dart';
import 'features/auth/domain/entities/usuario.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/usecases/obtener_modulos_dashboard_usecase.dart';
import 'features/dashboard/presentation/bloc/modulos_dashboard_bloc.dart';
import 'features/infraestructura/data/datasources/infraestructura_remote_data_source.dart';
import 'features/infraestructura/data/repositories/infraestructura_repository_impl.dart';
import 'features/infraestructura/domain/usecases/asignar_unidad_accesoria_usecase.dart';
import 'features/infraestructura/domain/usecases/crear_unidad_accesoria_usecase.dart';
import 'features/infraestructura/domain/usecases/crear_unidades_accesorias_en_lote_usecase.dart';
import 'features/infraestructura/domain/usecases/obtener_arbol_infraestructura_usecase.dart';
import 'features/infraestructura/domain/usecases/obtener_proyecto_del_usuario_usecase.dart';
import 'features/infraestructura/domain/usecases/registrar_agrupacion_en_cascada_usecase.dart';
import 'features/infraestructura/presentation/bloc/infraestructura_bloc.dart';
import 'features/superadmin/data/datasources/superadmin_remote_data_source.dart';
import 'features/superadmin/data/repositories/superadmin_repository_impl.dart';
import 'features/superadmin/domain/usecases/actualizar_proyecto_usecase.dart';
import 'features/superadmin/domain/usecases/crear_administrador_usecase.dart';
import 'features/superadmin/domain/usecases/crear_proyecto_usecase.dart';
import 'features/superadmin/domain/usecases/descartar_proyecto_borrador_usecase.dart';
import 'features/superadmin/domain/usecases/eliminar_proyecto_usecase.dart';
import 'features/superadmin/domain/usecases/guardar_paso_proyecto_usecase.dart';
import 'features/superadmin/domain/usecases/iniciar_proyecto_borrador_usecase.dart';
import 'features/superadmin/domain/usecases/listar_administradores_usecase.dart';
import 'features/superadmin/domain/usecases/listar_mis_proyectos_usecase.dart';
import 'features/superadmin/domain/usecases/listar_proyectos_usecase.dart';
import 'features/superadmin/domain/usecases/obtener_proyecto_usecase.dart';
import 'features/superadmin/presentation/bloc/administradores_bloc.dart';
import 'features/superadmin/presentation/bloc/proyecto_wizard_bloc.dart';
import 'features/residente/data/datasources/residente_remote_data_source.dart';
import 'features/residente/data/repositories/residente_repository_impl.dart';
import 'features/residente/domain/usecases/obtener_mi_informacion_usecase.dart';
import 'features/residente/presentation/bloc/residente_mi_informacion_bloc.dart';
import 'features/superadmin/presentation/bloc/superadmin_bloc.dart';
import 'features/tenant/presentation/bloc/tenant_bloc.dart';

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
  late final SuperadminBloc _superadminBloc;
  late final ProyectoWizardBloc _proyectoWizardBloc;
  late final AdministradoresBloc _administradoresBloc;
  late final TenantBloc _tenantBloc;
  late final ModulosDashboardBloc _modulosDashboardBloc;
  late final ResidenteMiInformacionBloc _residenteMiInformacionBloc;
  late final AsistenteAdminBloc _asistenteAdminBloc;
  late final AsistenteBloc _asistenteBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    final tokenStorage = SecureTokenStorage();
    final proyectoActivoStore = SharedPreferencesProyectoActivoStore();
    final dio = DioClient(tokenStorage, proyectoActivoStore).dio;

    final authDataSource = AuthRemoteDataSource(dio);
    final authRepository = AuthRepositoryImpl(authDataSource, tokenStorage);
    final loginUseCase = LoginUseCase(authRepository);

    _authBloc = AuthBloc(loginUseCase, authRepository);
    _authBloc.add(const AuthCheckRequested());

    final infraestructuraDataSource = InfraestructuraRemoteDataSource(dio);
    final infraestructuraRepository = InfraestructuraRepositoryImpl(
      infraestructuraDataSource,
    );

    _infraestructuraBloc = InfraestructuraBloc(
      obtenerArbolUseCase: ObtenerArbolInfraestructuraUseCase(
        infraestructuraRepository,
      ),
      registrarAgrupacionUseCase: RegistrarAgrupacionEnCascadaUseCase(
        infraestructuraRepository,
      ),
      crearUnidadAccesoriaUseCase: CrearUnidadAccesoriaUseCase(
        infraestructuraRepository,
      ),
      asignarUnidadAccesoriaUseCase: AsignarUnidadAccesoriaUseCase(
        infraestructuraRepository,
      ),
      obtenerProyectoUseCase: ObtenerProyectoDelUsuarioUseCase(
        infraestructuraRepository,
      ),
    );

    final superadminDataSource = SuperadminRemoteDataSource(dio);
    final superadminRepository = SuperadminRepositoryImpl(superadminDataSource);

    _superadminBloc = SuperadminBloc(
      listarProyectosUseCase: ListarProyectosUseCase(superadminRepository),
      crearProyectoUseCase: CrearProyectoUseCase(superadminRepository),
      obtenerProyectoUseCase: ObtenerProyectoUseCase(superadminRepository),
      actualizarProyectoUseCase: ActualizarProyectoUseCase(
        superadminRepository,
      ),
      eliminarProyectoUseCase: EliminarProyectoUseCase(superadminRepository),
      obtenerEstructuraUseCase: ObtenerArbolInfraestructuraUseCase(
        infraestructuraRepository,
      ),
      crearUnidadesAccesoriasEnLoteUseCase:
          CrearUnidadesAccesoriasEnLoteUseCase(infraestructuraRepository),
      asignarUnidadAccesoriaUseCase: AsignarUnidadAccesoriaUseCase(
        infraestructuraRepository,
      ),
    );

    _administradoresBloc = AdministradoresBloc(
      listarAdministradoresUseCase: ListarAdministradoresUseCase(
        superadminRepository,
      ),
      crearAdministradorUseCase: CrearAdministradorUseCase(
        superadminRepository,
      ),
    );

    _proyectoWizardBloc = ProyectoWizardBloc(
      iniciarProyectoBorradorUseCase: IniciarProyectoBorradorUseCase(
        superadminRepository,
      ),
      guardarPasoProyectoUseCase: GuardarPasoProyectoUseCase(
        superadminRepository,
      ),
      descartarProyectoBorradorUseCase: DescartarProyectoBorradorUseCase(
        superadminRepository,
      ),
    );

    _tenantBloc = TenantBloc(
      listarMisProyectosUseCase: ListarMisProyectosUseCase(
        superadminRepository,
      ),
      proyectoActivoStore: proyectoActivoStore,
    );

    final dashboardDataSource = DashboardRemoteDataSource(dio);
    final dashboardRepository = DashboardRepositoryImpl(dashboardDataSource);
    _modulosDashboardBloc = ModulosDashboardBloc(
      obtenerModulosUseCase: ObtenerModulosDashboardUseCase(
        dashboardRepository,
      ),
    );

    final residenteDataSource = ResidenteRemoteDataSource(dio);
    final residenteRepository = ResidenteRepositoryImpl(residenteDataSource);
    _residenteMiInformacionBloc = ResidenteMiInformacionBloc(
      obtenerMiInformacionUseCase: ObtenerMiInformacionUseCase(
        residenteRepository,
      ),
    );

    final asistenteAdminDataSource = AsistenteAdminRemoteDataSource(dio);
    final asistenteAdminRepository = AsistenteAdminRepositoryImpl(
      asistenteAdminDataSource,
    );
    _asistenteAdminBloc = AsistenteAdminBloc(
      obtenerDocumentoUseCase: ObtenerDocumentoUseCase(asistenteAdminRepository),
      subirDocumentoUseCase: SubirDocumentoUseCase(asistenteAdminRepository),
      eliminarDocumentoUseCase: EliminarDocumentoUseCase(
        asistenteAdminRepository,
      ),
    );

    final asistenteDataSource = AsistenteRemoteDataSource(dio);
    final asistenteRepository = AsistenteRepositoryImpl(asistenteDataSource);
    _asistenteBloc = AsistenteBloc(
      consultarUseCase: ConsultarAsistenteUseCase(asistenteRepository),
    );

    _authBloc.stream.listen((state) {
      if (state is AuthSuccess && state.usuario.rol == Rol.administrador) {
        _tenantBloc.add(const TenantResuelto());
      } else if (state is AuthUnauthenticated) {
        _tenantBloc.add(const TenantLimpiado());
      }
    });

    _router = buildRouter(_authBloc, _tenantBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _infraestructuraBloc.close();
    _superadminBloc.close();
    _proyectoWizardBloc.close();
    _administradoresBloc.close();
    _tenantBloc.close();
    _modulosDashboardBloc.close();
    _residenteMiInformacionBloc.close();
    _asistenteAdminBloc.close();
    _asistenteBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _infraestructuraBloc),
        BlocProvider.value(value: _superadminBloc),
        BlocProvider.value(value: _proyectoWizardBloc),
        BlocProvider.value(value: _administradoresBloc),
        BlocProvider.value(value: _tenantBloc),
        BlocProvider.value(value: _modulosDashboardBloc),
        BlocProvider.value(value: _residenteMiInformacionBloc),
        BlocProvider.value(value: _asistenteAdminBloc),
        BlocProvider.value(value: _asistenteBloc),
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
