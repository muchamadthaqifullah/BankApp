import 'package:flutter/cupertino.dart';
import 'package:modul2/model/voucher.dart';

class VoucherProvider with ChangeNotifier {
  List<VoucherModel> list = [];

  void addVoucher(VoucherModel data) {
    list.add(data);
    notifyListeners();
  }

  void updateVoucher(int index, VoucherModel data) {
    List<VoucherModel> temp = [];
    for (var i = 0; i < list.length; i++) {
      if (i == index) {
        temp.add(data);
        continue;
      }
      temp.add(data);
    }
    list = temp;
    notifyListeners();
  }

  void deleteVoucher(int index) {
    list.removeAt(index);
    notifyListeners();
  }
}
