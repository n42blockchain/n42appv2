import 'dart:io';
import 'dart:typed_data';
import 'package:n42appv2/src/component/pages/image_crop_page.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/face_api.dart';
import 'package:n42appv2/src/wallet/models/image_upload_model.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart' as i_picker;
import 'package:permission_handler/permission_handler.dart';

class FaceMatch extends StatefulWidget {
  final int matchType;//1相册，2相机
  const FaceMatch(this.matchType,{super.key});

  @override
  State<FaceMatch> createState() => _FaceMatchState();
}

class _FaceMatchState extends State<FaceMatch> with WidgetsBindingObserver{
  Load load=Load.finish;
  var img2 = Image.asset('assets/face/portrait.png');
  ImageUploadModel createModel = ImageUploadModel();
  bool photoOK=false;
  bool cameraOK=false;
  bool _openedSystemSettings = false;
  void init(){
    if(widget.matchType==1){
      getImageFromGallery();
    }else{
      getImageFromCamera();
    }
  }
  //拍照isImgMini
  Future<void> getImageFromCamera() async {
    try {
      final i_picker.ImagePicker picker = i_picker.ImagePicker();
      i_picker.XFile? img =
      await picker.pickImage(source: i_picker.ImageSource.camera);
      if (img != null) {
        createModel.imgType=getImageType(img.path);
        createModel.imageFile = img;
        createModel.imgFile = File(createModel.imageFile!.path);
        createModel.imgTotal = await img.length() * 1.0;
        //createModel.imageInfo.nftType = 0;
        setState(() {
        });
        imageCrop();
      }
    } catch (e) {
      ToastUtils.show(e.toString());
    }
  }
  //相册选择
  Future<void> getImageFromGallery() async {
    try {
      final i_picker.ImagePicker picker = i_picker.ImagePicker();
      i_picker.XFile? img =
      await picker.pickImage(source: i_picker.ImageSource.gallery);
      if (img != null) {
        bool edit=false;
        if(createModel.imageFile==null){
          edit=true;
        }else{
          if(createModel.imageFile!.path !=img.path){
            edit=true;
          }
        }
        if(edit){
          String? imgType=getImageType(img.path);
          if(imgType?.toLowerCase()=="gif"){
            return ;
          }
          createModel.imgType=getImageType(img.path);
          createModel.imageFile = img;
          createModel.imgFile = File(createModel.imageFile!.path);
          createModel.imgTotal = await img.length() * 1.0;
          createModel.imgCount = 0;
          //createModel.imageInfo.nftType = 0;
          createModel.imgMini = null;
          setState(() {
          });
          imageCrop();
        }
      }
    } catch (e) {
      ToastUtils.show(e.toString());
    }
  }
  Future<void> imageCrop()async{
    Uint8List imageData=createModel.imgFile!.readAsBytesSync();
    Uint8List? rImageData=await Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageCropPage(imageData)));
    if(rImageData !=null){
      setState(() {
        createModel.imgMini=rImageData;
        img2=Image.memory(createModel.imgMini!);
      });
    }
  }
  String? getImageType(String path){
    int dotIndex=path.lastIndexOf(".");
    if(dotIndex==-1)return null;
    return path.substring(dotIndex+1);
  }
  Future<void> binding()async{
    if(load==Load.loading)return;
    if(createModel.imgMini==null)return;
    setState(() {
      load=Load.loading;
    });
    MessageModel rmm=await FaceApi().match(createModel.imgMini, "face2.jpg",type: 1);
    if (!mounted) return;
    setState(() {
      load=Load.finish;
    });
    if(rmm.error){
      ToastUtils.show(S.of(context).g_face_match_key3);
      Navigator.pop(context,false);
    }else{
      if(rmm.data['match']==true){
        Navigator.pop(context,rmm.data['address']);
      }else{
        ToastUtils.show(S.of(context).g_face_match_key3);
        Navigator.pop(context,false);
      }
    }
  }

  Future<void> initPhoto() async {
    if(Platform.isIOS){
      String rData=await Trustdart().getPermissions("Photo");
      if(rData !=""){
        if(rData=="notDetermined" || rData=="authorized"){
          photoOK=true;
        }else{
          photoOK=false;
        }
      }
    }else{
      var status =await Permission.photos.status;
      if(status.isPermanentlyDenied){
        photoOK=false;
      }
      else if(status.isLimited){
        photoOK=false;
      }
      else if(status.isDenied){
        photoOK=false;
      }
      else{
        photoOK=true;
      }
    }
    setState(() {});
    if(photoOK){
      init();
    }
  }
  Future<void> initCamera() async {
    if(Platform.isIOS){
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
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPermissions();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  void initPermissions(){
    if(widget.matchType==1){
      initPhoto();
    }else{
      initCamera();
    }
  }
  @override
  Widget build(BuildContext context) {
    if(widget.matchType==1){
      if(photoOK==false){
        return photoWidget();
      }
    }else{
      if(cameraOK==false){
        return cameraWidget();
      }
    }
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_face_match_key7,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40.0)),
                  child: Image(height: ScreenUtil().setWidth(300.0), width: ScreenUtil().setWidth(300.0), image: img2.image),
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(300.0),
                height: ScreenUtil().setWidth(88.0),
                margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(40.0)),
                child: buttonStyle2(context, (){
                  if(load==Load.loading)return;
                  init();
                }, S.of(context).g_face_match_key8),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(300.0),
                height: ScreenUtil().setWidth(88.0),
                child: buttonStyle2(context, (){
                  binding();
                }, S.of(context).g_face_match_key9),
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

  Widget photoWidget(){
    return Scaffold(
        appBar: AppBarWidget(
          text: S.of(context).g_face_match_key7,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                S.of(context).g_key_205,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(36.0),),
              TextButton(onPressed: ()async{
                if(_openedSystemSettings==false){
                  _openedSystemSettings=true;
                  await openAppSettings();
                }
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
  Widget cameraWidget(){
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
                if(_openedSystemSettings==false){
                  _openedSystemSettings=true;
                  await openAppSettings();
                }
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
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_openedSystemSettings) {
        _openedSystemSettings = false;
        initPermissions();
      }
    }
  }
}
