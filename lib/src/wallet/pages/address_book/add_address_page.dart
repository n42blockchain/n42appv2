import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/pages/scan_page.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/address_book_api.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/models/address_book_model.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/pages/address_book/choose_coins_page.dart';
import 'package:n42appv2/src/wallet/pages/face_matching/face_match.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/container_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:n42appv2/src/widgets/textField_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final descController = TextEditingController();

  final addressFocusNode= FocusNode();
  final nameFocusNode= FocusNode();
  final descFocusNode= FocusNode();

  /// 默认的coin
  var coinName = 'BTC';
  var coinFullName= "Bitcoin";
  var coinType = 'BTC';
  var coinIcon = '';
  var blockchainType=BlockchainType.Bitcoin.name;

  String errorMessage="";
  @override
  void initState() {
    super.initState();
    /// 取出第一个币 作为本页默认的币种
    Future.microtask(() async {
      List<CoinModel> list =
          Provider.of<WalletActionProvider>(context, listen: false)
              .coinModels;
      debugPrint("list ===${list.length}");
      if (list.isNotEmpty) {
        if (mounted) {
          setState(() {
            coinName = list[0].coin["coinType"];
            coinIcon = list[0].coin["icon"];
            blockchainType=list[0].coin["blockchainType"];
          });
        }
      }
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    addressController.dispose();
    nameController.dispose();
    descController.dispose();
    addressFocusNode.dispose();
    nameFocusNode.dispose();
    descFocusNode.dispose();
    super.dispose();
  }

  address_check(String addr)async{
    if(addr==""){
      errorMessage=S.current.g_key_41;
      setState(() {});
      return null;
    }else{
      List<String> addrList=addr.split(":");
      if(addrList.length==2){
        addr=addrList[1];
      }
      bool check=await Trustdart().validateAddress(coinType, addr);
      if(check){
        errorMessage="";
        setState(() {});
        return addr;
      }else{
        if(coinType==CoinType.ETH.name){
          TokenViewApi tokenViewApi=TokenViewApi();
          MessageModel rmm=await tokenViewApi.getEnsResolve(addr);
          if(rmm.error){
            errorMessage=S.current.g_key_t_50;
            setState(() {});
            return null;
          }else{
            errorMessage="";
            setState(() {});
            return rmm.data;
          }
        }else{
          errorMessage=S.current.g_key_t_50;
          setState(() {});
          return null;
        }

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_112,
        actions: [
          GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
              color: Colors.transparent,
              child: Center(
                child: Text(
                  S.of(context).g_key_115,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
              ),
            ),
            onTap: () {
              handlerData();
            },
          )
        ],
      ),
      body: buildContentList(context),
    );
  }

  buildContentList(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30), vertical: ScreenUtil().setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectItem(),
          const SizedBox(
            height: 18,
          ),
          Text(
            S.of(context).address_Information,
            style: TextStyle(
              color:
              AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          _buildAddressView(context)
        ],
      ),
    );
  }

  _buildSelectItem() {
    return GestureDetector(
      onTap: () async {
        final CoinModel? data = await Navigator
            .push(context,MaterialPageRoute(builder: (_) => const ChooseCoinsPage()));
        debugPrint("data -name--->${data?.coin['name']}");
        if (data != null) {
          setState(() {
            // coinName = data.coin["name"];
            coinType = data.coin["coinType"];
            coinName = data.coin["miniName"];
            coinFullName= data.coin['name'];
            //MTC 单独设置icon
            coinIcon = data.coin["icon"]??"";
            blockchainType=data.coin["blockchainType"];
          });
        }
      },
      child: ContainerStyle1(
        context,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0),),
        height: ScreenUtil().setWidth(88.0),
        child: Row(
          children: [
            //mtc单独处理了一下icon
            (coinType == CoinType.N.name)
                ? Image.asset(
              'assets/img/ast.png',
              width: ScreenUtil().setWidth(50.0),
              height: ScreenUtil().setWidth(50.0),
              fit: BoxFit.cover,
            )
                : ImageNetWork(imageUrl:
              coinIcon,
              width: ScreenUtil().setWidth(50.0),
              height: ScreenUtil().setWidth(50.0),
              placeholder: "assets/img/list_default.png",
            ),
            SizedBox(
              width: ScreenUtil().setWidth(24.0),
            ),
            Text(
              '${coinFullName} (${coinName})',
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setWidth(32.0),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: ScreenUtil().setWidth(40.0),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ],
        ),
      ),
    );
  }

  _buildAddressView(BuildContext context) {
    return ContainerStyle1(
      context,
      padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(20.0)),
      child: Column(
        children: [
          scanItem(),
          Divider(
            height: ScreenUtil().setWidth(6.0),
            endIndent: ScreenUtil().setWidth(20.0),
            indent: ScreenUtil().setWidth(20.0),
          ),
          name(),
          Divider(
            height: ScreenUtil().setWidth(6.0),
            endIndent: ScreenUtil().setWidth(20.0),
            indent: ScreenUtil().setWidth(20.0),
          ),
          desc()
        ],
      ),
    );
  }

  scanItem() {
    return TextFieldStyle2(
      context,
      controller: addressController,
      focusNode: addressFocusNode,
      hintText: S.of(context).please_input_address,
      errorMessage: errorMessage,
      onEditingComplete: (){
        FocusScope.of(context).requestFocus(nameFocusNode);
      },
      boxShadow:BoxShadow(
        color: Color(0xff101828).withAlpha((0 * 255).round()),  //底色,阴影颜色
        offset: Offset(0, 0), //阴影位置,从什么位置开始
        blurRadius: ScreenUtil().setWidth(0),  // 阴影模糊层度
        spreadRadius: 0, ),
      bgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      messageMargin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      rightWidget3: blockchainType==BlockchainType.Ethereum.name?Container(
        width: ScreenUtil().setWidth(60.0),
        height: ScreenUtil().setWidth(60.0),
        padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
        child: Icon(
          Icons.face_outlined,
          size: ScreenUtil().setWidth(50.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        ),
      ):null,
      rightOnTap3: blockchainType==BlockchainType.Ethereum.name?faceMatchTypeWidget:null,

      rightWidget1: Container(
        width: ScreenUtil().setWidth(60.0),
        height: ScreenUtil().setWidth(60.0),
        padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
        child: Image.asset(
          "assets/wallet/scan.png",
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainBlueColor.name),
          width: ScreenUtil().setWidth(50.0),
          height: ScreenUtil().setWidth(50.0),
        ),
      ),
      rightOnTap1: () async {
        /// 扫描
        String? data = await Navigator
            .push(context,MaterialPageRoute(builder: (_) => ScanPage()));
        if(data != null){
          setState(() {
            addressController.text = data;
          });
        }
      },
      rightWidget2: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
        //margin: EdgeInsets.only(left: 10,),
        height: ScreenUtil().setWidth(60.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
            borderRadius: BorderRadius.all(Radius.circular(60.0))
        ),
        child: Text(
          S.of(context).g_key_166,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
            fontSize: ScreenUtil().setSp(26.0),
          ),
        ),
      ),
      rightOnTap2: () async {
        //复制
        //读取剪切板
        ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
        if (data != null) {
          if (data.text != null && data.text != "null") {
            addressController.text = data.text!;
          }
        }
      },
    );
  }

  name() {
    return TextFieldStyle2(
      context,
      controller: nameController,
      focusNode: nameFocusNode,
      hintText: S.of(context).g_key_nft_2,
      boxShadow:BoxShadow(
        color: Color(0xff101828).withAlpha((0 * 255).round()),  //底色,阴影颜色
        offset: Offset(0, 0), //阴影位置,从什么位置开始
        blurRadius: ScreenUtil().setWidth(0),  // 阴影模糊层度
        spreadRadius: 0, ),
      bgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      onEditingComplete: (){
        FocusScope.of(context).requestFocus(descFocusNode);
      },
    );
  }

  desc() {
    return TextFieldStyle2(
      context,
      controller: descController,
      focusNode: descFocusNode,
      hintText: S.of(context).descO,
      boxShadow:BoxShadow(
        color: Color(0xff101828).withAlpha((0 * 255).round()),  //底色,阴影颜色
        offset: Offset(0, 0), //阴影位置,从什么位置开始
        blurRadius: ScreenUtil().setWidth(0),  // 阴影模糊层度
        spreadRadius: 0, ),
      bgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      onEditingComplete: (){
        FocusScope.of(context).requestFocus(addressFocusNode);
      },
    );
  }

  void handlerData() async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    String? address = addressController.text.trim();

    address=await address_check(address);
    if(address==null){
      return;
    }
    if (coinType.isEmpty) {
      ///选择币类型
      ToastUtils.show(S.of(context).g_key_address_3);
      return;
    }
    if (address.isEmpty) {
      ToastUtils.show(S.of(context).g_key_address_2);
      return;
    }
    if (name.isEmpty) {
      ToastUtils.show(S.of(context).g_key_address_1);
      return;
    }

    AddressBookModel info = AddressBookModel();
    info.coinName = coinName;
    info.coinIcon = coinIcon;
    info.address = address;
    info.name = name;
    info.desc = desc;

    try {
      /// save 到数据库中去
      final code = await AddressBookApi().saveAddressBookItem(info);
      if (code != 0) {
        Navigator.of(context).pop(true);
      } else {
        //保存失败
      }
    } catch (err) {
    }
  }
  faceMatchTypeWidget(){
    Widget child=Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: ()async{
            String? address=await Navigator.push(context,
                MaterialPageRoute(builder: (_) => FaceMatch(1)));
            if(address !=null){
              setState(() {
                addressController.text = address;
              });
            }
            Navigator.pop(context);
          },
          child: Container(
            height: ScreenUtil().setWidth(88.0),
            width: double.infinity,
            child: Text(
              S.of(context).photograph,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(32.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        InkWell(
          onTap: ()async{
            String? address=await Navigator.push(context,
                MaterialPageRoute(builder: (_) => FaceMatch(2)));
            if(address !=null){
              addressController.text = address;
            }
            Navigator.pop(context);
          },
          child: Container(
            height: ScreenUtil().setWidth(88.0),
            width: double.infinity,
            child: Text(
              S.of(context).g_key_nft_16,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(32.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
    SheetBottom(context, S.of(context).g_face_match_key1, child);
  }
}
