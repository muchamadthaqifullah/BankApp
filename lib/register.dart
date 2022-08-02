import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modul2/model/repo/auth.dart';
import 'package:modul2/network/api/auth/auth.dart';
import 'package:modul2/network/dio_client.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController _email = TextEditingController();
    TextEditingController _name = TextEditingController();
    TextEditingController _password = TextEditingController();
    return SafeArea(
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Image.asset(
                    "assets/img/logo.png",
                    height: 80,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    //prefixIcon: Icon(Icons.phone_android_outlined),
                    labelText: 'Name',
                  ),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Text is empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _email,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    //prefixIcon: Icon(Icons.phone_android_outlined),
                    labelText: 'Email',
                  ),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Text is empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _password,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  decoration: const InputDecoration(
                    //prefixIcon: Icon(Icons.lock_outline),
                    labelText: 'Password',
                  ),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Text is empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          Dio dio = Dio();
                          DioClient dioClient = DioClient(dio);
                          AuthApi authApi = AuthApi(dioClient: dioClient);
                          AuthRepository repo =
                              AuthRepository(authApi: authApi);

                          try {
                            await repo.registerReq(
                                _email.text, _password.text, _name.text);
                            const snackBar =
                                SnackBar(content: Text("Berhasil register"));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          } catch (e) {
                            const snackBar = SnackBar(
                                content:
                                    Text("Username atau password salah!!"));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        }
                      },
                      child: const Text("Register")),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }
}
