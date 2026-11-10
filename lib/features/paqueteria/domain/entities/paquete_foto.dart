import 'dart:typed_data';

class PaqueteFoto {
  const PaqueteFoto({required this.bytes, required this.nombre});

  final Uint8List bytes;
  final String nombre;
}
