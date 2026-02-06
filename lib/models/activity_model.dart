// lib/models/activity_model.dart

class Activity {
  final int id;              // ID de la actividad
  final String name;         // Nombre de la actividad
  final String modname;      // Tipo de módulo (assign, forum, quiz, etc.)
  final int visible;         // 0 = oculto, 1 = visible
  final int? duedate;        // Fecha de vencimiento (timestamp Unix)
  final int? availablefrom;  // Fecha de apertura (timestamp Unix)
  final int instance;        // Instancia del módulo en Moodle

  Activity({
    required this.id,
    required this.name,
    required this.modname,
    required this.visible,
    this.duedate,
    this.availablefrom,
    required this.instance,
  });

  // Convertir desde JSON
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      modname: json['modname'] ?? '',
      visible: json['visible'] ?? 0,
      duedate: json['duedate'],
      availablefrom: json['availablefrom'],
      instance: json['instance'] ?? 0,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'modname': modname,
      'visible': visible,
      'duedate': duedate,
      'availablefrom': availablefrom,
      'instance': instance,
    };
  }
}
