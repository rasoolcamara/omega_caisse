class AppSetting {
  final int id;
  final String currentVersion;
  final String lastVersion;
  final num amountToPay;
  final String waveAPIKEY;
  final int isPaymentOn;

  AppSetting({
    this.id,
    this.currentVersion,
    this.lastVersion,
    this.amountToPay,
    this.waveAPIKEY,
    this.isPaymentOn,
  });

  factory AppSetting.fromJson(Map<String, dynamic> json) {
    return AppSetting(
      id: json['id'] as int,
      waveAPIKEY: json['wave_api_key'] as String,
      currentVersion: json['current_version'] as String,
      lastVersion: json['last_version'] as String,
      amountToPay: json['amount_to_pay'] as num,
      isPaymentOn: json['is_payment_on'] as int,
    );
  }
}
