import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/utils/rut_validator.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../superadmin/presentation/widgets/wizard_step_map.dart';
import '../../domain/entities/registro_residente.dart';
import '../bloc/registro_residente_bloc.dart';

const _pasos = ['Proyecto', 'Vínculo', 'Unidad', 'Residentes', 'Mascotas', 'Listo'];
const _maxResidentes = 6;

class RegistroWizardScreen extends StatefulWidget {
  const RegistroWizardScreen({super.key});

  @override
  State<RegistroWizardScreen> createState() => _RegistroWizardScreenState();
}

class _RegistroWizardScreenState extends State<RegistroWizardScreen> {
  int _paso = 0;

  ProyectoRegistro? _proyecto;
  TipoVinculoRegistro? _tipoVinculo;
  UnidadRegistro? _unidad;
  final _unidadController = TextEditingController();

  final List<_ResidenteForm> _residentes = [_ResidenteForm(esPrincipal: true)];

  bool? _tieneMascotas;
  final List<_MascotaForm> _mascotas = [];

  bool _enviadoLocal = false;

  @override
  void initState() {
    super.initState();
    context.read<RegistroResidenteBloc>().add(
      const RegistroProyectosSolicitados(),
    );
  }

  @override
  void dispose() {
    _unidadController.dispose();
    for (final residente in _residentes) {
      residente.dispose();
    }
    for (final mascota in _mascotas) {
      mascota.dispose();
    }
    super.dispose();
  }

  void _reiniciar() {
    for (final residente in _residentes) {
      residente.dispose();
    }
    for (final mascota in _mascotas) {
      mascota.dispose();
    }
    _unidadController.clear();
    setState(() {
      _paso = 0;
      _proyecto = null;
      _tipoVinculo = null;
      _unidad = null;
      _residentes
        ..clear()
        ..add(_ResidenteForm(esPrincipal: true));
      _tieneMascotas = null;
      _mascotas.clear();
      _enviadoLocal = false;
    });
    context.read<RegistroResidenteBloc>().add(const RegistroReiniciado());
    context.read<RegistroResidenteBloc>().add(
      const RegistroProyectosSolicitados(),
    );
  }

  void _siguiente() {
    FocusScope.of(context).unfocus();

    switch (_paso) {
      case 0:
        if (_proyecto == null) return;
        setState(() => _paso = 1);
      case 1:
        if (_tipoVinculo == null) return;
        setState(() => _paso = 2);
      case 2:
        if (_unidad == null) return;
        setState(() => _paso = 3);
      case 3:
        if (!_residentesValidos()) return;
        _mostrarAvisoDatos();
      case 4:
        if (!_mascotasValidas()) return;
        _enviar();
    }
  }

  void _atras() {
    if (_paso == 0) {
      _confirmarSalida();
      return;
    }
    setState(() => _paso -= 1);
  }

  bool _residentesValidos() {
    if (_residentes.isEmpty) return false;
    for (final residente in _residentes) {
      if (!residente.formKey.currentState!.validate()) return false;
    }
    return true;
  }

  bool _mascotasValidas() {
    if (_tieneMascotas != true) return true;
    if (_mascotas.isEmpty) return false;
    for (final mascota in _mascotas) {
      if (!mascota.formKey.currentState!.validate()) return false;
    }
    return true;
  }

  void _mostrarAvisoDatos() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Usaremos tus datos'),
        content: const Text(
          'Tus datos se usarán para facilitar la asociación de tu persona al '
          'departamento y serán cifrados para proteger tu información. '
          'Un administrador revisará tu solicitud antes de completar el ingreso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Entendido'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              setState(() => _paso = 4);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _enviar() {
    final residentes = _residentes
        .map(
          (residente) => PersonaRegistro(
            nombre: residente.nombre.text.trim(),
            rut: RutValidator.formatear(residente.rut.text),
            email: residente.email.text.trim(),
            telefono: residente.telefono.text.trim(),
            telefonoEmergencia: residente.telefonoEmergencia.text.trim(),
            nombreEmergencia: residente.nombreEmergencia.text.trim(),
          ),
        )
        .toList();

    final mascotas = _mascotas
        .map(
          (mascota) => MascotaRegistro(
            nombre: mascota.nombre.text.trim(),
            especie: mascota.especie,
            raza: mascota.raza.text.trim(),
            microchip: mascota.microchip.text.trim().isEmpty
                ? null
                : mascota.microchip.text.trim(),
          ),
        )
        .toList();

    final solicitud = SolicitudRegistro(
      proyectoId: _proyecto!.id,
      unidadPrincipalId: _unidad!.id,
      tipoVinculo: _tipoVinculo!,
      password: _residentes.first.password!.text,
      personas: residentes,
      mascotas: mascotas,
    );

    context.read<RegistroResidenteBloc>().add(
      RegistroSolicitudEnviada(solicitud),
    );
  }

  void _confirmarSalida() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Salir del registro?'),
        content: const Text(
          'Se perderá el progreso de tu solicitud. Deberás comenzar de nuevo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Seguir aquí'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.palette.danger,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go(AppRoutes.login);
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: BlocConsumer<RegistroResidenteBloc, RegistroResidenteState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: p.danger,
                    ),
                  );
                context.read<RegistroResidenteBloc>().add(
                  const RegistroErrorLimpiado(),
                );
              }
              if (state.enviado && !_enviadoLocal) {
                setState(() {
                  _enviadoLocal = true;
                  _paso = 5;
                });
              }
            },
            builder: (context, state) {
              final pasoVisual = state.enviado ? 5 : _paso;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Encabezado(onSalir: _confirmarSalida),
                        WizardStepMap(pasos: _pasos, pasoActual: pasoVisual),
                        const SizedBox(height: AppSpacing.sm),
                        Expanded(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.lg,
                            ),
                            child: _contenidoPaso(state),
                          ),
                        ),
                        if (!state.enviado)
                          _Navegacion(
                            paso: _paso,
                            enviando: state.enviando,
                            habilitado: _puedeAvanzar(state),
                            onAtras: _atras,
                            onSiguiente: _siguiente,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool _puedeAvanzar(RegistroResidenteState state) {
    return switch (_paso) {
      0 => _proyecto != null,
      1 => _tipoVinculo != null,
      2 => _unidad != null && !state.cargandoUnidades,
      3 => _residentes.isNotEmpty,
      4 => _tieneMascotas == false || _mascotas.isNotEmpty,
      _ => false,
    };
  }

  Widget _contenidoPaso(RegistroResidenteState state) {
    return switch (_paso) {
      0 => _PasoProyecto(
        state: state,
        seleccionado: _proyecto,
        onSeleccionar: (proyecto) {
          setState(() {
            _proyecto = proyecto;
            _unidad = null;
            _unidadController.clear();
          });
          context.read<RegistroResidenteBloc>().add(
            RegistroUnidadesSolicitadas(proyecto.id),
          );
        },
      ),
      1 => _PasoVinculo(
        seleccionado: _tipoVinculo,
        onSeleccionar: (tipo) => setState(() => _tipoVinculo = tipo),
      ),
      2 => _PasoUnidad(
        state: state,
        controller: _unidadController,
        seleccionada: _unidad,
        onSeleccionar: (unidad) => setState(() {
          _unidad = unidad;
          _unidadController.text = unidad.etiqueta;
        }),
        onInvalidar: () => setState(() => _unidad = null),
        onReintentar: () {
          final proyecto = _proyecto;
          if (proyecto == null) return;
          context.read<RegistroResidenteBloc>().add(
            RegistroUnidadesSolicitadas(proyecto.id),
          );
        },
      ),
      3 => _PasoResidentes(
        residentes: _residentes,
        tipoVinculo: _tipoVinculo,
        onAgregar: _residentes.length < _maxResidentes
            ? () => setState(() {
                _residentes.add(
                  _ResidenteForm(esPrincipal: false),
                );
              })
            : null,
        onEliminar: (index) => setState(() {
          final eliminado = _residentes.removeAt(index);
          eliminado.dispose();
        }),
      ),
      4 => _PasoMascotas(
        tieneMascotas: _tieneMascotas,
        mascotas: _mascotas,
        onCambiarTieneMascotas: (valor) => setState(() {
          _tieneMascotas = valor;
          if (valor == false) {
            for (final mascota in _mascotas) {
              mascota.dispose();
            }
            _mascotas.clear();
          } else if (_mascotas.isEmpty) {
            _mascotas.add(_MascotaForm());
          }
        }),
        onAgregarMascota: () => setState(() => _mascotas.add(_MascotaForm())),
        onEliminarMascota: (index) => setState(() {
          final eliminada = _mascotas.removeAt(index);
          eliminada.dispose();
        }),
      ),
      5 => _PasoFinalizado(
        mensaje: state.mensajeExito ??
            'Tu solicitud de ingreso fue registrada correctamente.',
        onIrLogin: () => context.go(AppRoutes.login),
        onNuevoRegistro: _reiniciar,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.onSalir});

  final VoidCallback onSalir;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: BrandMark(
            size: 38,
            showWordmark: true,
            subtitle: 'REGISTRO DE RESIDENTE',
          ),
        ),
        TextButton.icon(
          onPressed: onSalir,
          icon: const Icon(Icons.close_rounded, size: 18),
          label: const Text('Salir'),
        ),
      ],
    );
  }
}

class _Navegacion extends StatelessWidget {
  const _Navegacion({
    required this.paso,
    required this.enviando,
    required this.habilitado,
    required this.onAtras,
    required this.onSiguiente,
  });

  final int paso;
  final bool enviando;
  final bool habilitado;
  final VoidCallback onAtras;
  final VoidCallback onSiguiente;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: enviando ? null : onAtras,
          child: Text(paso == 0 ? 'Salir' : 'Atrás'),
        ),
        const Spacer(),
        SizedBox(
          height: 50,
          child: FilledButton(
            onPressed: !habilitado || enviando ? null : onSiguiente,
            child: enviando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(paso == 4 ? 'Enviar solicitud' : 'Siguiente'),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _PasoProyecto extends StatelessWidget {
  const _PasoProyecto({
    required this.state,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  final RegistroResidenteState state;
  final ProyectoRegistro? seleccionado;
  final ValueChanged<ProyectoRegistro> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Elige tu condominio',
      descripcion:
          'Selecciona el recinto en el que te estás registrando.',
      child: state.cargandoProyectos
          ? const _Cargando()
          : state.proyectos.isEmpty
          ? const _Vacio(
              mensaje: 'No hay proyectos disponibles para registrarse.',
            )
          : Column(
              children: [
                for (final proyecto in state.proyectos)
                  _OpcionCard(
                    titulo: proyecto.nombre,
                    icono: Icons.apartment_rounded,
                    seleccionado: seleccionado?.id == proyecto.id,
                    onTap: () => onSeleccionar(proyecto),
                  ),
              ],
            ),
    );
  }
}

class _PasoVinculo extends StatelessWidget {
  const _PasoVinculo({required this.seleccionado, required this.onSeleccionar});

  final TipoVinculoRegistro? seleccionado;
  final ValueChanged<TipoVinculoRegistro> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: '¿Cuál es tu vínculo con la unidad?',
      descripcion:
          'Esto define cómo el sistema registra tu relación con el condominio.',
      child: Column(
        children: [
          _OpcionCard(
            titulo: 'Propietario',
            descripcion: 'Eres dueño de la unidad.',
            icono: Icons.vpn_key_rounded,
            seleccionado: seleccionado == TipoVinculoRegistro.propietario,
            onTap: () => onSeleccionar(TipoVinculoRegistro.propietario),
          ),
          _OpcionCard(
            titulo: 'Arrendatario',
            descripcion: 'Arriendas la unidad a un propietario.',
            icono: Icons.receipt_long_rounded,
            seleccionado: seleccionado == TipoVinculoRegistro.arrendatario,
            onTap: () => onSeleccionar(TipoVinculoRegistro.arrendatario),
          ),
        ],
      ),
    );
  }
}

class _PasoUnidad extends StatelessWidget {
  const _PasoUnidad({
    required this.state,
    required this.controller,
    required this.seleccionada,
    required this.onSeleccionar,
    required this.onInvalidar,
    required this.onReintentar,
  });

  final RegistroResidenteState state;
  final TextEditingController controller;
  final UnidadRegistro? seleccionada;
  final ValueChanged<UnidadRegistro> onSeleccionar;
  final VoidCallback onInvalidar;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Selecciona tu unidad',
      descripcion:
          'Escribe el número o identificador y elige una de las unidades '
          'sugeridas. Debes seleccionar una opción válida.',
      child: state.cargandoUnidades
          ? const _Cargando()
          : state.errorUnidades != null
          ? _ErrorCarga(
              mensaje: state.errorUnidades!,
              onReintentar: onReintentar,
            )
          : state.unidades.isEmpty
          ? const _Vacio(mensaje: 'Este proyecto aún no tiene unidades.')
          : Autocomplete<UnidadRegistro>(
              displayStringForOption: (unidad) => unidad.etiqueta,
              optionsBuilder: (value) {
                final texto = value.text.trim().toLowerCase();
                if (texto.isEmpty) return state.unidades;
                return state.unidades.where(
                  (unidad) =>
                      unidad.etiqueta.toLowerCase().contains(texto) ||
                      unidad.identificador.toLowerCase().contains(texto),
                );
              },
              onSelected: onSeleccionar,
              fieldViewBuilder:
                  (context, textController, focusNode, onFieldSubmitted) {
                    controller.value = controller.value.copyWith(
                      text: textController.text,
                      selection: textController.selection,
                    );

                    return TextFormField(
                      controller: textController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Unidad / departamento',
                        hintText: 'Ej: Torre A - 101',
                        prefixIcon: Icon(Icons.home_work_outlined),
                      ),
                      onChanged: (value) {
                        controller.text = value;
                        if (seleccionada != null &&
                            value != seleccionada!.etiqueta) {
                          onInvalidar();
                        }
                      },
                      validator: (value) {
                        if (seleccionada == null) {
                          return 'Debes elegir una unidad sugerida';
                        }
                        return null;
                      },
                    );
                  },
            ),
    );
  }
}

class _ResidenteForm {
  _ResidenteForm({required this.esPrincipal}) {
    if (esPrincipal) {
      password = TextEditingController();
      passwordConfirm = TextEditingController();
    }
  }

  final bool esPrincipal;

  final formKey = GlobalKey<FormState>();
  final nombre = TextEditingController();
  final rut = TextEditingController();
  final email = TextEditingController();
  final telefono = TextEditingController();
  final telefonoEmergencia = TextEditingController();
  final nombreEmergencia = TextEditingController();
  TextEditingController? password;
  TextEditingController? passwordConfirm;

  bool get completo {
    return nombre.text.trim().isNotEmpty &&
        rut.text.trim().isNotEmpty &&
        email.text.trim().isNotEmpty &&
        telefono.text.trim().isNotEmpty &&
        telefonoEmergencia.text.trim().isNotEmpty &&
        nombreEmergencia.text.trim().isNotEmpty &&
        (!esPrincipal ||
            ((password?.text.trim().isNotEmpty ?? false) &&
                (passwordConfirm?.text.trim().isNotEmpty ?? false)));
  }

  void dispose() {
    nombre.dispose();
    rut.dispose();
    email.dispose();
    telefono.dispose();
    telefonoEmergencia.dispose();
    nombreEmergencia.dispose();
    password?.dispose();
    passwordConfirm?.dispose();
  }
}

class _PasoResidentes extends StatefulWidget {
  const _PasoResidentes({
    required this.residentes,
    required this.tipoVinculo,
    required this.onAgregar,
    required this.onEliminar,
  });

  final List<_ResidenteForm> residentes;
  final TipoVinculoRegistro? tipoVinculo;
  final VoidCallback? onAgregar;
  final ValueChanged<int> onEliminar;

  @override
  State<_PasoResidentes> createState() => _PasoResidentesState();
}

class _PasoResidentesState extends State<_PasoResidentes> {
  @override
  Widget build(BuildContext context) {
    final residentes = widget.residentes;
    final ultimo = residentes.last;
    final listenable = Listenable.merge([
      ultimo.nombre,
      ultimo.rut,
      ultimo.email,
      ultimo.telefono,
      ultimo.telefonoEmergencia,
      ultimo.nombreEmergencia,
      if (ultimo.password != null) ultimo.password!,
      if (ultimo.passwordConfirm != null) ultimo.passwordConfirm!,
    ]);

    return _Seccion(
      titulo: 'Datos de los residentes',
      descripcion:
          'Completa los datos de las personas que vivirán en la unidad. '
          'Puedes registrar hasta 6 residentes.',
      child: Column(
        children: [
          for (var i = 0; i < residentes.length; i++)
            _TarjetaResidente(
              form: residentes[i],
              indice: i,
              tipoVinculo: widget.tipoVinculo,
              onEliminar: i == 0 ? null : () => widget.onEliminar(i),
            ),
          const SizedBox(height: AppSpacing.sm),
          ListenableBuilder(
            listenable: listenable,
            builder: (context, _) {
              final puedeAgregar =
                  residentes.length < _maxResidentes && ultimo.completo;

              return Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: puedeAgregar ? widget.onAgregar : null,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: Text(
                    residentes.length >= _maxResidentes
                        ? 'Máximo 6 residentes'
                        : 'Agregar otro residente',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TarjetaResidente extends StatefulWidget {
  const _TarjetaResidente({
    required this.form,
    required this.indice,
    required this.tipoVinculo,
    required this.onEliminar,
  });

  final _ResidenteForm form;
  final int indice;
  final TipoVinculoRegistro? tipoVinculo;
  final VoidCallback? onEliminar;

  @override
  State<_TarjetaResidente> createState() => _TarjetaResidenteState();
}

class _TarjetaResidenteState extends State<_TarjetaResidente> {
  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final esPrincipal = form.esPrincipal;
    final p = context.palette;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: p.isDark ? 0.18 : 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: Form(
        key: form.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  esPrincipal
                      ? Icons.person_rounded
                      : Icons.people_outline_rounded,
                  size: 18,
                  color: p.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    esPrincipal
                        ? (widget.tipoVinculo ==
                                  TipoVinculoRegistro.propietario
                              ? 'Propietario principal'
                              : 'Arrendatario principal')
                        : 'Conviviente ${widget.indice + 1}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (widget.onEliminar != null)
                  IconButton(
                    tooltip: 'Quitar',
                    onPressed: widget.onEliminar,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
              ],
            ),
            if (esPrincipal)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  widget.tipoVinculo == TipoVinculoRegistro.propietario
                      ? 'Este formulario corresponde a los datos del '
                            'propietario. Los siguientes se consideran '
                            'convivientes.'
                      : 'Este formulario corresponde a los datos del '
                            'arrendatario. Los siguientes se consideran '
                            'convivientes.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: p.inkMuted),
                ),
              ),
            _Campo(
              controller: form.nombre,
              label: 'Nombre completo',
              icon: Icons.badge_outlined,
            ),
            _Campo(
              controller: form.rut,
              label: 'RUT',
              hint: '12.345.678-5',
              icon: Icons.credit_card_rounded,
              validator: RutValidator.validar,
            ),
            _Campo(
              controller: form.email,
              label: 'Correo electrónico',
              keyboardType: TextInputType.emailAddress,
              icon: Icons.alternate_email_rounded,
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Ingresa el correo';
                final valido = RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                ).hasMatch(email);
                return valido ? null : 'Correo inválido';
              },
            ),
            _Campo(
              controller: form.telefono,
              label: 'Teléfono',
              hint: '+56912345678',
              keyboardType: TextInputType.phone,
              icon: Icons.phone_outlined,
            ),
            _Campo(
              controller: form.telefonoEmergencia,
              label: 'Teléfono de emergencia',
              hint: '+56912345678',
              keyboardType: TextInputType.phone,
              icon: Icons.emergency_outlined,
            ),
            _Campo(
              controller: form.nombreEmergencia,
              label: 'Nombre del contacto de emergencia',
              icon: Icons.contact_emergency_outlined,
            ),
            if (esPrincipal) ...[
              _Campo(
                controller: form.password!,
                label: 'Contraseña (para iniciar sesión)',
                icon: Icons.lock_outline_rounded,
                obscure: true,
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Mínimo 8 caracteres';
                  }
                  return null;
                },
              ),
              _Campo(
                controller: form.passwordConfirm!,
                label: 'Confirmar contraseña',
                icon: Icons.lock_reset_rounded,
                obscure: true,
                validator: (value) {
                  if (value != form.password!.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MascotaForm {
  final formKey = GlobalKey<FormState>();
  final nombre = TextEditingController();
  final raza = TextEditingController();
  final microchip = TextEditingController();
  EspecieMascota especie = EspecieMascota.canino;

  void dispose() {
    nombre.dispose();
    raza.dispose();
    microchip.dispose();
  }
}

class _PasoMascotas extends StatelessWidget {
  const _PasoMascotas({
    required this.tieneMascotas,
    required this.mascotas,
    required this.onCambiarTieneMascotas,
    required this.onAgregarMascota,
    required this.onEliminarMascota,
  });

  final bool? tieneMascotas;
  final List<_MascotaForm> mascotas;
  final ValueChanged<bool> onCambiarTieneMascotas;
  final VoidCallback onAgregarMascota;
  final ValueChanged<int> onEliminarMascota;

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: '¿Tienes mascotas?',
      descripcion:
          'Registra las mascotas que vivirán en tu unidad. Puedes omitir este '
          'paso si no tienes.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _OpcionCard(
                  titulo: 'Sí, tengo mascotas',
                  icono: Icons.pets_rounded,
                  seleccionado: tieneMascotas == true,
                  onTap: () => onCambiarTieneMascotas(true),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _OpcionCard(
                  titulo: 'No tengo mascotas',
                  icono: Icons.block_rounded,
                  seleccionado: tieneMascotas == false,
                  onTap: () => onCambiarTieneMascotas(false),
                ),
              ),
            ],
          ),
          if (tieneMascotas == true) ...[
            for (var i = 0; i < mascotas.length; i++)
              _TarjetaMascota(
                form: mascotas[i],
                indice: i,
                onEliminar: () => onEliminarMascota(i),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onAgregarMascota,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Agregar otra mascota'),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            'La asociación de la mascota quedará vinculada a la unidad '
            'seleccionada en el paso anterior.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.palette.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaMascota extends StatelessWidget {
  const _TarjetaMascota({
    required this.form,
    required this.indice,
    required this.onEliminar,
  });

  final _MascotaForm form;
  final int indice;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: p.isDark ? 0.18 : 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: Form(
        key: form.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Mascota ${indice + 1}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Quitar',
                  onPressed: onEliminar,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            _Campo(
              controller: form.nombre,
              label: 'Nombre de la mascota',
              icon: Icons.pets_outlined,
            ),
            DropdownButtonFormField<EspecieMascota>(
              initialValue: form.especie,
              decoration: const InputDecoration(
                labelText: 'Especie',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                for (final especie in EspecieMascota.values)
                  DropdownMenuItem(
                    value: especie,
                    child: Text(especie.etiqueta),
                  ),
              ],
              onChanged: (value) {
                if (value != null) form.especie = value;
              },
            ),
            _Campo(
              controller: form.raza,
              label: 'Raza',
              icon: Icons.abc_rounded,
            ),
            _Campo(
              controller: form.microchip,
              label: 'Número de microchip (opcional)',
              hint: '15 dígitos',
              keyboardType: TextInputType.number,
              icon: Icons.memory_rounded,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              validator: (value) {
                final microchip = value?.trim() ?? '';
                if (microchip.isEmpty) return null;
                return microchip.length == 15
                    ? null
                    : 'El microchip debe tener 15 dígitos';
              },
            ),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.photo_camera_back_outlined, size: 18),
              label: const Text('Foto de la mascota (próximamente)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasoFinalizado extends StatelessWidget {
  const _PasoFinalizado({
    required this.mensaje,
    required this.onIrLogin,
    required this.onNuevoRegistro,
  });

  final String mensaje;
  final VoidCallback onIrLogin;
  final VoidCallback onNuevoRegistro;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.accent.withValues(alpha: 0.14),
            ),
            child: Icon(Icons.check_circle_rounded, size: 64, color: p.accent),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '¡Registro enviado!',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$mensaje\n\nUn administrador revisará tu solicitud. Cuando sea '
            'aprobada podrás ingresar con tu correo y contraseña.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: p.inkMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onIrLogin,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Volver al inicio de sesión'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onNuevoRegistro,
            child: const Text('Registrar otra solicitud'),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.titulo,
    required this.descripcion,
    required this.child,
  });

  final String titulo;
  final String descripcion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          descripcion,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: p.inkMuted),
        ),
        const SizedBox(height: AppSpacing.lg),
        child,
      ],
    );
  }
}

class _OpcionCard extends StatelessWidget {
  const _OpcionCard({
    required this.titulo,
    required this.icono,
    required this.seleccionado,
    required this.onTap,
    this.descripcion,
  });

  final String titulo;
  final String? descripcion;
  final IconData icono;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: seleccionado
                ? p.accent.withValues(alpha: 0.12)
                : p.surface.withValues(alpha: p.isDark ? 0.18 : 0.8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: seleccionado ? p.accent : p.border,
              width: seleccionado ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icono,
                color: seleccionado ? p.accent : p.inkMuted,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (descripcion != null)
                      Text(
                        descripcion!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: p.inkMuted),
                      ),
                  ],
                ),
              ),
              if (seleccionado)
                Icon(Icons.check_circle_rounded, color: p.accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  const _Campo({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.obscure = false,
    this.validator,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        validator:
            validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
      ),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCarga extends StatelessWidget {
  const _ErrorCarga({required this.mensaje, required this.onReintentar});

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 42, color: p.danger),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No pudimos cargar las unidades de este proyecto.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: p.inkMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onReintentar,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 42,
            color: context.palette.inkMuted,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(mensaje, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
