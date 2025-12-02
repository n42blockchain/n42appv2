import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
class Regular{
  //是否是十六进制字符串
  bool regular_hex(String str){
    bool r=RegExp(r'^(0x)?[0-9a-fA-F]+$').hasMatch(str);
    return r;
  }
  //判断base58
  bool regular_base58(String str){
    bool r=RegExp(r'^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$').hasMatch(str);
    return r;
  }
  //验证是否是浮点数
  bool regular_double(String str){
    bool r=RegExp(r'^\d+(\.)?[0-9]').hasMatch(str);
    return r;
  }
  //验证数字
  bool regular_nums(String str){
    return RegExp(r"^[0-9]+$").hasMatch(str);
  }
  //返回钱的缩写
  String getMoneyAbbreviation(dynamic money){
    final oCcy = NumberFormat("#,##0.00", "en_US");

    //double r=0;
    String rStr="";
    if(money>=1000000000000){
      String r=formartNum(money/1000000000000, 2,isCrop: true);
      //NumUtil.getNumByValueDouble(money/1000000000000, 3)!.toString();
      rStr=r;//.substring(0,r.length-1);
      return rStr+"T";
    }
    if(money>=1000000000){
      String r=formartNum(money/1000000000, 2,isCrop: true);
      //NumUtil.getNumByValueDouble(money/1000000000, 3)!.toString();
      rStr=r;//.substring(0,r.length-1);
      return rStr+"B";
    }
    return oCcy.format(money);
  }
  //返回小数缩写
  String getMoneyAbbreviation_decimal(dynamic money,{int l=8}){
    String moneyStr=Decimal.parse(money.toString()).toString();
    List<String> ms=moneyStr.split("");
    String rStr="0.0{";
    for(int i=l+3;i<ms.length;i++){
      if(ms[i]=="0"){
        l++;
      }else{
        rStr+="${l}}${moneyStr.substring(i)}";
        break;
      }
    }
    return rStr;
  }

  /**
   * target  要转换的数字
   * postion 要保留的位数
   * isCrop  true 直接裁剪 false 四舍五入
   * isFill0 小数位不足是否补0,true 补0 false 不补0
   */
  String formartNum(num target, int postion, {bool isCrop = false,isFill0=true}) {
    String t = target.toString();
    // 如果要保留的长度小于等于0 直接返回当前字符串
    if (postion < 0) {
      return t;
    }
    if (t.contains(".")) {
      String t1 = t.split(".").last;
      if (t1.length >= postion) {
        if (isCrop) {
          // 直接裁剪
          return t.substring(0, t.length - (t1.length - postion));
        } else {
          // 四舍五入
          return target.toStringAsFixed(postion);
        }
      } else {
        // 不够位数的补相应个数的0
        String t2 = "";
        if(isFill0){
          for (int i = 0; i < postion - t1.length; i++) {
            t2 += "0";
          }
        }
        return t + t2;
      }
    } else {
      String t3="";
      if(isFill0){
        // 不含小数的部分补点和相应的0
        t3 =  postion>0?".":"";

        for (int i = 0; i < postion; i++) {
          t3 += "0";
        }

      }
      return t + t3;
    }
  }
  double formartNum_double(num target,int postion,{bool isCrop = false,isFill0=true}){
    return double.parse(formartNum(target,postion,isCrop:isCrop,isFill0:isFill0));
  }
  //十六进制字符串转int
  int? hexToInt(String hex) {
    int? val;
    if(hex.toUpperCase().contains("0X")){
      String desString = hex.substring(2);
      val = int.tryParse("0x$desString");
    }else {
      val = int.tryParse("0x$hex");
    }
    return val;
  }

  //禁止科学计数法
  String getDoubleWithString(String d) {
    Decimal? deciaml = Decimal.parse(d);
    return deciaml.toString();
  }
  String getDoubleWithDouble(double d) {
    Decimal? deciaml = Decimal.parse(d.toString());
    return deciaml.toString();
  }


  ///是否是一个密码
  bool isPassword(String pwd) {
    RegExp rule = RegExp(r'^[A-Za-z\d$@$!%*#?&]{8,18}$');//RegExp(r'^[0-9A-Za-z]{6,18}$');
    return rule.hasMatch(pwd);
  }
  ///是否是6位验证码
  bool isCaptcha(String captcha) {
    RegExp rule = RegExp(r'^\w{6}$');
    return rule.hasMatch(captcha);
  }

  ///是否是8位验证码
  bool isCaptcha2(String captcha) {
    RegExp rule = RegExp(r'^\w{8}$');
    return rule.hasMatch(captcha);
  }

  ///是否是邮箱
  bool isEmail(String email) {
    RegExp  rule = RegExp(r"^\w+([-+.]\w+)*@\w+([-.]\w+)*.\w+([-.]\w+)*$");
    return rule.hasMatch(email);
  }

  ///验证小数位数
  bool checkDoubleLength(double value,int length){
    String valueStr=value.toString();
    List<String> valueStrs=valueStr.split('.');
    if(valueStrs.length==2){
      int l=valueStrs[1].length;
      if(length>l){
        return true;
      }else{
        return false;
      }
    }
    return true;
  }

}