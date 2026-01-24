import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'dart:convert';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/security/security_config.dart';

class BaseHttp {
  String baseUrl;
  String baseUrlTest;

  // 创建 Dio 实例
  late Dio _dio;

  late BaseOptions _options;

  ///0：'content-type': 'application/x-www-form-urlencoded'
  ///1:'content-type': 'multipart/form-data'
  int headerThype = 0;
  //String authorizationKey="";
  Map<String,String> headerMap={};
  //构造方法
  //传入正式地址和测试地址
  BaseHttp(this.baseUrl, this.baseUrlTest,this.headerMap, {this.headerThype=0,}) {
    _options = setBaseOptions();
    _dio = Dio(_options);
    // 配置 HttpClientAdapter 使用安全配置进行 SSL 证书验证
    _dio.httpClientAdapter = IOHttpClientAdapter()..createHttpClient=(){
      HttpClient client = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          // 使用统一的安全配置验证证书
          return SecurityConfig.verifySslCertificate(cert, host, port);
        };
      return client;
    };
    //日志拦截器 - 仅在 Debug 模式启用
    /*if (kDebugMode) {
      _dio.interceptors.add(
        DioLoggingInterceptor(
          level: Level.body,
          compact: true,
        ),
      );
    }*/
    //抓包地址 - 仅在 Debug 模式启用
    // if (kDebugMode) setProxy("192.168.0.130:8888");
  }

  /// 代理设置，方便抓包来进行接口调节 设置入口在main函数中
  /*void setProxy(String ip) {
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.findProxy = (uri) {
        return "PROXY $ip";
      };
    };
  }*/

  //重设dio连接
  void reSetDio(bool isTest) {
    _options = setBaseOptions(isTest: isTest);
    _dio = Dio(_options);
  }

  //设置dio的baseUrl
  //isTest：是否使用测试地址，也就是baseUrlTest的地址，默认是false，使用正式地址
  BaseOptions setBaseOptions({bool isTest = false}) {
    Map<String, String> header = {};
    if (headerThype == 0) {
      header = {'content-type': 'application/json'};
    } else if (headerThype == 1) {
      header = {'content-type': 'multipart/form-data',};
    } else {
      header = {'content-type': 'application/x-www-form-urlencoded'};
    }
    header.addAll(headerMap);
    /*if(authorizationKey!=""){
      header['Authorization']=authorizationKey;
    }*/
    return BaseOptions(
      baseUrl: AppConfig.isOnline ? baseUrl : baseUrlTest,
      connectTimeout: Duration(milliseconds: 60000),
      receiveTimeout: Duration(milliseconds: 60000),
      headers: header,
    );
  }

  // _request 是核心函数，所有的请求都会走这里
  //请求方法
  //path：请求的接口地址
  //method：请求类型，暂时是post或get
  //data：请求的参数
  //sendProgress：上传进度回调
  //receiveProgress：下载进度回调
  Future<T> _request<T>(String path,
      {required String method,
        required Map<String,dynamic> params,
        data,
        dynamic sendProgress,
        dynamic receiveProgress,
        var cancelToken, //String? contentType,
        Map<String,dynamic>? header,
        bool defaultReturn=true,//默认方式返回数据，
        Map<String,String>? userInfo,//加到header里的用户信息source=app，uuid，token
      }) async {
    // restful 请求处理
    if (params.isNotEmpty) {
      params.forEach((key, value) {
        if (path.contains(key)) {
          path = path.replaceAll(":$key", value.toString());
        }
      });
    }
    //LogUtil.v(data, tag: '发送的数据为：');
    try {
      //强制忽略https验证
      /*(_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
      };*/
      Options options=Options(method: method);
      if(header !=null){
        if(options.headers==null){
          options.headers=header;
        }else{
          List<String> hds=header.keys.toList();
          for(String k in hds){
            options.headers![k]=header[k];
          }
        }
        if(header["content-type"]==null){
          String conType='application/x-www-form-urlencoded';
          if (headerThype == 0) {
            conType='application/json';
          } else if (headerThype == 1) {
            conType='multipart/form-data';
          }
          options.contentType=conType;
        }
      }else{
        String conType='application/x-www-form-urlencoded';
        if (headerThype == 0) {
          conType='application/json';
        } else if (headerThype == 1) {
          conType='multipart/form-data';
        }
        options.contentType=conType;
      }

      if(userInfo !=null){
        if(options.headers!=null){
          options.headers!.addAll(userInfo);
        }else{
          options.headers=userInfo;
        }
      }
      Response response = await _dio.request(
        path,
        data: data,
        queryParameters: params,
        options: options,
        onSendProgress: (int count, int total) {
          //上传进度回调
          if (sendProgress != null) {
            sendProgress(count, total);
          }
        },
        onReceiveProgress: (int count, int total) {
          //下载进度回调
          if (receiveProgress != null) {
            receiveProgress(count, total);
          }
        },
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {
        try {
          var data = response.data;
          if(data is String){
            json.decode(data.toString());
          }
          if(defaultReturn){
            /// token过期处理
            /*if (mData["code"] != null &&  mData["code"] == -1403) {
              // debugPrint("path: $path");
              // 从新登录 清除状态
              //AppGlobals.logout();
              /*Navigator.pushAndRemoveUntil(
                  AppGlobals.navigatorKey.currentContext!,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const LoginPage()),
                      (route) => false);*/
            }*/
            if (response.data is Map || response.data is List) {
              return response.data;
            } else {
              return json.decode(response.data.toString());
            }
          }else{
            return response.data;
          }

        } catch (e) {
          //LogUtil.v(e, tag: '解析响应数据异常');
          return Future.error(S.current.g_key_error_1);
        }
      } else {
        //LogUtil.v(response.statusCode, tag: 'HTTP错误，状态码为：');
        // EasyLoading.showInfo('HTTP错误，状态码为：${response.statusCode}');
        String message=_handleHttpError(response.statusCode);
        return Future.error(message);
      }
    } on DioException catch (e) {
      return Future.error(_dioError(e));
    } catch (e) {
      return Future.error(S.current.g_key_error_3);
    }
  }
  // 处理 Dio 异常
  String _dioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return S.current.g_key_error_4;
      case DioExceptionType.receiveTimeout:
        return S.current.g_key_error_4;
      case DioExceptionType.sendTimeout:
        return S.current.g_key_error_4;
      case DioExceptionType.connectionError:
        return S.current.g_key_error_4;
      case DioExceptionType.badCertificate:
        //配置的证书错误
        return S.current.g_key_error_27;
      case DioExceptionType.badResponse:
        //配置的状态码不正确，尝试提取具体错误信息
        final response = error.response;
        if (response != null) {
          final data = response.data;
          if (data is Map && data.containsKey('error')) {
            final errorData = data['error'];
            if (errorData is Map && errorData.containsKey('message')) {
              return errorData['message'].toString();
            } else if (errorData is String) {
              return errorData;
            }
          }
          return _handleHttpError(response.statusCode);
        }
        return S.current.g_key_error_28;
      case DioExceptionType.cancel:
        return S.current.g_key_error_8;
      case DioExceptionType.unknown:
        return S.current.g_key_error_10;
    }
  }
  /*String _dioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return S.current.g_key_error_4;
      case DioExceptionType.receiveTimeout:
        return S.current.g_key_error_5;
      case DioExceptionType.sendTimeout:
        return S.current.g_key_error_6;
      case DioExceptionType.badResponse:
        return S.current.g_key_error_7;
      case DioExceptionType.cancel:
        return S.current.g_key_error_8;
      case DioExceptionType.unknown:
        return S.current.g_key_error_10;
      default:
        return S.current.g_key_error_10;
    }
  }*/

  // 处理 Http 错误码
  String _handleHttpError(int? errorCode) {
    String message;
    switch (errorCode) {
      case 400:
        message = S.current.g_key_error_11;
        break;
      case 401:
        message = S.current.g_key_error_12;
        break;
      case 403:
        message = S.current.g_key_error_13;
        break;
      case 404:
        message = S.current.g_key_error_14;
        break;
      case 408:
        message = S.current.g_key_error_15;
        break;
      case 500:
        message = S.current.g_key_error_16;
        break;
      case 501:
        message = S.current.g_key_error_17;
        break;
      case 502:
        message = S.current.g_key_error_18;
        break;
      case 503:
        message = S.current.g_key_error_19;
        break;
      case 504:
        message = S.current.g_key_error_20;
        break;
      case 505:
        message = S.current.g_key_error_21;
        break;
      default:
        message = '${S.current.g_key_error_22}$errorCode';
    }
    return message;
  }

  Future<T> get<T>(
      String path, {
        required Map<String,dynamic> params,
        bool defaultReutrn=true,bool addUserInfo=false,
        Map<String,dynamic>? header,
      }) {
    /*if(addUserInfo){
      params.addAll(getUserToken());
    }*/
    return _request(
        path,
        method: 'get',
        params: params,
        defaultReturn: defaultReutrn,
        userInfo: addUserInfo?getUserToken():null,
        header: header
    );
  }

  Future<T> post<T>(String path,
      {required Map<String,dynamic> params,
        data,
        dynamic sendProgress,
        dynamic receiveProgress,
        var cancelToken,
        //String? contentType,
        Map<String,dynamic>? header,
        bool defaultReutrn=true,
        bool addUserInfo=false,
      }) {
    /*if(addUserInfo){
      data.addAll(getUserToken());
    }*/
    return _request(path,
        method: 'post',
        params: params,
        data: data,
        sendProgress: sendProgress,
        receiveProgress: receiveProgress,
        cancelToken: cancelToken,
        //contentType: contentType,
        defaultReturn: defaultReutrn,
        userInfo: addUserInfo?getUserToken():null,
        header: header
    );
  }
  Future<T> put<T>(String path,
      {required Map<String,dynamic> params,
        data,
        bool defaultReutrn=true,
        bool addUserInfo=false,
        Map<String,dynamic>? header,
      }) {
    /*if(addUserInfo){
      data.addAll(getUserToken());
    }*/
    return _request(path,
        method: 'put',
        params: params,
        data: data,
        defaultReturn: defaultReutrn,
        userInfo: addUserInfo?getUserToken():null,
        header: header
    );
  }
  Future<T> delete<T>(String path,
      {required Map<String,dynamic> params,
        data,
        bool defaultReutrn=true,
        bool addUserInfo=false,
        //String? contentType,
        Map<String,dynamic>? header,
      }) {
    /*if(addUserInfo){
      data.addAll(getUserToken());
    }*/
    return _request(path,
        method: 'delete',
        params: params,
        data: data,
        defaultReturn: defaultReutrn,
        userInfo: addUserInfo?getUserToken():null,
        //contentType:contentType,
        header: header
    );
  }
  //获取用户信息
  Map<String, String>? getUserToken(){
    if(AppGlobals.userInfo !=null){
      Map<String,String> rmm= {
        "Source":"app",
        "Uuid":AppGlobals.userInfo?.uuid??"",
        "Token":AppGlobals.userInfo?.token??"",
      };
      return rmm;
    }else{
      return null;
    }
  }
// 这里只写了 get 和 post，其他的别名大家自己手动加上去就行


}
