import 'package:dio/dio.dart';
import 'package:modul2/model/model_auth.dart';
import 'package:modul2/network/api/auth/auth.dart';
import 'package:modul2/network/dio_exception.dart';

class AuthRepository {
  final AuthApi authApi;

  AuthRepository({required this.authApi});

  Future<ModelAuth> loginReq(String email, String password) async {
    try {
      final response = await authApi.loginApi(email, password);
      if (response.statusCode == 200) {
        return ModelAuth.fromJson(response.data);
      } else {
        return ModelAuth.fromJson(response.data);
      }
    } on DioError catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<String> registerReq(String email, String password, String name) async {
    try {
      final response = await authApi.registerApi(email, password, name);
      if (response.statusCode == 200) {
        return "OK";
      } else {
        return "Something bad happen";
      }
    } on DioError catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<String> meReq(String token) async {
    try {
      final response = await authApi.meApi(token);
      return response.data["name"];
    } on DioError catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
