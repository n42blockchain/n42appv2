class MiningWithdrawalsDaily {
  //{"count":10,"day":"2025-11-10","total_amount":"50001064322000000000"}
  int? count;
  String? day;
  String? totalAmount;
  MiningWithdrawalsDaily(this.count, this.day, this.totalAmount);
  MiningWithdrawalsDaily.fromJson(Map<String, dynamic> json) {
    count = json['count'] as int?;
    day = json['day'] as String?;
    totalAmount = json['total_amount'] as String?;
  }
  Map<String, dynamic> toJson() {
    return {'count': count, 'day': day, 'total_amount': totalAmount};
  }
}
