class AppUser {
  final String uid;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String country;
  final String accountNumber;
  final double btcBalance;
  final double localBalance;
  final String currency;
  final String walletAddress;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.country,
    required this.accountNumber,
    required this.btcBalance,
    required this.localBalance,
    required this.currency,
    required this.walletAddress,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'],
      fullName: data['fullName'],
      username: data['username'],
      email: data['email'],
      phone: data['phone'],
      country: data['country'],
      accountNumber: data['accountNumber'],
      btcBalance: (data['wallet']['btcBalance'] as num).toDouble(),
      localBalance: (data['wallet']['localBalance'] as num).toDouble(),
      currency: data['wallet']['currency'],
      walletAddress: data['wallet']['address'],
    );
  }
}
