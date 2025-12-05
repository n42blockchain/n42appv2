import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/src/miningV2/pages/keyManagement/mining_output_tip.dart';
import 'package:n42appv2/src/utils/sp_util.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/container_widget.dart';
import 'package:n42appv2/generated/l10n.dart';

class MiningKeyList extends StatefulWidget {
  const MiningKeyList({super.key});

  @override
  State<MiningKeyList> createState() => _MiningKeyListState();
}

class _MiningKeyListState extends State<MiningKeyList> {

  Map<String,dynamic>? miningData;
  List<dynamic> miningList=[];
  List<String> miningKeyList=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMiningData();
  }

  getMiningData()async{
    miningData=await SPUtil().getMiningData();
    if(miningData !=null){
      miningList=miningData!.values.toList();
      miningKeyList=miningData!.keys.toList();
    }
    setState(() {});
  }
  removeKey(int index)async{
    miningData!.remove(miningKeyList[index]);
    await SPUtil().setMiningData(miningData!);
    getMiningData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text:S.of(context).g_mining_key_103,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(
            ScreenUtil().setWidth(30)
        ),
        itemBuilder: (BuildContext context,index){
          Map<String,dynamic> keyValue=miningList[index] as Map<String,dynamic>;
          bool isMining=keyValue['isMining']??false;
          return ContainerStyle1(
            context,
            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
            child:Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(miningKeyList[index],
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                          fontSize: ScreenUtil().setSp(32),
                        ),
                      ),
                      Text(
                        isMining?
                        S.of(context).g_key_193:
                        S.of(context).g_mining_key_102,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, isMining?AppThemeKeys.rightTextColor.name:AppThemeKeys.errorTextColor.name),
                          fontSize: ScreenUtil().setSp(30),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10,),
                if(isMining==false)
                InkWell(
                  onTap: (){
                    removeKey(index);
                  },
                  child: Icon(
                    Icons.delete_forever_outlined,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                    size: ScreenUtil().setWidth(40),
                  ),
                ),
                if(isMining)
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>MiningOutputTip()));
                    },
                    child: Icon(
                      Icons.output_outlined,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      size: ScreenUtil().setWidth(40),
                    ),
                  ),
              ],
            ),
          );
        },
        itemCount: miningList.length,
      ),
    );
  }
}
