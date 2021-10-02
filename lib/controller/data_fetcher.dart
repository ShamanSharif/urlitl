import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:urlitl/model/response.dart';

import 'connection_helper.dart';

class DataFetcher {
  final ConnectionHelper _connectionHelper = ConnectionHelper();

  Future<GoTinyResponse?> goTiny({required String longUrl}) async {
    GoTinyResponse? goTinyResponse;
    String url = "https://gotiny.cc/api";
    dynamic data = {
      "input": longUrl,
    };
    Response<dynamic> response =
        await _connectionHelper.postData(url, data: data);
    if (response.statusCode == 200) {
      goTinyResponse = GoTinyResponse(
        longUrl: response.data[0]["long"],
        shortUrl: "https://gotiny.cc/" + response.data[0]["code"],
      );
    }
    return goTinyResponse;
  }
}
