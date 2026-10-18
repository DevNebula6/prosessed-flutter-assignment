import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/utils/formatters.dart';

void main() {
  test('formats prices with two decimals and a dollar sign', () {
    expect(formatPrice(9.99), r'$9.99');
    expect(formatPrice(170), r'$170.00');
    expect(formatPrice(8.9411), r'$8.94');
  });

  test('formats dates as day, short month and year', () {
    expect(formatDate(DateTime(2025, 4, 30)), '30 Apr 2025');
    expect(formatDate(DateTime(2026, 12, 1)), '1 Dec 2026');
  });
}
