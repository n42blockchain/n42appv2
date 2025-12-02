
class WalletInfo {
  //尽可能根据下面的 计算属性 get mnemonicSecure获取助记词
  String? mnemonic;
  String? password;
  Map<String,dynamic> coinSort={"assets":0,"name":-1};//币排序缓存 assets:0降序，1升序,-1不排序,name:0降序，1升序，-1不排序
  int networkIndex=-1;
  String? walletName;
  String? UUID; //此次登录的ID
  Map<String, dynamic>? coinInfo; //币的基本信息
  String? privateKey;
  //生成钱包的时间戳 唯一标识
  //DateTime.now().millisecondsSinceEpoch
  String? timestamp;
  bool? faceBinding;
  bool mainWallet=false;

  WalletInfo(
      {this.walletName,
        this.mnemonic,
        this.password,
        this.privateKey,
        this.UUID,
        this.timestamp,
        this.coinInfo,
      });
  WalletInfo.fromJson(Map<String, dynamic> json){
    walletName=json['walletName'] as String?;
    mnemonic=json['mnemonic'] as String?;
    password=json['password'] as String?;
    privateKey=json['privateKey'] as String?;
    UUID=json['UUID'] as String?;
    timestamp=json['timestamp'] as String?;
    coinInfo=json['coinInfo'] as Map<String, dynamic>?;
    coinSort=json['coinSort'] as Map<String, dynamic>;
    networkIndex=json['networkIndex'] as int;
    faceBinding=json['faceBinding'] as bool?;
    mainWallet=json['mainWallet'] as bool;
  }
  Map<String, dynamic> toJson(){
    return {
      "walletName":walletName,
      "mnemonic":mnemonic,
      "password":password,
      "privateKey":privateKey,
      "UUID":UUID,
      "timestamp":timestamp,
      "coinInfo":coinInfo,
      "coinSort":coinSort,
      "networkIndex":networkIndex,
      "faceBinding":faceBinding,
      "mainWallet":mainWallet,
    };
  }
}