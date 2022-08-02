import 'dart:convert';

ModelAuth modelAuthFromJson(String str) => ModelAuth.fromJson(json.decode(str));

String modelAuthToJson(ModelAuth data) => json.encode(data.toJson());

class ModelAuth {
  String access_token;

  ModelAuth({required this.access_token});

  factory ModelAuth.fromJson(Map<String, dynamic> json) => ModelAuth(
        access_token: json["access_token"],
      );

  Map<String, dynamic> toJson() => {
        "access_token": access_token,
      };
}
