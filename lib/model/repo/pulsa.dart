import 'package:dio/dio.dart';
import 'package:modul2/model/voucher.dart';
import 'package:modul2/network/api/pulsa/pulsa.dart';
import 'package:modul2/network/dio_exception.dart';

class PulsaRepository {
  final PulsaApi pulsaApi;
  PulsaRepository({required this.pulsaApi});
  Future<List<VoucherModel>> getAllPulsaReq(String token) async {
    try {
      final response = await pulsaApi.getAllPulsa(token);
      final ad = (response.data['data'] as List)
          .map((e) => VoucherModel.fromJson(e))
          .toList();
      return ad;
    } on DioError catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<VoucherModel> createPulsaReq(
      String noHp, String nominal, String keterangan, String token) async {
    try {
      final response =
          await pulsaApi.createPulsa(noHp, nominal, keterangan, token);
      return VoucherModel.fromJson(response.data["data"]);
    } on DioError catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<VoucherModel> updatePulsaReq(
      int id, String keterangan, String token) async {
    try {
      final response = await pulsaApi.updatePulsa(id, keterangan, token);
      return VoucherModel.fromJson(response.data["data"]);
    } on DioError catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<void> deletePulsaReq(int id, String token) async {
    try {
      final response = await pulsaApi.deletePulsa(id, token);
    } on DioError catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
