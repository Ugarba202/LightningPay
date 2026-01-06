class RateService {
  // Mock BTC rates per currency
  static const Map<String, double> _btcRates = {
    'USD': 43000,
    'NGN': 65000000,
    'GHS': 520000,
    'KES': 6700000,
    'PKR': 12000000,
    'GBP': 34000,
  };

  /// Convert BTC → Local currency
  double btcToLocal({
    required double btcAmount,
    required String currency,
  }) {
    final rate = _btcRates[currency];

    if (rate == null) {
      throw Exception('Unsupported currency');
    }

    return btcAmount * rate;
  }

  /// Convert Local → BTC
  double localToBtc({
    required double localAmount,
    required String currency,
  }) {
    final rate = _btcRates[currency];

    if (rate == null) {
      throw Exception('Unsupported currency');
    }

    return localAmount / rate;
  }
}
