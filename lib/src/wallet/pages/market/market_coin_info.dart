import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/api/market_api.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/widgets/about_show_dialog.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class MarketCoinInfo extends StatefulWidget {
  Map<String, dynamic> coin;
  MarketCoinInfo(this.coin,{super.key});

  @override
  State<MarketCoinInfo> createState() => _MarketCoinInfoState();
}

class _MarketCoinInfoState extends State<MarketCoinInfo> {
  final oCcy = NumberFormat("#,##0.00########", "en_US");
  double price_change_percentage_24h=0.0;
  Map<String,dynamic>? coinInfo;
  Load load=Load.loading;
  String website="";//官网
  List<dynamic> browsers=[];//浏览器
  String? reddit=null;//红迪
  String? twitter=null;//推特
  String? facebook=null;//脸书
  //String errorMessage="";
  String lang='en';
  Regular regular=Regular();
  @override
  void initState() {
    super.initState();
    price_change_percentage_24h=(widget.coin['price_change_per_24h']==null || widget.coin['price_change_per_24h']=='')?0.0:widget.coin['price_change_per_24h']*1.0;
    getCoinInfo();
  }
  getCoinInfo()async{
    if(widget.coin.length==0)return;
    var list = await MarketApi().getWalletCoinsInfo(widget.coin['coin']);
    //判断查询是否成功
    if (list['error']==false) {
      //查询成功，将币的信息赋值到_coinslist
      List<dynamic>? coins= list['data']['data'];
      if(coins !=null && coins.length >=1){
        for(dynamic c in coins){
          if(c['coin']==widget.coin['coin']){
            setState(() {
              widget.coin=c;
            });
            break;
          }
        }
      }
    }
    coinInfo=await Provider.of<WalletActionProvider>(context,listen: false).getCoinsBaseInfo(widget.coin['coin_gecko_id']);
    if(coinInfo==null){
      load=Load.error;
    }else{
      load=Load.finish;
      browsers=coinInfo!['links']['blockchain_site']??[];
      List<dynamic> wSites=coinInfo!['links']['official_forum_url']??[];//获取官网列表
      for(String ws in wSites){
        if(ws!=""){
          website=ws;
          break;
        }
      }
      reddit=coinInfo!['links']['subreddit_url']??"";//红迪
      String? tt =coinInfo!['links']['twitter_screen_name'];//推特
      if(tt!=null){
        twitter="https://twitter.com/"+tt;
      }
      //脸书
      String? fb=coinInfo!['links']['facebook_username'];
      if(fb!=null){
        facebook="https://www.facebook.com/"+fb;
      }
    }
    if(mounted){
      setState(() {
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: Column(
          children: [
            Container(
              height: ScreenUtil().setWidth(100.0),
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
              child: Row(
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: ScreenUtil().setWidth(80.0),
                      width: ScreenUtil().setWidth(80.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        size: ScreenUtil().setWidth(44.0),
                      ),
                    ),
                  ),
                  Container(
                    height: ScreenUtil().setWidth(80.0),
                    width: ScreenUtil().setWidth(80.0),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(10.0)),
                    child: ImageNetWork(imageUrl:
                        widget.coin['image']??"",
                      placeholder: "assets/img/list.default.png",
                    ),
                  ),
                  Text(
                    '${(widget.coin['coin']??"").toString().toUpperCase()}',
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(36.0),
                    ),
                  ),
                  SizedBox(width: 5,),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '(${widget.coin['name']??""})',
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                        fontSize: ScreenUtil().setSp(20.0),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child:Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30.0),
                        right: ScreenUtil().setWidth(30.0),
                      ),
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(30.0),
                          right: ScreenUtil().setWidth(30.0),
                          bottom: ScreenUtil().setWidth(20.0),
                          top: ScreenUtil().setWidth(20.0)
                      ),
                      height: ScreenUtil().setWidth(440.0),
                      child: Column(
                        children: [
                          Container(
                            height: ScreenUtil().setWidth(100.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '\$${oCcy.format(widget.coin['price']??0)}',
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setWidth(40.0),
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                                SizedBox(width: ScreenUtil().setWidth(20.0),),
                                Text(
                                  "${price_change_percentage_24h > 0 ? "+" : ""}${regular.formartNum(price_change_percentage_24h, 2,isCrop: true)}%",
                                  style: TextStyle(
                                    fontSize:ScreenUtil().setWidth(30.0),
                                    color:AppThemeUtils.getColorByKey(context, price_change_percentage_24h > 0?AppThemeKeys.rightTextColor.name:AppThemeKeys.errorTextColor.name),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          LineChart(widget.coin['kline_default']??[], price_change_percentage_24h > 0?true:false,ScreenUtil().setWidth(240.0),ScreenUtil().setWidth(20.0)),
                          Container(
                            height: ScreenUtil().setWidth(40.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('0H',style: TextStyle(
                                  fontSize: ScreenUtil().setWidth(24.0),
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                ),),
                                Text('24H',style: TextStyle(
                                  fontSize: ScreenUtil().setWidth(24.0),
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                ),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: ScreenUtil().setWidth(360.0),
                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(30.0),
                        vertical: ScreenUtil().setWidth(10.0),
                      ),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: ScreenUtil().setWidth(85.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  S.of(context).g_key_m_2,
                                  style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                    fontSize: ScreenUtil().setSp(30.0),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text('\$${regular.getMoneyAbbreviation(widget.coin['market_cap']??0*1.0,)}',
                                    style: TextStyle(
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                                      fontSize: ScreenUtil().setSp(30.0),
                                    ),
                                    maxLines: 2,
                                    textAlign: TextAlign.end,
                                  ),),

                              ],
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setWidth(85.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  S.of(context).g_key_m_3,
                                  style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                    fontSize: ScreenUtil().setSp(30.0),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text('\$${regular.getMoneyAbbreviation(widget.coin['volume_24h']??0*1.0,)}',
                                    style: TextStyle(
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                                      fontSize: ScreenUtil().setSp(30.0),
                                    ),
                                    maxLines: 2,
                                    textAlign: TextAlign.end,
                                  ),),

                              ],
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setWidth(85.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  S.of(context).g_key_m_4,
                                  style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                    fontSize: ScreenUtil().setSp(30.0),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '${regular.getMoneyAbbreviation(widget.coin['total_supply']??0*1.0)} ${(widget.coin['coin']??"").toString().toUpperCase()}',
                                    //widget.coin['total_supply'].toString(),
                                    style: TextStyle(
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                                      fontSize: ScreenUtil().setSp(30.0),
                                    ),
                                    textAlign: TextAlign.end,
                                    maxLines: 2,
                                  ),),

                              ],
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setWidth(85.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  S.of(context).g_key_m_5,
                                  style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                    fontSize: ScreenUtil().setSp(30.0),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text('${regular.getMoneyAbbreviation(widget.coin['circulating_supply']??0*1.0)} ${(widget.coin['coin']??"").toString().toUpperCase()}',
                                    style: TextStyle(
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                                      fontSize: ScreenUtil().setSp(30.0),
                                    ),
                                    maxLines: 2,
                                    textAlign: TextAlign.end,
                                  ),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: load==Load.finish,
                      child: coinInfo==null?Container():
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              top: ScreenUtil().setWidth(30.0),
                              left: ScreenUtil().setWidth(30.0),
                              right: ScreenUtil().setWidth(30.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(25.0)),
                                  child: Text(
                                    S.of(context).g_key_m_6,
                                    style: TextStyle(
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                                      fontSize: ScreenUtil().setSp(30.0),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(30.0),
                                    right:ScreenUtil().setWidth(30.0),
                                    top: ScreenUtil().setWidth(30.0),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                                    borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        coinInfo!['description'][lang]??"",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setWidth(26.0),
                                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                            overflow: TextOverflow.ellipsis
                                        ),
                                        maxLines: 6,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: (){
                                              AboutShowDialog(context,coinInfo!['description'][lang]??"",S.of(context).g_key_m_6);
                                            },
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              padding: EdgeInsets.symmetric(
                                                vertical: ScreenUtil().setWidth(15.0),
                                                horizontal:ScreenUtil().setWidth(30.0),
                                              ),
                                              margin: EdgeInsets.symmetric(
                                                vertical: ScreenUtil().setWidth(15.0),
                                              ),
                                              child: Text(
                                                S.of(context).g_key_m_7,
                                                style: TextStyle(
                                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                                                  fontSize: ScreenUtil().setSp(30.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(ScreenUtil().setWidth(30.0),),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(25.0)),
                                  child: Text(
                                    S.of(context).g_key_m_8,
                                    style: TextStyle(
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                                      fontSize: ScreenUtil().setSp(30.0),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(30.0),
                                    vertical: ScreenUtil().setWidth(10.0),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                                    borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
                                  ),
                                  child: Column(
                                    children: [
                                      Visibility(
                                        visible: website!="",
                                        child: InkWell(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>BrowserPage(
                                              website,
                                              //S.of(context).g_key_m_9
                                            )));
                                          },
                                          child: Container(
                                            height: ScreenUtil().setWidth(85.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  'assets/img/webshit1.png',
                                                  width: ScreenUtil().setWidth(40.0),
                                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                                ),
                                                SizedBox(width: ScreenUtil().setWidth(30.0),),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    S.of(context).g_key_m_9,
                                                    style: TextStyle(
                                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                                      fontSize: ScreenUtil().setSp(30.0),
                                                    ),
                                                  ),
                                                ),
                                                Icon(Icons.arrow_forward_ios_sharp,
                                                  size: ScreenUtil().setWidth(30.0),
                                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: facebook!=null,
                                        child: InkWell(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>BrowserPage(
                                              facebook!,
                                              //S.of(context).g_key_m_10
                                            )));
                                          },
                                          child: Container(
                                            height: ScreenUtil().setWidth(85.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  'assets/img/facebook.png',
                                                  width: ScreenUtil().setWidth(40.0),
                                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                                ),
                                                SizedBox(width: ScreenUtil().setWidth(30.0),),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    S.of(context).g_key_m_10,
                                                    style: TextStyle(
                                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                                      fontSize: ScreenUtil().setSp(30.0),
                                                    ),
                                                  ),
                                                ),
                                                Icon(Icons.arrow_forward_ios_sharp,
                                                  size: ScreenUtil().setWidth(30.0),
                                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: twitter!=null,
                                        child: InkWell(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>BrowserPage(
                                              twitter!,
                                              //S.of(context).g_key_m_11
                                            )));
                                          },
                                          child: Container(
                                            height: ScreenUtil().setWidth(85.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  'assets/img/twitter.png',
                                                  width: ScreenUtil().setWidth(40.0),
                                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                                ),
                                                SizedBox(width: ScreenUtil().setWidth(30.0),),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    S.of(context).g_key_m_11,
                                                    style: TextStyle(
                                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                                      fontSize: ScreenUtil().setSp(30.0),
                                                    ),
                                                  ),
                                                ),
                                                Icon(Icons.arrow_forward_ios_sharp,
                                                  size: ScreenUtil().setWidth(30.0),
                                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: reddit!=null,
                                        child: InkWell(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>BrowserPage(
                                              reddit!,
                                              //S.of(context).g_key_m_14
                                            )));
                                          },
                                          child: Container(
                                            height: ScreenUtil().setWidth(85.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  'assets/img/reddit.png',
                                                  width: ScreenUtil().setWidth(40.0),
                                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                                ),
                                                SizedBox(width: ScreenUtil().setWidth(30.0),),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    S.of(context).g_key_m_14,
                                                    style: TextStyle(
                                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                                      fontSize: ScreenUtil().setSp(30.0),
                                                    ),
                                                  ),
                                                ),
                                                Icon(Icons.arrow_forward_ios_sharp,
                                                  size: ScreenUtil().setWidth(30.0),
                                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      _browserWidget(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )

          ],
        ),

      ),
    );
  }
  _browserWidget() {
    if (browsers.length == 0)
      return SizedBox();
    List<Widget> childs = [];
    childs.add(Container(
      height: ScreenUtil().setWidth(85.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/img/website.png',
            width: ScreenUtil().setWidth(40.0),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          SizedBox(width: ScreenUtil().setWidth(30.0),),
          Expanded(
            flex: 1,
            child: Text(
              S
                  .of(context)
                  .g_key_m_15,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(30.0),
              ),
            ),
          ),
        ],
      ),
    ),);
    for (String b in browsers) {
      if (b != "") {
        print(b);
        childs.add(InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                BrowserPage(b,
                )));
          },
          child: Container(
            height: ScreenUtil().setWidth(85.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: ScreenUtil().setWidth(70.0),),
                Expanded(
                  flex: 1,
                  child: Text(
                    b,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(30.0),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_forward_ios_sharp,
                  size: ScreenUtil().setWidth(30.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ],
            ),
          ),
        ),);
      }
    }
    return Column(
      children: childs,
    );
  }
}
