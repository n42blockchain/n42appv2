class MessageModel {
  bool error;
  dynamic data;

  MessageModel() : error = false;

  MessageModel.error() : error = true;
}
