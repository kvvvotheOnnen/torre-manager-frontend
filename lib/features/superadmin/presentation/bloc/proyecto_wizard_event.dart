import 'package:equatable/equatable.dart';

import '../../domain/entities/definicion_agrupacion.dart';
import '../../domain/entities/instalacion_extra.dart';
import '../../domain/entities/modulo_sistema.dart';
import '../../domain/entities/tipo_condominio.dart';

sealed class ProyectoWizardEvent extends Equatable {
  const ProyectoWizardEvent();

  @override
  List<Object?> get props => [];
}

class WizardIniciado extends ProyectoWizardEvent {
  const WizardIniciado({required this.nombre, this.descripcion});

  final String nombre;
  final String? descripcion;

  @override
  List<Object?> get props => [nombre, descripcion];
}

class WizardTipoGuardado extends ProyectoWizardEvent {
  const WizardTipoGuardado(this.tipo);

  final TipoCondominio tipo;

  @override
  List<Object?> get props => [tipo];
}

class WizardEstructuraGuardada extends ProyectoWizardEvent {
  const WizardEstructuraGuardada(this.agrupaciones);

  final List<DefinicionAgrupacion> agrupaciones;

  @override
  List<Object?> get props => [agrupaciones];
}

class WizardInstalacionesGuardadas extends ProyectoWizardEvent {
  const WizardInstalacionesGuardadas(this.instalaciones);

  final List<InstalacionExtra> instalaciones;

  @override
  List<Object?> get props => [instalaciones];
}

class WizardAdministradoresGuardados extends ProyectoWizardEvent {
  const WizardAdministradoresGuardados(this.adminIds);

  final List<String> adminIds;

  @override
  List<Object?> get props => [adminIds];
}

class WizardFinalizado extends ProyectoWizardEvent {
  const WizardFinalizado(this.modulos, this.adminIds);

  final List<ModuloSistema> modulos;
  final List<String> adminIds;

  @override
  List<Object?> get props => [modulos, adminIds];
}

class WizardPasoAvanzado extends ProyectoWizardEvent {
  const WizardPasoAvanzado();
}

class WizardPasoRetrocedido extends ProyectoWizardEvent {
  const WizardPasoRetrocedido();
}

class WizardDescartado extends ProyectoWizardEvent {
  const WizardDescartado();
}

class WizardMensajeConsumido extends ProyectoWizardEvent {
  const WizardMensajeConsumido();
}

class WizardReiniciado extends ProyectoWizardEvent {
  const WizardReiniciado();
}
