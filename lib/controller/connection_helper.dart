import 'package:dio/dio.dart';

class ConnectionHelper {
  final Dio dio = Dio();

  Future<Response<dynamic>> getData(url,
      {Map<String, dynamic>? queryData}) async {
    try {
      Response<dynamic> response =
          await dio.get(url, queryParameters: queryData);
      return response;
    } on DioError {
      rethrow;
    }
  }
}
