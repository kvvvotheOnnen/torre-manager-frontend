import 'package:equatable/equatable.dart';

class FuenteAsistente extends Equatable {
  const FuenteAsistente({required this.documento, required this.pagina});

  final String documento;
  final int pagina;

  @override
  List<Object?> get props => [documento, pagina];
}
