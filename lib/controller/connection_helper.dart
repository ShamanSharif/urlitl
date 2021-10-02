import 'package:dio/dio.dart';

class ConnectionHelper {
  final Dio dio = Dio();

  Future<Response<dynamic>> postData(url, {required dynamic data}) async {
    try {
      Response<dynamic> response = await dio.post(url, data: data);
      return response;
    } on DioError {
      rethrow;
    }
  }
}
