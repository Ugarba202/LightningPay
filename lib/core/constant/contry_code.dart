class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

const List<Country> supportedCountries = [
  Country(
    name: 'Nigeria',
    code: 'NG',
    dialCode: '+234',
    flag: '🇳🇬',
  ),
  Country(
    name: 'United States',
    code: 'US',
    dialCode: '+1',
    flag: '🇺🇸',
  ),
  Country(
    name: 'United Kingdom',
    code: 'GB',
    dialCode: '+44',
    flag: '🇬🇧',
  ),
  Country(
    name: 'Canada',
    code: 'CA',
    dialCode: '+1',
    flag: '🇨🇦',
  ),
  Country(
    name: 'Germany',
    code: 'DE',
    dialCode: '+49',
    flag: '🇩🇪',
  ),
  Country(
    name: 'France',
    code: 'FR',
    dialCode: '+33',
    flag: '🇫🇷',
  ),
  Country(
    name: 'India',
    code: 'IN',
    dialCode: '+91',
    flag: '🇮🇳',
  ),
  Country(
    name: 'Kenya',
    code: 'KE',
    dialCode: '+254',
    flag: '🇰🇪',
  ),
  Country(
    name: 'South Africa',
    code: 'ZA',
    dialCode: '+27',
    flag: '🇿🇦',
  ),
  Country(
    name: 'Ghana',
    code: 'GH',
    dialCode: '+233',
    flag: '🇬🇭',
  ),
];
