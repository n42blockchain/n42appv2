//调用rpc，当throw抛出错误时使用此模型
class MessageModel{
  bool error=false;
  MessageErrorType type=MessageErrorType.Default;
  dynamic data=null;
  MessageModel();
  MessageModel.error(){
    error=true;
  }
}
enum MessageErrorType{
  Default,
  E1403,//登出状态
}