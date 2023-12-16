import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ink_tale_version1/auth/login_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
            padding: const EdgeInsets.only(top: 150),
            child: Column(
              children: [

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('SignUp',style: TextStyle(color: Colors.black,fontSize: 30,fontWeight: FontWeight.bold),),
                ),
                const SizedBox(
                  height: 30,
                ),
                 SizedBox(
                  height: 50,
                  width: 300,
                  child: TextField(
                    controller: userNameController,
                      decoration: InputDecoration(
                          hintText: 'User Name',
                          hintStyle: TextStyle(fontSize: 20.0, color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: Colors.black),
                          )
                      )
                  ),
                ),
                SizedBox(
                  height: 30,
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
                SizedBox(
                  height: 30,
                ),
                 SizedBox(
                  height: 50,
                  width: 300,
                  child: TextField(
                    controller: passwordController,
                      decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(fontSize: 20.0, color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: Colors.black),
                          )
                      )
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                SizedBox(
                    width: 200,
                    child: ElevatedButton(onPressed: ()async{
                      try{
                        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                        );
                        await userCredential.user?.updateDisplayName(userNameController.text);
                        await _firestore.collection('user').doc(userCredential.user?.uid).set({
                          'username': userNameController.text,
                          'email': emailController.text,
                          'password': passwordController.text,
                        });
                        Get.to(LoginPage());
                        }
                      catch(e){
                        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
                          Get.snackbar(
                            'Error',
                            'The email address is already in use. Please log in or use a different email.',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                        else{
                          Get.snackbar(
                            'Error',
                            'Their was some error signing in.. Please try again later',
                            backgroundColor: Colors.black,
                            colorText: Colors.white,
                          );
                        }

                      }

                    },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black,foregroundColor: Colors.white), child: const Text('SignUp'),
                    )),
                SizedBox(height: 30,),
                Text('Already have an account?'),
                SizedBox(height: 10,),
                GestureDetector(
                    onTap: (){
                      Get.off(LoginPage());
                    },
                    child: Text('Login'))

              ],
            ),
          ),
        ),
      ),
    );
  }
}
