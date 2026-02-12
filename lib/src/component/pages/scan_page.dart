import 'dart:io';

import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:n42appv2/generated/l10n.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool cameraOK=false;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool flash=false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }
  @override
  void dispose() {
    // QRViewController is no longer necessary to dispose - it self-disposes when QRView is un-mounted
    super.dispose();
  }
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }
  Future<void> initPlatformState() async {
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
      else{
        cameraOK=true;
      }
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_4,
        actions: [
          IconButton(
            onPressed: ()async{
              await controller?.toggleFlash();
              flash=await controller?.getFlashStatus()??false;
              setState(() {});
            },
            icon: Icon(flash==true?Icons.flash_on:Icons.flash_off,color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),),
          ),
        ],
      ),
      body: SafeArea(
        child: cameraOK?
        _buildQrView(context):
        Center(
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
                initPlatformState();
              }, child: Text(
                S.of(context).g_face_5,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: ScreenUtil().setWidth(16),
          borderLength: ScreenUtil().setWidth(30),
          borderWidth: ScreenUtil().setWidth(1),
          cutOutSize: ScreenUtil().setWidth(600)),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
        if(back==false){
          pop(scanData.code??"");
        }
    });
  }
  bool back=false;
  void pop(String code){
    back=true;
    controller?.stopCamera();
    Navigator.pop(context,code);
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
}
