class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? salePrice;
  final List<String> imageUrls;
  final List<String> additionalImages;
  final List<String> sizes;
  final List<String> colors;
  final String brand;
  final bool inStock;
  bool isFavorite;

  bool get isOnSale => salePrice != null && salePrice! < price;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.salePrice,
    required this.imageUrls,
    this.additionalImages = const [],
    required this.sizes,
    required this.colors,
    required this.brand,
    required this.inStock,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle both single and multiple image URLs
    final dynamic imageUrlData = json['imageUrl'];
    final List<String> imageUrls = imageUrlData is List
        ? List<String>.from(imageUrlData)
        : [imageUrlData ?? ''];
    final dynamic additionalImagesData = json['additionalImages'];
    final List<String> additionalImages = additionalImagesData is List
        ? List<String>.from(additionalImagesData)
        : [];

    return Product(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      salePrice: json['salePrice']?.toDouble(),
      imageUrls: imageUrls,
      additionalImages: additionalImages,
      sizes: List<String>.from(json['sizes']),
      colors: List<String>.from(json['colors']),
      brand: json['brand'],
      inStock: json['inStock'] ?? false,
      isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'salePrice': salePrice,
      'imageUrl': imageUrls,
      'additionalImages': additionalImages,
      'sizes': sizes,
      'colors': colors,
      'brand': brand,
      'inStock': inStock,
    };
  }

  // First image URL for backwards compatibility and easy access
  String get firstImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  static List<Product> getProducts(List<Map<String, dynamic>> productsJson) {
    return productsJson.map((product) => Product.fromJson(product)).toList();
  }
}
