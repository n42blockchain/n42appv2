class ExchangeAccountModel {
  String? coin;
  int? created;
  String? icon;
  int? id;
  int? updated;
  String? lock;
  String? over;
  String? platform;
  String? coinFullname;

  ExchangeAccountModel(
    this.coin,
    this.created,
    this.icon,
    this.id,
    this.updated,
    this.lock,
    this.over,
    this.platform,
    this.coinFullname,
  );

  ExchangeAccountModel.fromJson(Map<String, dynamic> map) {
    coin = map['coin'] as String?;
    created = map['created'] as int?;
    icon = map['icon'] as String?;
    id = map['id'] as int?;
    updated = map['updated'] as int?;
    lock = map['lock'] as String?;
    over = map['over'] as String?;
    platform = map['platform'] as String?;
    coinFullname = map['coinFullname'] as String?;
  }

  Map<String, dynamic> toJson() => {
        'coin': coin,
        'created': created,
        'icon': icon,
        'id': id,
        'updated': updated,
        'lock': lock,
        'over': over,
        'platform': platform,
        'coinFullname': coinFullname,
      };
}
