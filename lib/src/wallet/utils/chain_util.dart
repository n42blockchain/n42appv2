//walletList中使用
import 'package:decimal/decimal.dart';
import 'package:wallet/wallet.dart';
import 'chain_util_data_part1.dart';
import 'chain_util_data_part2.dart';

/// 默认钱包链配置
/// 排序原则：N42主链放首位，其余按知名度和常用程度排列
/// 2026年调整：移除OKT、ZIL等低知名度链，添加ARB、OP、AVAX、MATIC、TON等热门链
Map<String,dynamic> chainUrlMap={
  ...chainUrlDataPart1,
  ...chainUrlDataPart2,
};

//根据 index和默认path 返回新path
String getPathWithIndex(String path,int index){
  List<String> paths=path.split('/');
  if(paths.length>=4){
    int indexOf=paths[paths.length-1].lastIndexOf("'");
    String rPath="";
    for(int i=0;i<paths.length-1;i++){
      rPath+="${paths[i]}/";
    }
    if(indexOf==-1){
      rPath+="$index";
    }else{
      rPath+="$index'";
    }
    return rPath;
  }else{
    return path;
  }
}
Map<String,String>decimalMap={
  "0" :"1.0",
  '1' :"10.0",
  '2' :"100.0",
  '3' :"1000.0",
  '4' :"10000.0",
  '5' :"100000.0",
  '6' :"1000000.0",
  '7' :"10000000.0",
  '8' :"100000000.0",
  '9' :"1000000000.0",
  '10':"10000000000.0",
  '11':"100000000000.0",
  '12':"1000000000000.0",
  '13':"10000000000000.0",
  '14':"100000000000000.0",
  '15':"1000000000000000.0",
  '16':"10000000000000000.0",
  '17':"100000000000000000.0",
  '18':"1000000000000000000.0",
  '19':"10000000000000000000.0",
  '20':"100000000000000000000.0",
  '21':"1000000000000000000000.0",
  '22':"10000000000000000000000.0",
  '23':"100000000000000000000000.0",
  '24':"1000000000000000000000000.0",  // NEAR uses 24 decimals
};
Decimal toEther(String wei,int decimal) {
  int weiLength=wei.length;
  if(weiLength>decimal){
    String wei1=wei.substring(0,weiLength-decimal);
    String wei2="0.${wei.substring(weiLength-decimal)}";
    return Decimal.parse(wei1)+Decimal.parse(wei2);
  }else{
    // Safe access to decimalMap, dynamically calculate if not found
    String? divisor = decimalMap[decimal.toString()];
    // Dynamically calculate the divisor for unsupported decimals
    divisor ??= '${BigInt.from(10).pow(decimal)}.0';
    Decimal dd=(Decimal.parse(wei) / Decimal.parse(divisor)).toDecimal();
    return dd;
  }
}

double toGWei(String wei) {
  int l = wei.length;
  if (l <= 1) {
    return double.parse(wei);
  }

  if (l <= 9) {
    Decimal formatted= (Decimal.parse(wei) / Decimal.parse('1000000000')).toDecimal();
    return formatted.toDouble();
  } else {
    int fix = l - 9;
    String formatted ="${wei.substring(0, fix)}.${wei.substring(fix, l)}";
    return Decimal.parse(formatted).toDouble();
  }
}

BigInt ethToWeiString(String eth,int decimals) {
  List<String> list = eth.split('.');
  if (list.length > 2) {
    return BigInt.from(0);
  }
  BigInt prix = BigInt.parse(list[0]);
  if(decimals==18){
    EtherAmount a =
    EtherAmount.fromBigInt(EtherUnit.ether, prix);
    if (list.length == 1) {
      return a.getInWei;
    }
    int len = list[1].length;
    if(len>18){
      len=18;
    }
    int diff = 18 - len;
    BigInt bDiff = BigInt.parse(list[1]);
    BigInt n = bDiff * BigInt.from(10).pow(diff);
    return a.getInWei + n;
  }else{
    // Safe access to decimalMap, dynamically calculate if not found
    String? decStr = decimalMap[decimals.toString()];
    decStr ??= '${BigInt.from(10).pow(decimals)}.0';
    double dec= double.parse(decStr);
    Decimal rValue=Decimal.parse(eth)*Decimal.parse(dec.toString());
    return rValue.toBigInt();
  }
}
