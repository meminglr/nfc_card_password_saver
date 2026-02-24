class CardItem {
  final String id;
  final String name;
  final String password;
  final String? description;
  final int? colorCode;

  CardItem({
    required this.id,
    required this.name,
    required this.password,
    this.description,
    this.colorCode,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'password': password,
    'description': description,
    'colorCode': colorCode,
  };

  factory CardItem.fromJson(Map<String, dynamic> json) => CardItem(
    id: json['id'],
    name: json['name'],
    password: json['password'],
    description: json['description'],
    colorCode: json['colorCode'],
  );
}
