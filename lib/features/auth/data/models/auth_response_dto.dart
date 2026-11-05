import 'usuario_dto.dart';

class AuthResponseDTO {
  const AuthResponseDTO({required this.accessToken, required this.usuario});

  final String accessToken;
  final UsuarioDTO usuario;

  factory AuthResponseDTO.fromJson(Map<String, dynamic> json) {
    return AuthResponseDTO(
      accessToken: (json['access_token'] ?? json['token'] ?? '') as String,
      usuario: UsuarioDTO.fromJson(
        (json['user'] ?? json['usuario'] ?? const <String, dynamic>{})
            as Map<String, dynamic>,
      ),
    );
  }
}
