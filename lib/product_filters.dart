class ProductRecord {
  const ProductRecord({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;
  final double price;

  static ProductRecord? tryParse({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final name = data['name'];
    final price = data['price'];
    if (name is! String ||
        name.trim().isEmpty ||
        price is! num ||
        !price.isFinite ||
        price < 0) {
      return null;
    }
    return ProductRecord(id: id, name: name.trim(), price: price.toDouble());
  }
}

class ProductFilter {
  const ProductFilter({this.search = '', this.minimum, this.maximum});

  final String search;
  final double? minimum;
  final double? maximum;

  factory ProductFilter.parse({
    required String search,
    required String minimum,
    required String maximum,
  }) {
    final parsedMinimum = _parseBound(minimum, 'Minimum price');
    final parsedMaximum = _parseBound(maximum, 'Maximum price');
    if (parsedMinimum != null &&
        parsedMaximum != null &&
        parsedMinimum > parsedMaximum) {
      throw const FormatException(
        'Minimum price cannot be greater than maximum price.',
      );
    }
    return ProductFilter(
      search: search.trim().toLowerCase(),
      minimum: parsedMinimum,
      maximum: parsedMaximum,
    );
  }

  static double? _parseBound(String raw, String label) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null || !value.isFinite || value < 0) {
      throw FormatException('$label must be a finite number of zero or more.');
    }
    return value;
  }

  bool matches(ProductRecord product) {
    return product.name.toLowerCase().contains(search) &&
        (minimum == null || product.price >= minimum!) &&
        (maximum == null || product.price <= maximum!);
  }
}
