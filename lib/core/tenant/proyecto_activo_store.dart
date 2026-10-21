import 'package:shared_preferences/shared_preferences.dart';

/// Almacén del proyecto activo (tenant) seleccionado por el usuario.
abstract interface class ProyectoActivoStore {
  Future<void> saveProyectoId(String proyectoId);

  Future<String?> readProyectoId();

  Future<void> clear();
}

class SharedPreferencesProyectoActivoStore implements ProyectoActivoStore {
  static const _key = 'proyecto_activo_id';

  @override
  Future<void> saveProyectoId(String proyectoId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, proyectoId);
  }

  @override
  Future<String?> readProyectoId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
