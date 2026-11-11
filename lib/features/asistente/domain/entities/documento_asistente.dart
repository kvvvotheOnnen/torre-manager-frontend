import 'package:equatable/equatable.dart';

class DocumentoAsistente extends Equatable {
  const DocumentoAsistente({
    required this.id,
    required this.nombre,
    required this.paginas,
    required this.tamanoTokens,
  });

  final String id;
  final String nombre;
  final int paginas;
  final int tamanoTokens;

  @override
  List<Object?> get props => [id, nombre, paginas, tamanoTokens];
}
