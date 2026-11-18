import 'dart:typed_data';

class PublicacionFoto {
  const PublicacionFoto({required this.bytes, required this.nombre});

  final Uint8List bytes;
  final String nombre;
}
