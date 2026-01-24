import 'dart:convert';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/chat/models/red_pocket_claim_model.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RedPocketGroup3 extends StatefulWidget {
  final ChatMessageModel? chatMessage;
  const RedPocketGroup3(this.chatMessage,{super.key});

  @override
  State<RedPocketGroup3> createState() => _RedPocketGroup3State();
}

class _RedPocketGroup3State extends State<RedPocketGroup3> {
  Map<String,dynamic> content={};
  String message="Error";
  RedPocketClaimModel? redPocketClaimModel;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    content=json.decode(widget.chatMessage?.decryptionMessageContent??"{}");
    redPocketClaimModel=getClaim(AppGlobals.userInfo?.uuid??"");
    if(redPocketClaimModel !=null){
      if(redPocketClaimModel?.status==0){
        message="You will receive the above amount in 20s";
      }else if(redPocketClaimModel?.status==2){
        message="领取失败";
      }else{
        message="领取成功";
      }
    }else{
      message="Hands are slow";
    }
  }
  getClaim(String uuid){
    widget.chatMessage?.redPocketDetailModel?.red_claim?.sort((RedPocketClaimModel a,RedPocketClaimModel b)=>b.value!.compareTo(a.value!));
    int? index = widget.chatMessage?.redPocketDetailModel?.red_claim?.indexWhere((element) {
      if(element.uuid==uuid){
        return true;
      }
      return false;
    });
    if(index !=null && index !=-1){
      return widget.chatMessage!.redPocketDetailModel!.red_claim![index];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: ScreenUtil().setWidth(850.0),
              child: Image.asset("assets/chat/redPocket2.png",fit: BoxFit.cover,),
            ),
            Positioned(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: ScreenUtil().setWidth(850.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: ScreenUtil().setWidth(60.0),
                                height: ScreenUtil().setWidth(60.0),
                                margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0),top: ScreenUtil().setWidth(20.0),),
                                child: Icon(
                                  Icons.close,
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: ScreenUtil().setSp(60.0),
                              height: ScreenUtil().setSp(60.0),
                              margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(60.0)),
                              ),
                              child: ImageNetWork(
                                imageUrl: content['avatar']??"",
                                width: ScreenUtil().setSp(60.0),
                                height: ScreenUtil().setSp(60.0),
                                placeholder: "assets/chat/user_def_icon.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                            Text(
                              content['nickname']??"",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(28.0),
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Container(
                          height: ScreenUtil().setWidth(100.0),
                          width: double.infinity,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(100.0),top: ScreenUtil().setWidth(50.0)),
                          child: Text(
                            widget.chatMessage?.redPocketDetailModel?.description??"",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(32.0),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(96.0),
                          height: ScreenUtil().setWidth(96.0),
                          child: Image.asset("assets/img/ast.png",fit: BoxFit.cover,),
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(top: ScreenUtil().setWidth(10.0)),
                          alignment: Alignment.center,
                          child: Text(
                            "${redPocketClaimModel?.value??0} ${CoinType.N.name}",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(60.0),
                              fontWeight: FontWeight.w600,
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30.0)),
                          child: RichText(
                            text: TextSpan(
                                text: message,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28.0),
                                  fontWeight: FontWeight.w400,
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                                ),
                                children: [
                                  if(redPocketClaimModel !=null)
                                    TextSpan(
                                      text: 'View >',
                                      style: TextStyle(
                                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                                        fontWeight: FontWeight.w700,
                                        fontSize: ScreenUtil().setSp(28.0),
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          setState(() {

                                          });
                                        },
                                    ),
                                ]
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: ScreenUtil().setWidth(10.0)),
                    alignment: Alignment.center,
                    child: Text(
                      "Lucky List",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(48.0),
                        fontWeight: FontWeight.w600,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: ScreenUtil().setWidth(10.0)),
                    alignment: Alignment.center,
                    child: Text(
                      "Opend ${(widget.chatMessage?.redPocketDetailModel?.count??0)-(widget.chatMessage?.redPocketDetailModel?.remain_count??0)}/${widget.chatMessage?.redPocketDetailModel?.count??0}",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28.0),
                        fontWeight: FontWeight.w400,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: widget.chatMessage?.redPocketDetailModel?.red_claim?.length,
                      itemBuilder: (context,int index){
                        RedPocketClaimModel? rpcm=widget.chatMessage?.redPocketDetailModel?.red_claim?[index];
                        String redUrl="";
                        if(index==0){
                          redUrl="red1";
                        }else if(index==1){
                          redUrl="red3";
                        }else if(index==2){
                          redUrl="red2";
                        }
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                          child: Row(
                            children: [
                              Container(
                                width: ScreenUtil().setSp(80.0),
                                height: ScreenUtil().setSp(80.0),
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(80.0)),
                                ),
                                child: ImageNetWork(
                                  imageUrl: rpcm?.avatar_url??"",
                                  width: ScreenUtil().setSp(80.0),
                                  height: ScreenUtil().setSp(80.0),
                                  placeholder: "assets/chat/user_def_icon.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if(redUrl !="")
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
                                  child: Image.asset("assets/chat/$redUrl.png",width: ScreenUtil().setWidth(48.0),height: ScreenUtil().setWidth(48.0),),
                                ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "${rpcm?.nickname??""}${rpcm?.uuid==redPocketClaimModel?.uuid?" (You)":""}",
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(32.0),
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                "${rpcm?.value??0} ${CoinType.N.name}",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28.0),
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}