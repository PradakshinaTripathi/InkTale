import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ink_tale_version1/auth/sign_up.dart';
import 'package:ink_tale_version1/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  FirebaseAuth _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 250,
        title: const Padding(
          padding: EdgeInsets.only(right: 45),
          child: Image(image: AssetImage('assets/images/logo_1-removebg.png')),
        ),
      ),

      body:  Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 200),
            child: Column(
              children: [

                const Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Welcome, Back',style: TextStyle(color: Colors.grey,fontSize: 30,fontWeight: FontWeight.bold),),
                    )),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),

                     SizedBox(
                      height: 50,
                      width: 300,
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                            hintStyle: TextStyle(fontSize: 20.0, color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: Colors.black),
                          )
                        )
                      ),
                    ),
                    const SizedBox(height: 30,),
                     SizedBox(
                      height: 50,
                      width: 300,
                      child: TextField(
                          obscureText: showPassword?false:true,
                        controller: passwordController,
                          decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(fontSize: 20.0, color: Colors.black),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: Colors.black),
                              ),
                              suffixIcon: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      showPassword = !showPassword;
                                    });                      },
                                  child: Icon(Icons.remove_red_eye_rounded))
                          )
                      ),
                    ),
                    const SizedBox(height: 30,),
                    SizedBox(
                        width: 200,
                        child: ElevatedButton(onPressed: ()async{
                          try {
                            UserCredential userCredential =
                                await _auth.signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                            User? user = userCredential.user;
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setBool('isLoggedIn', true);
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Navigation(user: user,)),
                            );
                          } catch (e) {
                            if (e is FirebaseAuthException && (e.code == "invalid-credential"||e.code == "wrong-password")) {
                              Get.snackbar(
                                'Error',
                                'Please check your email or password',
                                backgroundColor: Colors.black,
                                colorText: Colors.white,
                              );
                              print("Login failed: $e");
                            }

                            else{
                              Get.snackbar(
                                'Error',
                                'Login Failed',
                                backgroundColor: Colors.black,
                                colorText: Colors.white,
                              );
                              print("Login failed: $e");
                            }

                            }

                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black,foregroundColor: Colors.white), child: const Text('Login'),
                        )),
                    const SizedBox(height: 30,),

                  ],
                ),
                SizedBox(height: 30,),
                Text('New Here? Need an account?'),
                SizedBox(height: 10,),
                GestureDetector(
                    onTap: (){
                      Get.off(SignUp());
                    },
                    child: Text('SignUp'))
              ],
            ),
          ),
        ),
      ),

    );
  }


}
