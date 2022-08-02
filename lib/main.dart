import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modul2/firebase_options.dart';
import 'package:modul2/login.dart';
import 'package:modul2/model/repo/pulsa.dart';
import 'package:modul2/model/voucher.dart';
import 'package:modul2/network/api/pulsa/pulsa.dart';
import 'package:modul2/network/dio_client.dart';
import 'package:modul2/provider/voucher_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
      create: (_) => VoucherProvider(), child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  initializeNotification() async {
    final fcm = FirebaseMessaging.instance;

    try {
      if (Platform.isIOS) {
        await fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        await fcm.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      debugPrint(
          "Token ${(await FirebaseMessaging.instance.getToken()).toString()}");

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        debugPrint("onMessage title : ${notification!.title}");
        debugPrint("onMessage body : ${notification.body}");
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        debugPrint("onMessageOpenendApp title : ${notification!.title}");
        debugPrint("onMessageOpenendApp body : ${notification.body}");
      });

      FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        debugPrint("onBackgroundMessage title : ${notification!.title}");
        debugPrint("onBackgroundMessage body : ${notification.body}");
      });

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

//fungsi buat ngecek sudah login atau belum
  _checkLoggedIn() async {
    //fungsi ini digunakan untuk mengambil data dari user yang login
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("token") != null) {
      setState(() {
        isLoggedIn = true;
      });
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  @override
  void initState() {
    initializeNotification();
    _checkLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BCA Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //jika sudah login maka diarahkan ke halaman utama
      //jika belum login maka diarahkan ke halaman login
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String nama = "";
  //ambil data nama dari firebase auth
  _ambilData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("token") != null) {
      setState(() {
        nama = prefs.getString('name')!;
      });
    }
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginPage(),
        ));
  }

  @override
  void initState() {
    _ambilData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue[900],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 10),
              height: 80,
              decoration: const BoxDecoration(
                  color: Color.fromRGBO(50, 50, 50, 1),
                  border: Border(
                      bottom: BorderSide(width: 2, color: Colors.white70))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "BCA Mobile",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selamat Datang",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            nama,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton(
                          onPressed: () {
                            _logout();
                          },
                          child: const Text("Logout"))
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        child: CardMainMenu(
                          title: "M-Commerce",
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const MCommerce()));
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        child: CardMainMenu(
                          title: "History",
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const HistoryPage()));
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardMainMenu extends StatelessWidget {
  CardMainMenu({Key? key, required this.title}) : super(key: key);

  String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(color: Colors.blueAccent),
          child: const Icon(
            Icons.shopping_cart,
            color: Colors.white,
            size: 50,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white),
        )
      ],
    );
  }
}

class MCommerce extends StatefulWidget {
  const MCommerce({Key? key}) : super(key: key);

  @override
  State<MCommerce> createState() => _MCommerceState();
}

class _MCommerceState extends State<MCommerce> {
  @override
  Widget build(BuildContext context) {
    //isi menu buat listviewbuilder
    //berisi judul menu dan widget halaman dari menu yang dipilih
    List<Map<String, dynamic>> listMenu = [
      {
        "title": "Voucher Isi Ulang",
        "route": const VoucherIsiUlangPage(),
      },
      {
        "title": "PLN Prabayar",
        "route": const VoucherIsiUlangPage(),
      },
      {
        "title": "PLN Manual Advice",
        "route": const VoucherIsiUlangPage(),
      },
      {
        "title": "Lainnya",
        "route": const VoucherIsiUlangPage(),
      },
      {
        "title": "Inbox",
        "route": const VoucherIsiUlangPage(),
      },
    ];
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueAccent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Bagian judul paling atas
            Container(
              height: 80,
              decoration: const BoxDecoration(
                  color: Color.fromRGBO(50, 50, 50, 1),
                  border: Border(
                      bottom: BorderSide(width: 2, color: Colors.white70))),
              child: const Center(
                child: Text(
                  "m-Commerce",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
            //Bagian menu utama
            Padding(
              padding: const EdgeInsets.all(10),
              child: Expanded(
                child: Container(
                  height: 500,
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(30, 30, 30, 1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white70, width: 2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //judul di menu utama
                      Container(
                        padding: const EdgeInsets.all(10),
                        height: 80,
                        color: const Color.fromRGBO(50, 50, 50, 1),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                child: const Icon(Icons.shopping_cart),
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.blueAccent,
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "m-Commerce",
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent),
                            ),
                          ],
                        ),
                      ),
                      //buat list menu
                      ListView.builder(
                        padding: const EdgeInsets.only(right: 8),
                        shrinkWrap: true,
                        itemCount: listMenu.length,
                        itemBuilder: (BuildContext context, int index) {
                          //menu
                          return ListTile(
                            onTap: () {
                              //navigasi ke halaman yang diambil dari variabel listMenu
                              //secara berurutan
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => listMenu[index]['route']));
                            },
                            title: Text(listMenu[index]['title'],
                                style: const TextStyle(
                                    color: Colors.blueAccent, fontSize: 14)),
                            trailing: const Text(
                              ">",
                              style: TextStyle(
                                  color: Colors.blueAccent, fontSize: 14),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class VoucherIsiUlangPage extends StatefulWidget {
  const VoucherIsiUlangPage({Key? key}) : super(key: key);

  @override
  State<VoucherIsiUlangPage> createState() => _VoucherIsiUlangPageState();
}

class _VoucherIsiUlangPageState extends State<VoucherIsiUlangPage> {
  String noHandphone = "";
  String keterangan = "";
  String noRekening = "26376183";

  @override
  void initState() {
    super.initState();
  }

  //controller buat ambil data textfield
  TextEditingController noHandphoneController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();

//list dropdown menu pilihan pulsa
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(child: Text("Rp. 10.000"), value: "Rp. 10.000"),
      const DropdownMenuItem(child: Text("Rp. 20.000"), value: "Rp. 20.000"),
      const DropdownMenuItem(child: Text("Rp. 50.000"), value: "Rp. 50.000"),
      const DropdownMenuItem(child: Text("Rp. 100.000"), value: "Rp. 100.000"),
    ];
    return menuItems;
  }

//nominal pulsa yang dipilih
  String selectedNominal = "Rp. 10.000";

  _changeNoHandphone(String noHp) {
    //update data setelah input no hp
    setState(() {
      noHandphone = noHp;
    });
  }

  _changeKeterangan(String keterangans) {
    //update data setelah input no hp
    setState(() {
      keterangan = keterangans;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueAccent,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 80,
                padding: const EdgeInsets.only(right: 10),
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(50, 50, 50, 1),
                    border: Border(
                        bottom: BorderSide(width: 2, color: Colors.white70))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 75),
                      child: Text(
                        "m-Commerce",
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                    //button send di pojok kanan
                    ElevatedButton(
                        onPressed: () async {
                          //ngecek dulu textfield pulsa sudah diisi atau belum
                          if (noHandphone == "") {
                            //tampilkan alert dialog peringatan
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Peringatan!"),
                                    content: const Text(
                                        "No handphone tidak boleh kosong!"),
                                    actions: [
                                      //tutup alert dialog
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("OK"))
                                    ],
                                  );
                                });
                          } else {
                            //jika textfield no hp sudah diisi
                            //maka diarahkan ke halaman detail transaksi
                            final prefs = await SharedPreferences.getInstance();
                            Dio dio = Dio();
                            DioClient dioClient = DioClient(dio);
                            PulsaApi pulsaApi = PulsaApi(dioClient: dioClient);
                            PulsaRepository pulsaRepository =
                                PulsaRepository(pulsaApi: pulsaApi);

                            VoucherModel model =
                                await pulsaRepository.createPulsaReq(
                                    noHandphone,
                                    selectedNominal,
                                    keterangan,
                                    prefs.getString("token")!);
                            context.read<VoucherProvider>().addVoucher(model);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => SucessVoucher(
                                      //kirim data nominal dan no hp ke halaman detail transaksi
                                      nominal: selectedNominal,
                                      noHp: noHandphone,
                                      keterangan: keterangan,
                                    )));
                          }
                        },
                        child: const Text("Send"))
                  ],
                ),
              ),
              //Kolom isi no handphone
              Padding(
                padding: const EdgeInsets.all(10),
                child: Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(30, 30, 30, 1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white70, width: 2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "No. Handphone",
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                              Text(
                                noHandphone,
                                style:
                                    const TextStyle(color: Colors.blueAccent),
                              )
                            ],
                          ),
                          trailing: const Text(
                            ">",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                          //ketika kolom no hp ditekan
                          //maka muncul alert dialog untuk isi no hp
                          onTap: () {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      scrollable: true,
                                      content: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("No Handphone"),
                                          TextField(
                                            keyboardType: TextInputType.number,
                                            controller: noHandphoneController,
                                          )
                                        ],
                                      ),
                                      actions: <Widget>[
                                        //tombol jika kita tekan cancel akan menuutup alert dialog
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('Cancel'),
                                        ),
                                        //tombol ketika tekan ok
                                        //sekaligus jalankan fungsi setState ubah nilai nohp
                                        TextButton(
                                          onPressed: () {
                                            _changeNoHandphone(
                                                noHandphoneController.text);
                                            Navigator.pop(context, 'OK');
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ));
                          },
                        ),
                        const Divider(
                          color: Colors.white70,
                          height: 5,
                        ),
                        //kolom dropdown nominal pulsa
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Nominal Voucher ",
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                              DropdownButton(
                                  value: selectedNominal,
                                  //digunakan buat ubah nilai pilihan nominal
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedNominal = newValue!;
                                    });
                                  },
                                  items: dropdownItems,
                                  style:
                                      const TextStyle(color: Colors.blueAccent))
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.white70,
                          height: 5,
                        ),
                        //kolom no rekening
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("No Rekening",
                                  style: TextStyle(color: Colors.blueAccent)),
                              Text(noRekening,
                                  style: const TextStyle(
                                      color: Colors.blueAccent)),
                            ],
                          ),
                          trailing: const Text(">",
                              style: TextStyle(color: Colors.blueAccent)),
                        ),
                        const Divider(
                          color: Colors.white70,
                          height: 5,
                        ),
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Keterangan",
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                              Text(
                                keterangan,
                                style:
                                    const TextStyle(color: Colors.blueAccent),
                              )
                            ],
                          ),
                          trailing: const Text(
                            ">",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                          //ketika kolom no hp ditekan
                          //maka muncul alert dialog untuk isi no hp
                          onTap: () {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      scrollable: true,
                                      content: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("Keterangan"),
                                          TextField(
                                            controller: keteranganController,
                                          )
                                        ],
                                      ),
                                      actions: <Widget>[
                                        //tombol jika kita tekan cancel akan menuutup alert dialog
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('Cancel'),
                                        ),
                                        //tombol ketika tekan ok
                                        //sekaligus jalankan fungsi setState ubah nilai nohp
                                        TextButton(
                                          onPressed: () {
                                            _changeKeterangan(
                                                keteranganController.text);
                                            Navigator.pop(context, 'OK');
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SucessVoucher extends StatelessWidget {
  const SucessVoucher(
      {Key? key,
      required this.nominal,
      required this.noHp,
      required this.keterangan})
      : super(key: key);
  final String nominal;
  final String noHp;
  final String keterangan;

  @override
  Widget build(BuildContext context) {
    //formatter buat tanggal dan jam transaksi
    DateFormat dateFormat = DateFormat("dd-MM-yyyy HH:mm:ss");
    dynamic currentTime = dateFormat.format(DateTime.now());
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                    //fungsi tombol kembali ke halaman utama
                    //sekaligus menutup halaman voucher isi ulang dan detail transaksi
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    )),
                const Text(
                  "Status Pembayaran",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Image.asset(
              "assets/img/check-mark.png",
              height: 150,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Pembayaran Berhasil!",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(30, 30, 30, 1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white70, width: 2)),
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Detail",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Informasi Pemesanan",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                  Text("Pulsa $nominal $noHp",
                      style: const TextStyle(
                          color: Colors.blueAccent, fontSize: 16)),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Jumlah",
                      style: TextStyle(color: Colors.blueAccent)),
                  Text(nominal,
                      style: const TextStyle(
                          color: Colors.blueAccent, fontSize: 16)),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Keterangan",
                      style: TextStyle(color: Colors.blueAccent)),
                  Text(keterangan,
                      style: const TextStyle(
                          color: Colors.blueAccent, fontSize: 16)),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Waktu Transaksi",
                      style: TextStyle(color: Colors.blueAccent)),
                  Text(currentTime,
                      style: const TextStyle(
                          color: Colors.blueAccent, fontSize: 16))
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    //isi menu buat listviewbuilder
    //berisi judul menu dan widget halaman dari menu yang dipilih
    List<Map<String, dynamic>> listMenu = [
      {
        "title": "Voucher Isi Ulang",
        "route": const HistoryVoucherPage(),
      },
      {
        "title": "PLN Prabayar",
        "route": const HistoryVoucherPage(),
      },
      {
        "title": "PLN Manual Advice",
        "route": const HistoryVoucherPage(),
      },
      {
        "title": "Lainnya",
        "route": const HistoryVoucherPage(),
      },
      {
        "title": "Inbox",
        "route": const HistoryVoucherPage(),
      },
    ];
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueAccent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Bagian judul paling atas
            Container(
              height: 80,
              decoration: const BoxDecoration(
                  color: Color.fromRGBO(50, 50, 50, 1),
                  border: Border(
                      bottom: BorderSide(width: 2, color: Colors.white70))),
              child: const Center(
                child: Text(
                  "History",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
            //Bagian menu utama
            Padding(
              padding: const EdgeInsets.all(10),
              child: Expanded(
                child: Container(
                  height: 500,
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(30, 30, 30, 1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white70, width: 2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //judul di menu utama
                      Container(
                        padding: const EdgeInsets.all(10),
                        height: 80,
                        color: const Color.fromRGBO(50, 50, 50, 1),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                child: const Icon(Icons.shopping_cart),
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.blueAccent,
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "History",
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent),
                            ),
                          ],
                        ),
                      ),
                      //buat list menu
                      ListView.builder(
                        padding: const EdgeInsets.only(right: 8),
                        shrinkWrap: true,
                        itemCount: listMenu.length,
                        itemBuilder: (BuildContext context, int index) {
                          //menu
                          return ListTile(
                            onTap: () {
                              //navigasi ke halaman yang diambil dari variabel listMenu
                              //secara berurutan
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => listMenu[index]['route']));
                            },
                            title: Text(listMenu[index]['title'],
                                style: const TextStyle(
                                    color: Colors.blueAccent, fontSize: 14)),
                            trailing: const Text(
                              ">",
                              style: TextStyle(
                                  color: Colors.blueAccent, fontSize: 14),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HistoryVoucherPage extends StatefulWidget {
  const HistoryVoucherPage({Key? key}) : super(key: key);

  @override
  State<HistoryVoucherPage> createState() => _HistoryVoucherPageState();
}

class _HistoryVoucherPageState extends State<HistoryVoucherPage> {
  Future<List<VoucherModel>> ReadJsonData() async {
    final prefs = await SharedPreferences.getInstance();
    Dio dio = Dio();
    DioClient dioClient = DioClient(dio);
    PulsaApi pulsaApi = PulsaApi(dioClient: dioClient);
    PulsaRepository pulsaRepository = PulsaRepository(pulsaApi: pulsaApi);
    return pulsaRepository.getAllPulsaReq(prefs.getString("token")!);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: Column(
          children: [
            Container(
              height: 80,
              decoration: const BoxDecoration(
                  color: Color.fromRGBO(50, 50, 50, 1),
                  border: Border(
                      bottom: BorderSide(width: 2, color: Colors.white70))),
              child: const Center(
                child: Text(
                  "History Voucher",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(50, 50, 50, 1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white70, width: 2),
                  ),
                  child: FutureBuilder<List<VoucherModel>>(
                      future: ReadJsonData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          final error = snapshot.error;
                          return Center(
                            child: Text(
                              "Error: " + error.toString(),
                            ),
                          );
                        } else if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            context.read<VoucherProvider>().list = [];
                          }
                          context.read<VoucherProvider>().list = snapshot.data!;
                          List<VoucherModel> data =
                              context.watch<VoucherProvider>().list;
                          return ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Pulsa ${data[index].nominal}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        data[index].noHp,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      TextEditingController noHpController =
                                          TextEditingController(
                                              text: data[index].noHp);
                                      TextEditingController nominalController =
                                          TextEditingController(
                                              text: data[index].nominal);
                                      TextEditingController
                                          keteranganController =
                                          TextEditingController(
                                              text: data[index].keterangan);
                                      showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                scrollable: true,
                                                content: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text("No Handphone"),
                                                    TextField(
                                                      enabled: false,
                                                      controller:
                                                          noHpController,
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Text("Nominal"),
                                                    TextField(
                                                      enabled: false,
                                                      controller:
                                                          nominalController,
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Text("Keterangan"),
                                                    TextField(
                                                      controller:
                                                          keteranganController,
                                                    )
                                                  ],
                                                ),
                                                actions: <Widget>[
                                                  //tombol jika kita tekan cancel akan menuutup alert dialog
                                                  TextButton(
                                                    onPressed: () async {
                                                      final prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      Dio dio = Dio();
                                                      DioClient dioClient =
                                                          DioClient(dio);
                                                      PulsaApi pulsaApi =
                                                          PulsaApi(
                                                              dioClient:
                                                                  dioClient);
                                                      PulsaRepository
                                                          pulsaRepository =
                                                          PulsaRepository(
                                                              pulsaApi:
                                                                  pulsaApi);
                                                      debugPrint("keterangan : " +
                                                          keteranganController
                                                              .text);
                                                      VoucherModel
                                                          model = await pulsaRepository
                                                              .updatePulsaReq(
                                                                  data[index]
                                                                      .id,
                                                                  keteranganController
                                                                      .text,
                                                                  prefs.getString(
                                                                      "token")!);
                                                      context
                                                          .read<
                                                              VoucherProvider>()
                                                          .updateVoucher(
                                                              index, model);
                                                      context
                                                              .read<
                                                                  VoucherProvider>()
                                                              .list =
                                                          await pulsaRepository
                                                              .getAllPulsaReq(
                                                                  prefs.getString(
                                                                      "token")!);
                                                      setState(() {
                                                        data = context
                                                            .read<
                                                                VoucherProvider>()
                                                            .list;
                                                      });
                                                      Navigator.pop(
                                                          context, 'Edit');
                                                    },
                                                    child: const Text('Edit'),
                                                  ),
                                                  //tombol ketika tekan ok
                                                  //sekaligus jalankan fungsi setState ubah nilai nohp
                                                  TextButton(
                                                    onPressed: () async {
                                                      final prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      Dio dio = Dio();
                                                      DioClient dioClient =
                                                          DioClient(dio);
                                                      PulsaApi pulsaApi =
                                                          PulsaApi(
                                                              dioClient:
                                                                  dioClient);
                                                      PulsaRepository
                                                          pulsaRepository =
                                                          PulsaRepository(
                                                              pulsaApi:
                                                                  pulsaApi);
                                                      pulsaRepository
                                                          .deletePulsaReq(
                                                              data[index].id,
                                                              prefs.getString(
                                                                  "token")!);
                                                      context
                                                          .read<
                                                              VoucherProvider>()
                                                          .deleteVoucher(index);
                                                      Navigator.pop(
                                                          context, 'Delete');
                                                    },
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ));
                                    },
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              });
                        }
                        return Container();
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
