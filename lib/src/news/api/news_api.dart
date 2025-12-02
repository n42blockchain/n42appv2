import 'package:n42appv2/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:flutter/material.dart';


///@author zhc 2023/2/13 11:21
///@description: 新闻api

class NewsApi {
  late Map<String,String> header;
  NewsApi(){
    header={'content-type': 'application/json'};
  }
  //获取新闻列表
  Future newsList({
    required int skip,
    required int limit
  }) async {
    Map params = {
      "skip": skip * limit,
      "limit": limit
    };
    final data = await BaseApi.RequestEmpty_h.post(
      '${AppConfig.apiUrl['newsHostUrl']}/newsList',
      params: {},
      data: params,header: header,);
    debugPrint("news data: $data");
    return data;
  }

  Future newsDetail(String id) async {
    Map params = {
      "newId":id
    };
    final data = await BaseApi.RequestEmpty_h.post(
      '${AppConfig.apiUrl['newsHostUrl']}/newsList?',
      params: {},
      data: params,header: header,);
    return data;
  }



}
