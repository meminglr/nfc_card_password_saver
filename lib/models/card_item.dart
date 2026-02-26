class CardItem {
  final String id;
  final String name;
  final String password;
  final String? description;
  final int? colorCode;
  final int orderIndex; // Used for custom sorting

  CardItem({
    required this.id,
    required this.name,
    required this.password,
    this.description,
    this.colorCode,
    this.orderIndex = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'password': password,
    'description': description,
    'colorCode': colorCode,
    'orderIndex': orderIndex,
  };

  factory CardItem.fromJson(Map<String, dynamic> json) => CardItem(
    id: json['id'],
    name: json['name'],
    password: json['password'],
    description: json['description'],
    colorCode: json['colorCode'],
    orderIndex: json['orderIndex'] ?? 0, // Fallback to 0 for old cards
  );
}
