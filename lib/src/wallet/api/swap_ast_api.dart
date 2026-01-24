import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

class SwapAstApi{
  late String url;
  late Map<String,String> header;
  SwapAstApi(){
    url=AppConfig.getApiUrlOnline('nftHost');
    header={'content-type': 'application/json'};
  }
  //获取商品列表
  //type 1nft 2ast
  getNftOrAstList(int type)async{
    try{
      MessageModel mm=MessageModel();
      final data=await BaseApi.requestEmptyH.get("$url/v1/nft-amt/list", params: {"type":type},header: header);
      mm.data=data['data'];
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }

  //获取订单详情
  getNftOrAstDetail(int orderId)async{
    try{
      MessageModel mm=MessageModel();
      final data=await BaseApi.requestEmptyH.get("$url/v1/nft-amt/order/detail", params: {"order_id": orderId},header: header);
      mm.data=data['data'];
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }

  //获取订单列表
  //type 1nft 2ast
  getNftOrAstOrderList(int type, String uuid, {int page = 1, int pageSize = 10})async{
    Map<String, dynamic> getParams = {
      "type":type,
      "uuid":uuid,
      "page":page,
      "page_size":pageSize
    };

    try{
      MessageModel mm = MessageModel();
      final data = await BaseApi.requestEmptyH.get("$url/v1/nft-amt/order/list", params: getParams,header: header);
      mm.data = data['data']['list'];
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }

  //新增订单
  postNftOrAstAddOrder(
      String bAddr,
      String bUuid,
      int astId,
      int type,
      double orderNumber,
      )async{
    Map<String, dynamic> requestParams = {
      "b_addr": bAddr,
      "b_uuid": bUuid,
      "nft_amt_id": astId,
      "type": type,
      "order_num":orderNumber,
    };

    try{
      MessageModel mm = MessageModel();
      final data = await BaseApi.requestEmptyH.post("$url/v1/nft-amt/add/order/v2", params:{}, data: requestParams,header: header);
      if(data['code']==200){
        mm.data = data['data'];
      }else{
        mm.data=data['err'];
        mm.error=true;
      }
      return mm;
    }catch(e){
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  //取消订单
  postNftOrAstCancelOrder(String bUuid,int orderId)async{
    Map<String, dynamic> requestParams = {
      "b_uuid": bUuid,
      "nft_amt_order_id": orderId,
    };

    try{
      MessageModel mm = MessageModel();
      await BaseApi.requestEmptyH.post("$url/v1/nft-amt/cancel/order", params:{}, data: requestParams,header: header);
      mm.data = true;
      return mm;
    }catch(e){
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  //提交支付哈希
  postNftOrAstCommitPay(
      String bUuid,
      int orderId,
      String txHash,
      )async{
    Map<String, dynamic> requestParams = {
      "b_uuid": bUuid,
      "nft_amt_order_id": orderId,
      "tx": txHash
    };

    try{
      MessageModel mm = MessageModel();
      await BaseApi.requestEmptyH.post("$url/v1/nft-amt/commit/pay/tx", params: {}, data: requestParams,header: header);
      mm.data=true;
      return mm;
    }catch(e){
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
}
