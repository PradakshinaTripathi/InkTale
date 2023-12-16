import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ink_tale_version1/auth/login_screen.dart';

import 'createBlogPage.dart';

class CreateNew extends StatefulWidget {
  const CreateNew({super.key});

  @override
  State<CreateNew> createState() => _CreateNewState();
}

class _CreateNewState extends State<CreateNew> {

  late Future<User?> _userFuture;

  @override
  void initState() {
    // TODO: implement initState
    _userFuture = FirebaseAuth.instance.authStateChanges().first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
        child: SingleChildScrollView(
            child: Center(
          child: Column(
            children: [
              Text('Start Writing',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),),
              SizedBox(
                height: 50,
              ),
              FutureBuilder<User?>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  User? user = snapshot.data;

                  return GestureDetector(
                    onTap: () {
                      user != null
                          ? Get.to(CreateBlog())
                          : Get.to(LoginPage());
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/explore_images/blog.jpg',
                              ),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: Offset(0, 5),
                                blurRadius: 7,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Blog',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(
                height: 60,
              ),
              // Column(
              //   children: [
              //     Container(
              //       height: 200,
              //       width: 200,
              //       margin: EdgeInsets.all(8),
              //       decoration: BoxDecoration(
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(2),
              //         image: DecorationImage(
              //           image: AssetImage(
              //             'assets/images/explore_images/Author.jpg',
              //           ),
              //           fit: BoxFit.cover,
              //         ),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.grey.withOpacity(0.5),
              //             offset: Offset(0, 5),
              //             blurRadius: 7,
              //             spreadRadius: 2,
              //           ),
              //         ],
              //       ),
              //     ),
              //     Text(
              //       'Author',
              //       style: TextStyle(
              //         color: Colors.black,
              //         fontWeight: FontWeight.bold,
              //         fontSize: 20,
              //       ),
              //     ),
              //   ],
              // )
            ],
          ),
            ),
        ),
      ),

    );
  }

}
