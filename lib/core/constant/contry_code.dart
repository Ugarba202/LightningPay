class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flag;
  final String currencyCode;
  final String currencySymbol;

  static Country? getByName(String name) {
    try {
      // Handle cases where name might be "🇳🇬 Nigeria"
      return supportedCountries.firstWhere(
        (c) => name.contains(c.name) || c.name.contains(name),
      );
    } catch (_) {
      return null;
    }
  }

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
    required this.currencyCode,
    required this.currencySymbol,
  });
}

const List<Country> supportedCountries = [
  Country(name: 'Nigeria', code: 'NG', dialCode: '+234', flag: '🇳🇬', currencyCode: 'NGN', currencySymbol: '₦'),
  Country(name: 'United States', code: 'US', dialCode: '+1', flag: '🇺🇸', currencyCode: 'USD', currencySymbol: '\$'),
  Country(name: 'United Kingdom', code: 'GB', dialCode: '+44', flag: '🇬🇧', currencyCode: 'GBP', currencySymbol: '£'),
  Country(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦', currencyCode: 'CAD', currencySymbol: '\$'),
  Country(name: 'Germany', code: 'DE', dialCode: '+49', flag: '🇩🇪', currencyCode: 'EUR', currencySymbol: '€'),
  Country(name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷', currencyCode: 'EUR', currencySymbol: '€'),
  Country(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳', currencyCode: 'INR', currencySymbol: '₹'),
  Country(name: 'Kenya', code: 'KE', dialCode: '+254', flag: '🇰🇪', currencyCode: 'KES', currencySymbol: 'KSh'),
  Country(name: 'South Africa', code: 'ZA', dialCode: '+27', flag: '🇿🇦', currencyCode: 'ZAR', currencySymbol: 'R'),
  Country(name: 'Ghana', code: 'GH', dialCode: '+233', flag: '🇬🇭', currencyCode: 'GHS', currencySymbol: 'GH₵'),
  Country(name: 'Australia', code: 'AU', dialCode: '+61', flag: '🇦🇺', currencyCode: 'AUD', currencySymbol: '\$'),
  Country(name: 'Brazil', code: 'BR', dialCode: '+55', flag: '🇧🇷', currencyCode: 'BRL', currencySymbol: 'R\$'),
  Country(name: 'China', code: 'CN', dialCode: '+86', flag: '🇨🇳', currencyCode: 'CNY', currencySymbol: '¥'),
  Country(name: 'Japan', code: 'JP', dialCode: '+81', flag: '🇯🇵', currencyCode: 'JPY', currencySymbol: '¥'),
  Country(name: 'Mexico', code: 'MX', dialCode: '+52', flag: '🇲🇽', currencyCode: 'MXN', currencySymbol: '\$'),
  Country(name: 'Italy', code: 'IT', dialCode: '+39', flag: '🇮🇹', currencyCode: 'EUR', currencySymbol: '€'),
  Country(name: 'Spain', code: 'ES', dialCode: '+34', flag: '🇪🇸', currencyCode: 'EUR', currencySymbol: '€'),
  Country(name: 'Netherlands', code: 'NL', dialCode: '+31', flag: '🇳🇱', currencyCode: 'EUR', currencySymbol: '€'),
  Country(name: 'Switzerland', code: 'CH', dialCode: '+41', flag: '🇨🇭', currencyCode: 'CHF', currencySymbol: 'CHF'),
  Country(name: 'Sweden', code: 'SE', dialCode: '+46', flag: '🇸🇪', currencyCode: 'SEK', currencySymbol: 'kr'),
  Country(name: 'Norway', code: 'NO', dialCode: '+47', flag: '🇳🇴', currencyCode: 'NOK', currencySymbol: 'kr'),
  Country(name: 'Denmark', code: 'DK', dialCode: '+45', flag: '🇩🇰', currencyCode: 'DKK', currencySymbol: 'kr'),
  Country(name: 'Finland', code: 'FI', dialCode: '+358', flag: '🇫🇮', currencyCode: 'EUR', currencySymbol: '€'),
  Country(name: 'Ireland', code: 'IE', dialCode: '+353', flag: '🇮🇪', currencyCode: 'EUR', currencySymbol: '€'),
  Country(name: 'Belgium', code: 'BE', dialCode: '+32', flag: '🇧🇪', currencyCode: 'EUR', currencySymbol: '€'),
  Country(name: 'Austria', code: 'AT', dialCode: '+43', flag: '🇦🇹', currencyCode: 'EUR', currencySymbol: '€'),
  Country(name: 'Portugal', code: 'PT', dialCode: '+351', flag: '🇵🇹', currencyCode: 'EUR', currencySymbol: '€'),
  Country(name: 'Greece', code: 'GR', dialCode: '+30', flag: '🇬🇷', currencyCode: 'EUR', currencySymbol: '€'),
  Country(name: 'Turkey', code: 'TR', dialCode: '+90', flag: '🇹🇷', currencyCode: 'TRY', currencySymbol: '₺'),
  Country(name: 'Egypt', code: 'EG', dialCode: '+20', flag: '🇪🇬', currencyCode: 'EGP', currencySymbol: 'E£'),
  Country(name: 'Ethiopia', code: 'ET', dialCode: '+251', flag: '🇪🇹', currencyCode: 'ETB', currencySymbol: 'Br'),
  Country(name: 'Morocco', code: 'MA', dialCode: '+212', flag: '🇲🇦', currencyCode: 'MAD', currencySymbol: 'DH'),
  Country(name: 'Algeria', code: 'DZ', dialCode: '+213', flag: '🇩🇿', currencyCode: 'DZD', currencySymbol: 'DA'),
  Country(name: 'Uganda', code: 'UG', dialCode: '+256', flag: '🇺🇬', currencyCode: 'UGX', currencySymbol: 'USh'),
  Country(name: 'Tanzania', code: 'TZ', dialCode: '+255', flag: '🇹🇿', currencyCode: 'TZS', currencySymbol: 'TSh'),
  Country(name: 'Rwanda', code: 'RW', dialCode: '+250', flag: '🇷🇼', currencyCode: 'RWF', currencySymbol: 'FRw'),
  Country(name: 'Senegal', code: 'SN', dialCode: '+221', flag: '🇸🇳', currencyCode: 'XOF', currencySymbol: 'CFA'),
  Country(name: 'Cameroon', code: 'CM', dialCode: '+237', flag: '🇨🇲', currencyCode: 'XAF', currencySymbol: 'CFA'),
  Country(name: 'Ivory Coast', code: 'CI', dialCode: '+225', flag: '🇨🇮', currencyCode: 'XOF', currencySymbol: 'CFA'),
  Country(name: 'United Arab Emirates', code: 'AE', dialCode: '+971', flag: '🇦🇪', currencyCode: 'AED', currencySymbol: 'د.إ'),
  Country(name: 'Saudi Arabia', code: 'SA', dialCode: '+966', flag: '🇸🇦', currencyCode: 'SAR', currencySymbol: '﷼'),
  Country(name: 'Qatar', code: 'QA', dialCode: '+974', flag: '🇶🇦', currencyCode: 'QAR', currencySymbol: '﷼'),
  Country(name: 'Israel', code: 'IL', dialCode: '+972', flag: '🇮🇱', currencyCode: 'ILS', currencySymbol: '₪'),
  Country(name: 'Singapore', code: 'SG', dialCode: '+65', flag: '🇸🇬', currencyCode: 'SGD', currencySymbol: '\$'),
  Country(name: 'Malaysia', code: 'MY', dialCode: '+60', flag: '🇲🇾', currencyCode: 'MYR', currencySymbol: 'RM'),
  Country(name: 'Indonesia', code: 'ID', dialCode: '+62', flag: '🇮🇩', currencyCode: 'IDR', currencySymbol: 'Rp'),
  Country(name: 'Thailand', code: 'TH', dialCode: '+66', flag: '🇹🇭', currencyCode: 'THB', currencySymbol: '฿'),
  Country(name: 'Vietnam', code: 'VN', dialCode: '+84', flag: '🇻🇳', currencyCode: 'VND', currencySymbol: '₫'),
  Country(name: 'Philippines', code: 'PH', dialCode: '+63', flag: '🇵🇭', currencyCode: 'PHP', currencySymbol: '₱'),
  Country(name: 'Argentina', code: 'AR', dialCode: '+54', flag: '🇦🇷', currencyCode: 'ARS', currencySymbol: '\$'),
  Country(name: 'Chile', code: 'CL', dialCode: '+56', flag: '🇨🇱', currencyCode: 'CLP', currencySymbol: '\$'),
  Country(name: 'Colombia', code: 'CO', dialCode: '+57', flag: '🇨🇴', currencyCode: 'COP', currencySymbol: '\$'),
  Country(name: 'Pakistan', code: 'PK', dialCode: '+92', flag: '🇵🇰', currencyCode: 'PKR', currencySymbol: 'Rs'),
  Country(name: 'Bangladesh', code: 'BD', dialCode: '+880', flag: '🇧🇩', currencyCode: 'BDT', currencySymbol: '৳'),
  Country(name: 'New Zealand', code: 'NZ', dialCode: '+64', flag: '🇳🇿', currencyCode: 'NZD', currencySymbol: '\$'),
];
