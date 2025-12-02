import 'package:n42appv2/src/home/widgets/gesture_password/gesture_password.dart';
import 'package:n42appv2/src/state/public_provider.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_1.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GesturePasswordSetting extends StatefulWidget{
  int type;//0新密码，1重设密码
  String? oldPassword;
  GesturePasswordSetting(this.type,{this.oldPassword,Key? key}):super(key: key);
  @override
  _GesturePasswordSettingState createState()=>_GesturePasswordSettingState();
}

class _GesturePasswordSettingState extends State<GesturePasswordSetting>{
  Map<String,dynamic> cachedData={
    //0：新密码操作步骤
    "0":{
      "1":"",//第一次输入
      "2":"",//第二次输入
      "errorCount":0,//第二次输入错误次数
      "index":"1",//当前进行到第几步了，默认第一步
    },
    //重设密码步骤
    "1":{
      //旧密码输入
      "1":{
        "old":"",//旧密码 数组
        "errorCount":0,//输入错误次数
      },
      "2":"",//新密码首次输入
      "3":"",//新密码二次输入
      "errorCount":0,//第二次输入错误次数
      "index":"1",//当前进行到第几步了，默认第一步
    }
  };
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.type==1){
      cachedData["1"]["1"]["old"]=widget.oldPassword;
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBarWidget(
        text: widget.type==0?S.of(context).g_lock_key16:S.of(context).g_lock_key22,
      ),
      body: Consumer<PublicProvider>(
          builder: (context,pValue,child){
            return gesturePasswordWidget();
          }),
    );
  }
  gesturePasswordWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: ScreenUtil().setWidth(350.0),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(60.0)),
          child: tipTextWidget(),
        ),
        Container(
          alignment: Alignment.center,
          height: ScreenUtil().setWidth(540.0),
          width: double.infinity,
          child: Container(
            height: ScreenUtil().setWidth(540.0),
            width: ScreenUtil().setWidth(540.0),
            child: GesturePassword(
                  (String value)async{
                if(widget.type==0){
                  if(cachedData['0']['index']=="1"){
                    setState(() {
                      cachedData['0']["1"]=value;
                      cachedData['0']["index"]="2";
                    });
                  }else{
                    if(value==cachedData['0']["1"]){
                      //设置密码完成
                      //调用保存设置
                      //退出当前页
                      setState(() {
                        cachedData['0']["2"]=value;
                      });
                      Navigator.pop(context,value);
                    }else{
                      cachedData['0']["errorCount"]=cachedData['0']["errorCount"]+1;
                      if(cachedData['0']["errorCount"]==3){
                        //三次输入错误，重置内容
                        final flag=await TipsDialog1(context, S.of(context).g_lock_key23);
                        if (flag != null && flag) {
                          cachedData['0']["index"]="1";
                          cachedData['0']["errorCount"]=0;
                          cachedData['0']["1"]="";
                        }
                      }
                      setState(() {});
                    }
                  }
                }
                else{
                  if(cachedData['1']['index']=="1"){
                    if(cachedData['1']["1"]["old"]==value){
                      setState(() {
                        cachedData['1']["index"]="2";
                      });
                    }else{
                      cachedData['1']["1"]["errorCount"]=cachedData['1']["1"]["errorCount"]+1;
                      if(cachedData['1']["1"]["errorCount"]==3){
                        //输入三次错误，提示输入错误次数过多返回上一页
                        final flag=await TipsDialog1(context, S.of(context).g_lock_key23);
                        if (flag != null && flag) {
                          cachedData['1']["1"]["errorCount"]=0;
                          Navigator.pop(context);
                        }
                      }
                      setState(() {});
                    }
                  }
                  else if(cachedData['1']['index']=="2"){
                    setState(() {
                      cachedData['1']["2"]=value;
                      cachedData['1']["index"]="3";
                    });
                  }else{
                    if(value==cachedData['1']["2"]){
                      //设置密码完成
                      //调用保存设置
                      //退出当前页
                      setState(() {
                        cachedData['1']["3"]=value;
                      });
                      Navigator.pop(context,value);
                    }else{
                      cachedData['1']["errorCount"]=cachedData['1']["errorCount"]+1;
                      if(cachedData['1']["errorCount"]==3){
                        //三次输入错误，重置内容
                        final flag=await TipsDialog1(context, S.of(context).g_lock_key23);
                        if (flag != null && flag) {
                          cachedData['1']["index"]="1";
                          cachedData['1']["errorCount"]=0;
                          cachedData['1']["2"]="";
                        }
                        setState(() {});
                      }
                    }
                  }
                }
              },
              ScreenUtil().setWidth(180.0),
              answer: getAnswer(),
            ),
          ),
        ),
      ],
    );
  }
  tipTextWidget(){
    String titleStr="";
    String subtitleStr="";
    if(widget.type==0){
      titleStr=S.of(context).g_lock_key17;
      if(cachedData["0"]["index"]=="1"){
        subtitleStr=S.of(context).g_lock_key18;
      }else{
        if(cachedData["0"]["errorCount"] ==0){
          subtitleStr=S.of(context).g_lock_key19;
        }else if(cachedData["0"]["errorCount"] ==2){
          subtitleStr=S.of(context).g_lock_key25("${3-cachedData["0"]["errorCount"]}");
        }else{
          subtitleStr=S.of(context).g_lock_key21("${3-cachedData["0"]["errorCount"]}");
        }
      }
    }else{
      if(cachedData["1"]["index"] =="1"){
        titleStr=S.of(context).g_lock_key20;
        if(cachedData["1"]["1"]["errorCount"] !=0){
          if(cachedData["1"]["1"]["errorCount"] ==2){
            subtitleStr=S.of(context).g_lock_key25("${3-cachedData["1"]["1"]["errorCount"]}");
          }else{
            subtitleStr=S.of(context).g_lock_key21("${3-cachedData["1"]["1"]["errorCount"]}");
          }
        }
      }else{
        titleStr=S.of(context).g_lock_key17;
        if(cachedData["1"]["index"]=="2"){
          subtitleStr=S.of(context).g_lock_key18;
        }else{
          if(cachedData["1"]["errorCount"] ==0){
            subtitleStr=S.of(context).g_lock_key19;
          }else if(cachedData["1"]["errorCount"] ==2){
            subtitleStr=S.of(context).g_lock_key25("${3-cachedData["1"]["errorCount"]}");
          }else{
            subtitleStr=S.of(context).g_lock_key21("${3-cachedData["1"]["errorCount"]}");
          }
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: ScreenUtil().setWidth(140.0),
          alignment: Alignment.center,
          child: Text(
            titleStr,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(32.0),
            ),
          ),
        ),
        Text(
          subtitleStr,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(32.0),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  getAnswer(){
    if(widget.type==0){
      if(cachedData['0']['index']=="1"){
        return null;
      }else{
        return stringToIntArray(cachedData['0']["1"]);
      }
    }else{
      if(cachedData['1']['index']=="1"){
        return stringToIntArray(cachedData['1']["1"]['old']);
      }else if(cachedData['1']['index']=="2"){
        return null;
      }else{
        return stringToIntArray(cachedData['1']["2"]);
      }
    }
  }
  stringToIntArray(String answer){
    List<String> answerStrList=answer.split(',');
    List<int> answerIntList=[];
    for(String value in answerStrList){
      answerIntList.add(int.parse(value));
    }
    return answerIntList;
  }
}