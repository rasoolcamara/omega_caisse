class Product {
  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.image,
    this.quantity = 0,
  });

  String name;
  int id;
  String image;
  String description;
  num price;
  int quantity = 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as num,
      image: json['path'] as String,
    );
  }
}
