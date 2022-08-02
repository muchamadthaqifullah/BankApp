import 'package:dio/dio.dart';
import 'package:modul2/network/constant/endpoint.dart';
import 'package:modul2/network/dio_client.dart';

class AuthApi {
  final DioClient dioClient;

  AuthApi({required this.dioClient});

  Future<Response> registerApi(
      String email, String password, String name) async {
    try {
      final Response response =
          await dioClient.post(Endpoints.auth + '/register', data: {
        'email': email,
        'password': password,
        'password_confirmation': password,
        'name': name
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> loginApi(String email, String password) async {
    try {
      final Response response =
          await dioClient.post(Endpoints.auth + '/login', data: {
        'email': email,
        'password': password,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> meApi(String token) async {
    try {
      final Response response = await dioClient.post(Endpoints.auth + "/me",
          options: Options(headers: {"Authorization": "bearer " + token}));
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
