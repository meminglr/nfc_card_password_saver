class CardItem {
  final String id;
  final String name;
  final String password;

  CardItem({required this.id, required this.name, required this.password});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'password': password,
  };

  factory CardItem.fromJson(Map<String, dynamic> json) =>
      CardItem(id: json['id'], name: json['name'], password: json['password']);
}
