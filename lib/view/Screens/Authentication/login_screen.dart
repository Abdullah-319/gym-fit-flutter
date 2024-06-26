import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softec_app_dev/utils/colors.dart';
import 'package:softec_app_dev/view/Screens/Authentication/sign_up_page.dart';
import 'package:softec_app_dev/view/Screens/Authentication/verify_email.dart';
import 'package:softec_app_dev/view_model/login_controller.dart';
import '../../../utils/utils.dart';
import '../bottom_navigation.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = Get.put(LoginController());

  @override
  void dispose() {
    super.dispose();
    controller.clearFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
        child: Form(
          key: controller.key.value,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: Get.height * 0.06,
                ),
                SizedBox(
                    height: Get.height * .35,
                    child: Lottie.asset('assets/animations/dumble.json')),

                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Welcome to Health Life',
                    style: GoogleFonts.poppins(
                        fontSize: Get.height * 0.034,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: Get.height * .05,
                ),

                // Email
                SizedBox(
                  height: Get.height * 0.11,
                  child: SizedBox(
                    height: Get.height * 0.1,
                    child: TextFormField(
                      validator: (text) {
                        if (text == null) {
                          return 'Null';
                        }
                        if (text.isEmpty) {
                          return 'Required Field';
                        }
                        if (!text.contains('@gmail.com')) {
                          return 'Invalid Email';
                        }
                        return null;
                      },
                      controller: controller.emailController.value,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(CupertinoIcons.mail),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: Get.height * .01,
                ),

                // Password
                SizedBox(
                  height: Get.height * 0.11,
                  child: SizedBox(
                    height: Get.height * 0.1,
                    child: Obx(
                          () => TextFormField(
                        validator: (text) {
                          if (text == null) {
                            return 'Null';
                          }
                          if (text.isEmpty) {
                            return 'Required Field';
                          }
                          if (text.length < 8) {
                            return 'Password Invalid';
                          }
                          return null;
                        },
                        controller: controller.passController.value,
                        obscureText: controller.isObscure.value,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(CupertinoIcons.lock),
                          suffixIcon: GestureDetector(
                              onTap: () {
                                controller.changeObscure();
                              },
                              child: controller.isObscure.value
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility)),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Forget Password
                const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forget Password?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),

                SizedBox(
                  height: Get.height * .03,
                ),

                // Sign in button
                GestureDetector(
                  onTap: () async {
                    if (controller.key.value.currentState!.validate()) {
                      controller.loadingTrue();
                      String email = controller.emailController.value.text.trim();
                      String pass = controller.passController.value.text.trim();
                      await _signInWithEmailAndPassword(email, pass);
                      controller.loadingFalse();
                    }
                  },
                  child: Obx(() => Container(
                    width: Get.width,
                    height: 55,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromRGBO(253, 215, 138, 1)),
                    child: Center(
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.black,)
                            : Text('L O G I N',
                            style: GoogleFonts.poppins(
                                fontSize: Get.height * 0.026,
                                fontWeight: FontWeight.bold))
                    ),
                  )),
                ),
                SizedBox(
                  height: Get.height * 0.04,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),

                    // Navigate to SignUp
                    InkWell(
                        onTap: () {
                          Get.to(const SignupPage(),
                              transition: Transition.cupertino);
                        },
                        child: const Text(
                          '  Register Now',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> isVerified(String email) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      await user.reload();
      user = auth.currentUser;
      return user?.emailVerified ?? false;
    } else {
      return false;
    }
  }

  void showVerificationDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Email Verification Required'),
          content: const Text('Please verify your email to proceed.'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context, false); // Cancel button
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.black),),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VerifyEmailPage(email: email)),
                );
              },
              child: Text('Verify Email', style: TextStyle(color: yellowDark),),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signInWithEmailAndPassword(String email, String pass) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      await auth.signInWithEmailAndPassword(email: email, password: pass);

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      Get.offAll(const BottomNavigation(), transition: Transition.cupertino);
    } on Exception catch (e) {
      controller.loadingFalse();
      Utils().showMessage(context,"'Error ${e.toString()}", Colors.red);
    }
  }
}
