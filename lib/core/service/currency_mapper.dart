class CurrencyMapper {
  static String fromCountry(String country) {
    final value = country.toLowerCase();

    if (value.contains('nigeria')) return 'NGN';
    if (value.contains('pakistan')) return 'PKR';
    if (value.contains('united states')) return 'USD';
    if (value.contains('united kingdom')) return 'GBP';
    if (value.contains('ghana')) return 'GHS';
    if (value.contains('kenya')) return 'KES';

    return 'USD'; // fallback
  }
}
