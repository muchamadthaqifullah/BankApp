import 'dart:convert';

VoucherModel voucherModelFromJson(String str) =>
    VoucherModel.fromJson(json.decode(str));

String voucherModelToJson(VoucherModel data) => json.encode(data.toJson());

class VoucherModel {
  int id;
  String noHp;
  String nominal;
  String keterangan;

  VoucherModel(
      {required this.id,
      required this.noHp,
      required this.nominal,
      required this.keterangan});

  factory VoucherModel.fromJson(Map<String, dynamic> json) => VoucherModel(
        id: json["id"],
        noHp: json["noHp"],
        nominal: json["nominal"],
        keterangan: json["keterangan"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "noHp": noHp,
        "nominal": nominal,
        "keterangan": keterangan,
      };
}
