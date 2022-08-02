import 'package:dio/dio.dart';
import 'package:modul2/network/constant/endpoint.dart';
import 'package:modul2/network/dio_client.dart';

class PulsaApi {
  final DioClient dioClient;

  PulsaApi({required this.dioClient});

  Future<Response> getAllPulsa(String token) async {
    try {
      final Response response = await dioClient.get(Endpoints.pulsa,
          options: Options(headers: {"Authorization": "bearer " + token}));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createPulsa(
      String noHp, String nominal, String keterangan, String token) async {
    try {
      final Response response = await dioClient.post(
        Endpoints.pulsa,
        data: {
          "noHp": noHp,
          "nominal": nominal,
          "keterangan": keterangan,
        },
        options: Options(
          followRedirects: false,
          headers: {
            "Authorization": "bearer " + token,
            "Accept": "application/json"
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updatePulsa(int id, String keterangan, String token) async {
    try {
      final Response response = await dioClient.put(
        Endpoints.pulsa + "/$id",
        data: {
          "keterangan": keterangan,
        },
        options: Options(
          headers: {
            "Authorization": "bearer " + token,
            "Accept": "application/json"
          },
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePulsa(int id, String token) async {
    try {
      await dioClient.delete(
        Endpoints.pulsa + "/$id",
        options: Options(
          headers: {"Authorization": "bearer " + token},
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
