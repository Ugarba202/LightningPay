class EmailOtpService {
  static final Map<String, String> _otpStore = {};

  static String generateOtp(String email) {
    final otp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
        .toString();
    _otpStore[email] = otp;
    return otp;
  }

  static bool verifyOtp(String email, String otp) {
    return _otpStore[email] == otp;
  }
}
