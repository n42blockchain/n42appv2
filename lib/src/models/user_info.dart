import 'dart:convert';

class UserInfo{
  String? email;
  String? token;
  String? uuid;
  int? created;
  String? idxEmailHash;
  String? source;
  String? image;
  String? name;
  String? desc;
  String? artJson;
  bool? bindGoogleAuthState;
  bool? createWallet;//是否创建了钱包
  String? walletAddr;
  String? inviteCode;

  bool _follower=false;//是否是追随者
  void setFollower(bool value){
    _follower=value;
  }
  bool get follower=>_follower;

  bool _following=false;//是否是我关注的
  void setFollowing(bool value){
    _following=value;
  }
  bool get following=>_following;
  bool _followAction=false;//是否正在操作follow
  void setFollowAction(bool value){
    _followAction=value;
  }
  bool get followAction=>_followAction;

  bool? _isArtist;
  bool get isArtist{
    if(_isArtist !=null)return _isArtist!;
    Map<String, dynamic>? artData = json.decode(artJson!);
    _isArtist=true;
    if(artData==null){
      _isArtist=false;
    }else{
      _isArtist=artData['_id']==null?false:true;
    }
    return _isArtist!;
  }

  UserInfo(
      this.email,
      this.token,
      this.uuid,
      this.created,
      this.image,
      this.name,
      this.desc,
      this.artJson,
      this.idxEmailHash,
      this.source,
      this.bindGoogleAuthState,
      this.createWallet,
      this.inviteCode);

  UserInfo.fromJson(Map<String, dynamic> json){
    email=json['email'] as String?;
    token=json['token'] as String?;
    uuid=json['uuid'] as String?;
    created=json['created'] as int?;
    image=json['image'] as String?;
    name=json['name'] as String?;
    desc=json['desc'] as String?;
    artJson=json['art_json'] as String?;
    idxEmailHash=json['idx_email_hash'] as String?;
    source=json['source'] as String?;
    bindGoogleAuthState=json['bind_google_auth_state'] as bool?;
    createWallet=json['createWallet'] as bool?;
    inviteCode=json['invite_code'] as String?;
    walletAddr=json['wallet_addr'] as String?;
  }
  Map<String, dynamic> toJson(){
    return{
      'email': email,
      'token': token,
      'uuid': uuid,
      'created': created,
      'idx_email_hash': idxEmailHash,
      'source': source,
      'image': image,
      'name': name,
      'desc': desc,
      'art_json': artJson,
      'bind_google_auth_state': bindGoogleAuthState,
      'createWallet': createWallet,
      'wallet_addr': walletAddr,
      'invite_code': inviteCode,
    };
  }
}