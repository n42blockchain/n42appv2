import 'dart:convert';

class UserInfo{
  String? email;
  String? token;
  String? uuid;
  int? created;
  String? idx_email_hash;
  String? source;
  String? image;
  String? name;
  String? desc;
  String? art_json;
  bool? bind_google_auth_state;
  bool? createWallet;//是否创建了钱包
  String? wallet_addr;
  String? invite_code;

  bool _follower=false;//是否是追随者
  setFollower(bool value){
    _follower=value;
  }
  bool get follower=>_follower;

  bool _following=false;//是否是我关注的
  setFollowing(bool value){
    _following=value;
  }
  bool get following=>_following;
  bool _followAction=false;//是否正在操作follow
  setFollowAction(bool value){
    _followAction=value;
  }
  bool get followAction=>_followAction;

  bool? _isArtist;
  bool get isArtist{
    if(_isArtist !=null)return _isArtist!;
    Map<String, dynamic>? artJson = json.decode(art_json!);
    _isArtist=true;
    if(artJson==null){
      _isArtist=false;
    }else{
      _isArtist=artJson['_id']==null?false:true;
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
      this.art_json,
      this.idx_email_hash,
      this.source,
      this.bind_google_auth_state,
      this.createWallet,
      this.invite_code);

  UserInfo.fromJson(Map<String, dynamic> json){
    email=json['email'] as String?;
    token=json['token'] as String?;
    uuid=json['uuid'] as String?;
    created=json['created'] as int?;
    image=json['image'] as String?;
    name=json['name'] as String?;
    desc=json['desc'] as String?;
    art_json=json['art_json'] as String?;
    idx_email_hash=json['idx_email_hash'] as String?;
    source=json['source'] as String?;
    bind_google_auth_state=json['bind_google_auth_state'] as bool?;
    createWallet=json['createWallet'] as bool?;
    invite_code=json['invite_code'] as String?;
    wallet_addr=json['wallet_addr'] as String?;
  }
  Map<String, dynamic> toJson(){
    return{
      'email': email,
      'token': token,
      'uuid': uuid,
      'created': created,
      'idx_email_hash': idx_email_hash,
      'source': source,
      'image': image,
      'name': name,
      'desc': desc,
      'art_json': art_json,
      'bind_google_auth_state': bind_google_auth_state,
      'createWallet': createWallet,
      'wallet_addr': wallet_addr,
      'invite_code': invite_code,
    };
  }
}