import 'dart:typed_data';
import 'dart:io' as io;
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/face_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';


class FaceBinding extends StatefulWidget {
  int type;//1绑定，2验证
  String? address;
  int? walletIndex;
  FaceBinding(this.type,{this.address,this.walletIndex,super.key});

  @override
  State<FaceBinding> createState() => _FaceBindingState();
}


class _FaceBindingState extends State<FaceBinding> {
  var faceSdk = FaceSDK.instance;
  Load load=Load.finish;
  bool cameraOK=false;
  var img1 = Image.asset('assets/face/portrait.png');
  String errorMessage="";
  // If 'assets/regula.license' exists, init using license(enables offline match)
  // otherwise init without license.
  Future<bool> initialize() async {
    var license = await loadAssetIfExists("assets/regula.license");
    InitConfig? config = null;
    if (license != null) config = InitConfig(license);
    //var success,error;
    var result = await faceSdk.initialize(config: config);
    if (!result.$1) {
      errorMessage = result.$2!.message;
    }
    return result.$1;
  }
  Future<ByteData?> loadAssetIfExists(String path) async {
    try {
      return await rootBundle.load(path);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }
  init()async{
    if (!await initialize()) return;
    useCamera();
  }
  useCamera() async{
    var response = await faceSdk.startLiveness();
    var image = response.image;
    if (image != null) {
      setState(() {
        errorMessage="";
      });
      binding(image);
    }else{
      setState(() {
        errorMessage=S.of(context).g_face_match_key12;
      });
    }
  }
  binding(Uint8List img)async{
    if(widget.type==1){
      String addr;
      if(widget.address !=null){
        addr=widget.address!;
      }else{
        CoinModel? cm=Provider.of<WalletActionProvider>(context,listen: false).getCoinModelWithCoinType(CoinType.N.name);
        if(cm !=null){
          addr=cm.address;
          //Navigator.pop(context,base64Decode(result.bitmap!.replaceAll("\n", "")));
        }else{
          ToastUtils.show(S.of(context).g_face_match_key5);
          Navigator.pop(context);
          return;
        }
      }
      setState(() {
        load=Load.loading;
        img1=Image.memory(img);
      });
      MessageModel rmm=await FaceApi().binding(addr, img, "face2.jpg",type: 1);
      if(rmm.error){
        //ToastUtils.show(rmm.data);
        Navigator.pop(context,rmm);
      }else{
        if(rmm.data['match']==true){
          MessageModel mm=MessageModel.error();
          mm.data=S.of(context).g_face_match_key10(rmm.data['address']);
          //ToastUtils.show(S.of(context).g_face_match_key10(rmm.data['address']));
          Navigator.pop(context,mm);
        }else{
          //ToastUtils.show(S.of(context).g_face_match_key11(cm.address));
          await Provider.of<WalletActionProvider>(context,listen: false).setWalletFaceBinding(widget.walletIndex);
          MessageModel mm=MessageModel();
          mm.data=S.of(context).g_face_match_key11(addr);
          Navigator.pop(context,mm);
        }
      }
    }
    else{
      setState(() {
        load=Load.loading;
        img1=Image.memory(img);
      });
      MessageModel rmm=await FaceApi().match(img, "face2.jpg",type: 1);
      if(rmm.error){
        //ToastUtils.show(S.of(context).g_face_match_key3);
        Navigator.pop(context,rmm);
      }else{
        if(rmm.data['match']==true){
          //ToastUtils.show(S.of(context).g_face_match_key4(rmm.data['address']));
          MessageModel mm=MessageModel();
          mm.data=rmm.data['address'];
          Navigator.pop(context,mm);
        }else{
          //ToastUtils.show(S.of(context).g_face_match_key3);
          MessageModel mm=MessageModel.error();
          mm.data=S.of(context).g_face_match_key3;
          Navigator.pop(context,false);
        }
      }
    }
  }
  Future<void> initCamera() async {
    if(io.Platform.isIOS){
      String rData=await Trustdart().getPermissions("Camera");
      if(rData !=""){
        if(rData=="notDetermined" || rData=="authorized"){
          cameraOK=true;
        }else{
          cameraOK=false;
        }
      }
    }else{
      var status =await Permission.camera.status;
      if(status.isPermanentlyDenied){
        cameraOK=false;
      }
      else if(status.isLimited){
        cameraOK=false;
      }
      else if(status.isDenied){
        cameraOK=false;
      }
      else{
        cameraOK=true;
      }
    }
    setState(() {});
    if(cameraOK){
      init();
    }
  }
  @override
  Widget build(BuildContext context){
    return cameraOK?
    faceWidget():
    cameraWidget();
  }
  faceWidget(){
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image(height: 300, width: 300, image: img1.image),
                ),
              ),
              if(errorMessage !="")
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(80),
                    horizontal: ScreenUtil().setWidth(30),
                  ),
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor.name),
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                      fontSize: ScreenUtil().setSp(28),
                    ),
                  ),
                ),
              if(errorMessage !="")
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(30),
                  ),
                  height: ScreenUtil().setWidth(88),
                  width: double.infinity,
                  child: ButtonStyle2(context, (){
                    useCamera();
                  }, S.of(context).g_face_match_key12),
                ),
            ],
          ),),
          Positioned.fill(child: Visibility(
            visible: load==Load.loading,
            child: LoadingPage(),
          ),)
        ],
      ),
    );
  }
  cameraWidget(){
    return Scaffold(
        appBar: AppBarWidget(
          text: S.of(context).g_face_match_key6,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                S.of(context).g_key_195,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(36.0),),
              TextButton(onPressed: ()async{
                await openAppSettings();
                initCamera();
              }, child: Text(
                S.of(context).g_face_5,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),),
            ],
          ),
        )
    );
  }
}
