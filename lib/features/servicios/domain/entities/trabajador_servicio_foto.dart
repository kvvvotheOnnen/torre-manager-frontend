import 'dart:typed_data';

class TrabajadorServicioFoto {
  const TrabajadorServicioFoto({required this.bytes, required this.nombre});

  final Uint8List bytes;
  final String nombre;
}
