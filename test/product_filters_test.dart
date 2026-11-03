import 'package:autumn_product_manager/product_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const products = [
    ProductRecord(id: '1', name: 'Cedar Mug', price: 12.50),
    ProductRecord(id: '2', name: 'Harvest Tea', price: 18),
    ProductRecord(id: '3', name: 'amber Candle', price: 20),
    ProductRecord(id: '4', name: 'Wool Scarf', price: 32),
    ProductRecord(id: '5', name: 'Autumn Sample', price: 0),
  ];

  test('search is trimmed, case-insensitive, and substring based', () {
    final filter = ProductFilter.parse(
      search: '  cEdAr ',
      minimum: '',
      maximum: '',
    );
    expect(products.where(filter.matches).map((item) => item.id), ['1']);
  });

  test('inclusive range and search conditions are combined', () {
    final range = ProductFilter.parse(
      search: '',
      minimum: '12.50',
      maximum: '20',
    );
    expect(products.where(range.matches).map((item) => item.id), [
      '1',
      '2',
      '3',
    ]);

    final combined = ProductFilter.parse(
      search: 'tea',
      minimum: '12.50',
      maximum: '20',
    );
    expect(products.where(combined.matches).map((item) => item.id), ['2']);
  });

  test('equal, minimum-only, and maximum-only bounds are valid', () {
    final equal = ProductFilter.parse(
      search: '',
      minimum: '12.50',
      maximum: '12.50',
    );
    expect(products.where(equal.matches).map((item) => item.id), ['1']);

    final minimumOnly = ProductFilter.parse(
      search: '',
      minimum: '20',
      maximum: '',
    );
    expect(products.where(minimumOnly.matches).map((item) => item.id), [
      '3',
      '4',
    ]);

    final maximumOnly = ProductFilter.parse(
      search: '',
      minimum: '',
      maximum: '12.50',
    );
    expect(products.where(maximumOnly.matches).map((item) => item.id), [
      '1',
      '5',
    ]);
  });

  test('invalid, nonfinite, negative, and reversed bounds are rejected', () {
    for (final value in ['abc', 'NaN', 'Infinity', '-1']) {
      expect(
        () => ProductFilter.parse(search: '', minimum: value, maximum: ''),
        throwsFormatException,
      );
    }
    expect(
      () => ProductFilter.parse(search: '', minimum: '20', maximum: '10'),
      throwsFormatException,
    );
  });

  test('malformed Firestore-shaped records are rejected', () {
    expect(
      ProductRecord.tryParse(id: 'ok', data: {'name': 'Sample', 'price': 0}),
      isNotNull,
    );
    expect(
      ProductRecord.tryParse(id: 'blank', data: {'name': ' ', 'price': 1}),
      isNull,
    );
    expect(
      ProductRecord.tryParse(id: 'string', data: {'name': 'Mug', 'price': '1'}),
      isNull,
    );
    expect(
      ProductRecord.tryParse(
        id: 'nan',
        data: {'name': 'Mug', 'price': double.nan},
      ),
      isNull,
    );
  });
}
