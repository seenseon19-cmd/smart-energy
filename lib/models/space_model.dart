/// ══════════════════════════════════════════════════════════════════════════════
/// نموذج المساحة الذكية الموحد — SpaceModel
/// ══════════════════════════════════════════════════════════════════════════════
///
/// الوظيفة: يمثل مساحة ذكية واحدة في النظام (منزل، غرفة، متجر، مكتب...)
///          كل مساحة لها نوع (سكني residential / تجاري commercial) وحد أقصى للأجهزة
/// ══════════════════════════════════════════════════════════════════════════════

class SpaceModel {
  final String id;
  String name;
  String type; // 'residential' أو 'commercial'
  String iconKey;

  bool get isCommercial => type == 'commercial';
  int get deviceLimit => type == 'commercial' ? 12 : 8;

  SpaceModel({
    required this.id,
    required this.name,
    this.type = 'residential',
    this.iconKey = 'home',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'iconKey': iconKey,
      };

  factory SpaceModel.fromMap(Map<String, dynamic> map) => SpaceModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        type: map['type'] ?? 'residential',
        iconKey: map['iconKey'] ?? 'home',
      );
}
