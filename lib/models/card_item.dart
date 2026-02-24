class CardItem {
  final String id;
  final String name;
  final String password;
  final String? description;

  CardItem({
    required this.id,
    required this.name,
    required this.password,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'password': password,
    'description': description,
  };

  factory CardItem.fromJson(Map<String, dynamic> json) => CardItem(
    id: json['id'],
    name: json['name'],
    password: json['password'],
    description: json['description'],
  );
}
