class MiningWithdrawalsDaily{
  //{"count":10,"day":"2025-11-10","total_amount":"50001064322000000000"}
  int? count;
  String? day;
  String? total_amount;
  MiningWithdrawalsDaily(this.count,this.day,this.total_amount);
  MiningWithdrawalsDaily.fronJson(Map<String, dynamic> json){
    count=json['count'] as int?;
    day=json['day'] as String?;
    total_amount=json['total_amount'] as String?;
  }
  Map<String, dynamic> toJson(){
    return{
      'count': count,
      'day': day,
      'total_amount': total_amount,
    };
  }
}