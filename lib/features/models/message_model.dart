/// RPC 调用错误模型，当 throw 抛出错误时使用此模型
class MessageModel {
  bool error = false;
  dynamic data;

  MessageModel();

  MessageModel.error() {
    error = true;
  }
}
