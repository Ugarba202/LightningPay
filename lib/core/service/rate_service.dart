class RateService {
  static double btcToLocal({
    required double btc,
    required String currency,
  }) {
    // Mock rates (later replace with API)
    final rates = {
      'NGN': 65000000, // 1 BTC ≈ 65m NGN
      'PKR': 12000000,
      'USD': 43000,
    };

    final rate = rates[currency] ?? 43000;
    return btc * rate;
  }
}
