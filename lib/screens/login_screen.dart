import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_redesign_ui/const.dart';
import 'package:instagram_redesign_ui/models/api_response.dart';
import 'package:instagram_redesign_ui/models/user.dart';
import 'package:instagram_redesign_ui/screens/main/home_screen.dart';
import 'package:instagram_redesign_ui/screens/main/navbar.dart';
import 'package:instagram_redesign_ui/screens/register_screen.dart';
import 'package:instagram_redesign_ui/services/user_service.dart';
import 'package:instagram_redesign_ui/widget/textfield.dart';
import "package:shared_preferences/shared_preferences.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool loading = false;

  void _loginUser() async {
    ApiResponse response = await login(txtEmail.text, txtPassword.text);
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Navbar()), (route) => false);
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Form(
        key: formkey,
        child: Center(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: height / 5,
              ),
              Text(
                "SMKN 10 JAKARTA",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontFamily: "Lato",
                    fontWeight: FontWeight.w500),
              ),
              Text(
                "Social Media",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontFamily: "Montserrat"),
              ),
              SizedBox(
                height: height / 5,
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    TextFieldInput(
                      textEditingController: txtEmail,
                      hintText: 'Email',
                      textInputType: TextInputType.emailAddress,
                      validator: (val) =>
                          val.isEmpty ? 'Invalid email address' : null,
                      // textEditingController: _emailController,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    TextFieldInput(
                      validator: (val) =>
                          val.length < 6 ? 'Required at least 6 chars' : null,
                      textEditingController: txtPassword,
                      hintText: 'Password',
                      textInputType: TextInputType.text,
                      // textEditingController: _passwordController,
                      isPass: true,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    MaterialButton(
                      // height: 50,
                      onPressed: () {
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (context) => Navbar(),
                        //   ),
                        // );
                        if (formkey.currentState.validate()) {
                          setState(() {
                            loading = true;
                            _loginUser();
                          });
                        }
                      },
                      minWidth: width,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Lato",
                          ),
                        ),
                      ),
                      color: CustColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: const Text(
                            'Dont have an acount?',
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(),
                            ),
                          ),
                          child: Container(
                            child: const Text(
                              ' Register',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
