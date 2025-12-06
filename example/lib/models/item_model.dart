class ItemModel {
  final String id;
  final String name;
  final String icon;
  final int order;

  ItemModel({
    required this.id,
    required this.name,
    required this.icon,
    this.order = 0,
  });

  ItemModel copyWith({String? id, String? name, String? icon}) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }
}
