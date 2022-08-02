import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modul2/main.dart';
import 'package:modul2/model/model_auth.dart';
import 'package:modul2/model/repo/auth.dart';
import 'package:modul2/network/api/auth/auth.dart';
import 'package:modul2/network/dio_client.dart';
import 'package:modul2/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController _email = TextEditingController();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      "Lupa password?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    )
                  ],
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
                            ModelAuth logins = await repo.loginReq(
                                _email.text, _password.text);
                            String getName =
                                await repo.meReq(logins.access_token);
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("token", logins.access_token);
                            prefs.setString("name", getName);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const HomePage(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            const snackBar = SnackBar(
                                content:
                                    Text("Username atau password salah!!"));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        }
                      },
                      child: const Text("Login")),
                ),
                const SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Belum punya akun? Register!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }
}
