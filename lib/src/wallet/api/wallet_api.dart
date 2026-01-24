import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/generated/l10n.dart';

class WalletApi{
  late String url;
  late Map<String,String> header;
  tokenViewApi(){
    url=AppConfig.getApiUrlOnline('tokenViewUri');
    header={'content-type': 'application/json'};
  }
  //public
  ///获取币列表，主链加代币
  ///chains 返回特定的主链 主链币全名 solna,bitcoin,
  ///coins 返回特定的代币 代币的symbol eth,bnb,ast
  getChainListAll({String chains="",String coins=""})async{
    try{
      //chains="Amaze Chain";
      String condition="";
      if(chains!=""){
        condition="?chains=$chains";
      }
      if(coins!=""){
        if(condition==""){
          condition="?";
        }else{
          condition+="&";
        }
        condition+="coins=$coins";
      }
      String path='${url}v2/chains/coins/v2$condition';
      final a=await BaseApi.RequestEmpty_h.get(path, params: {},header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        mm.error=false;
        mm.data=a['data'];
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  //获取某个主链币的所有代币
  getTokenListFullname(String fullname)async{
    try{
      final a=await BaseApi.RequestEmpty_h.get('${url}v1/chains/coins?chains=$fullname', params: {},header:header,);
      MessageModel mm=MessageModel.error();
      if(a['code']==200){
        List<dynamic> rData=a['data'];
        mm.error=false;
        if(rData.isEmpty){
          mm.data=[];
        }else{
          mm.data=rData[0]['coins'];
        }
      }else{
        mm.data=errorMessage(a['code']);
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }


  String errorMessage(int errorcode){
    if(errorcode==404){
      return S.current.g_key_error_14;
    }else if(errorcode==429){
      return S.current.g_key_error_24;
    }else if(errorcode==500){
      return S.current.g_key_error_5;
    }else if(errorcode==40001){
      return S.current.g_key_error_23;//系统繁忙
    }else if(errorcode==10001){
      return S.current.g_key_error_25;
    }else if(errorcode==10002){
      return S.current.g_key_error_26;
    }else{
      return S.current.g_key_error_3;//未知错误
    }
  }
}
