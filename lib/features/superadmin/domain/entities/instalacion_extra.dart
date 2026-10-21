import 'package:equatable/equatable.dart';

class InstalacionExtra extends Equatable {
  const InstalacionExtra({
    required this.nombre,
    this.tipo,
    this.atributos = const {},
  });

  final String nombre;
  final String? tipo;
  final Map<String, dynamic> atributos;

  @override
  List<Object?> get props => [nombre, tipo, atributos];
}
