import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

class Regular {
  static final RegExp _hexRegExp = RegExp(r'^(0x)?[0-9a-fA-F]+$');
  static final RegExp _base58RegExp = RegExp(
    r'^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$',
  );
  static final RegExp _doubleRegExp = RegExp(r'^\d+(\.)?[0-9]');
  static final RegExp _numsRegExp = RegExp(r"^[0-9]+$");
  static final RegExp _passwordRegExp = RegExp(r'^[A-Za-z\d$@$!%*#?&]{8,18}$');
  static final RegExp _captchaRegExp = RegExp(r'^\w{6}$');
  static final RegExp _captcha2RegExp = RegExp(r'^\w{8}$');
  static final RegExp _emailRegExp = RegExp(
    r"^\w+([-+.]\w+)*@\w+([-.]\w+)*.\w+([-.]\w+)*$",
  );

  bool regularHex(String str) => _hexRegExp.hasMatch(str);

  bool regularBase58(String str) => _base58RegExp.hasMatch(str);

  bool regularDouble(String str) => _doubleRegExp.hasMatch(str);

  bool regularNums(String str) => _numsRegExp.hasMatch(str);

  String getMoneyAbbreviation(dynamic money) {
    if (money >= 1000000000000) {
      return '${formartNum(money / 1000000000000, 2, isCrop: true)}T';
    }
    if (money >= 1000000000) {
      return '${formartNum(money / 1000000000, 2, isCrop: true)}B';
    }
    return NumberFormat("#,##0.00", "en_US").format(money);
  }

  String getMoneyAbbreviationDecimal(dynamic money, {int l = 8}) {
    final moneyStr = Decimal.parse(money.toString()).toString();
    final ms = moneyStr.split("");
    String rStr = "0.0{";
    for (int i = l + 3; i < ms.length; i++) {
      if (ms[i] == "0") {
        l++;
      } else {
        rStr += "$l}${moneyStr.substring(i)}";
        break;
      }
    }
    return rStr;
  }

  String formartNum(
    num target,
    int postion, {
    bool isCrop = false,
    bool isFill0 = true,
  }) {
    final t = target.toString();
    if (postion < 0) return t;

    if (t.contains(".")) {
      final decimalPart = t.split(".").last;
      if (decimalPart.length >= postion) {
        if (isCrop) {
          return t.substring(0, t.length - (decimalPart.length - postion));
        }
        return target.toStringAsFixed(postion);
      }
      if (!isFill0) return t;
      return t + "0" * (postion - decimalPart.length);
    }

    if (!isFill0) return t;
    return postion > 0 ? '$t.${"0" * postion}' : t;
  }

  double formartNumDouble(
    num target,
    int postion, {
    bool isCrop = false,
    bool isFill0 = true,
  }) {
    return double.parse(
      formartNum(target, postion, isCrop: isCrop, isFill0: isFill0),
    );
  }

  int? hexToInt(String hex) {
    final normalized = hex.toUpperCase().contains("0X")
        ? '0x${hex.substring(2)}'
        : '0x$hex';
    return int.tryParse(normalized);
  }

  bool isPassword(String pwd) => _passwordRegExp.hasMatch(pwd);

  bool isCaptcha(String captcha) => _captchaRegExp.hasMatch(captcha);

  bool isCaptcha2(String captcha) => _captcha2RegExp.hasMatch(captcha);

  bool isEmail(String email) => _emailRegExp.hasMatch(email);
}
