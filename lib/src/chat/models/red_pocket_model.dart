class RedPocketModel{
  int? number;
  double? value;
  String? note;
  int? distribution;
  String? tx_raw;
  String? uuid;
  String? nickname;
  String? avatar;
  int? cover;
  RedPocketModel({this.number,this.value,this.note,this.distribution,this.cover,this.uuid,this.nickname,this.avatar});
  RedPocketModel.fromMap(Map<String,dynamic> map){
    number=map['number'] as int?;
    value=map['value'] as double?;
    note=map['note'] as String?;
    distribution=map['distribution'] as int?;
    cover=map['cover'] as int?;
    tx_raw=map['tx_raw'] as String?;
    uuid=map['uuid'] as String?;
    nickname=map['nickname'] as String?;
    avatar=map['avatar'] as String?;
  }
  Map<String, dynamic> RedPocketModelToJson(){
    return {
      "number" : number??0,
      "value" : value??0.0,
      "note" : note??"",
      "distribution" : distribution?? 0,
      "cover" : cover?? 0,
      "tx_raw" : tx_raw??"",
      "uuid" : uuid??"",
      "nickname" : nickname??"",
      "avatar" : avatar??"",
    };
  }
}