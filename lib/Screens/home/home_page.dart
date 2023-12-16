
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink_tale_version1/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/change_password.dart';
import '../../controller/booksController.dart';
import '../../models/explore_items.dart';
import '../author/authorScreen.dart';
import '../explore_tales/blogs/blogDescription.dart';
import '../explore_tales/blogs/blogsPage.dart';
import '../explore_tales/books/booksPage.dart';
import '../profile/my_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.user,});
  final User? user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoggedIn = false;
  String phoneNumber = '';
  String displayName = '';
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    isLoggedIn = widget.user != null;
    checkLoginStatus();
  }

  final List<ExploreItem> exploreItems = [
    ExploreItem(
      imagePath: 'assets/images/explore_images/Books.jpg',
      name: 'Books',
    ),
    ExploreItem(
      imagePath: 'assets/images/explore_images/blog.jpg',
      name: 'Blogs',
    ),
    ExploreItem(
      imagePath: 'assets/images/explore_images/Author.jpg',
      name: 'Author',
    ),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: Colors.white,
        leading: Visibility(
            visible:false,
            child: const Icon(Icons.more_horiz, size: 32,color: Colors.black,)),
        title: Center(
            child: Row(
              children: [
                const SizedBox(width: 40,),
                Image.asset('assets/images/logo_1.jpg',height: 150,width: 150,),
              ],
            )),
        actions: [
          GestureDetector(
            onTap: (){
              _scaffoldKey.currentState?.openEndDrawer();
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                Icons.person_2_rounded,
                size: 32,
                color: Colors.black,
              ),
            ),
          ),
        ],
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30,),
            searchBar(),
            const SizedBox(height: 15,),
            explore(),
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Top Blogs',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600)),
                  GestureDetector(
                      onTap: (){
                        Get.to(BlogPage());
                      },
                      child: Icon(Icons.arrow_forward_ios,size: 20,))
                ],
              ),
            ),
            const SizedBox(height: 10,),
            topBlogs(),
            const SizedBox(height: 20,),

            // categories()

          ],
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
        DrawerHeader(
        decoration: const BoxDecoration(
        color: Colors.black,
        ),
        child: UserAccountsDrawerHeader(
          decoration: const BoxDecoration(color: Colors.black),
          accountName: !isLoggedIn?const Text('Hello, User',style: TextStyle(fontSize: 18)):
          Text(widget.user?.displayName ?? ''),
          accountEmail: Visibility(
              visible: isLoggedIn,
              child: Text(widget.user?.email ?? ''),),
          currentAccountPictureSize: const Size.square(50),
            currentAccountPicture: imageUrl != null && imageUrl.isNotEmpty && isLoggedIn
                ? CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 48.0,
                  child: ClipOval(
                    child: SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: Image.network(
              imageUrl,
              fit: BoxFit.fill,
            ),
                    ),
                  ),
                )
                : CircleAvatar(
              backgroundColor: Colors.white,
              child: isLoggedIn
                  ? Text(
                widget.user?.displayName?[0].toUpperCase() ?? '',
                style: TextStyle(fontSize: 30.0, color: Colors.black),
              )
                  : const Icon(Icons.person, color: Colors.black, size: 35),
            ),
        ),
      ),
            Visibility(
              visible: isLoggedIn,
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text(' My Profile '),
                onTap: () {
                  Get.to(ProfileEditPage(user: widget.user,));
                },
              ),
            ),
            Visibility(
              visible: isLoggedIn,
              child: ListTile(
                leading: const Icon(Icons.password_sharp),
                title: const Text(' Change Password '),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                  );
                },
              ),
            ),

            Visibility(
              visible: !isLoggedIn,
              child: ListTile(
                leading: const Icon(Icons.login),
                title: const Text('LogIn'),
                onTap: () async{
                  bool isLoginSuccess = await Get.to(LoginPage()) ?? false;
                  if (isLoginSuccess) {
                    User? user = (Get.arguments as Map<String, dynamic>)['user'];
                    setState(() {
                      isLoggedIn = true;
                    });
                  }
                },
              ),
            ),
            Visibility(
              visible: isLoggedIn,
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('LogOut'),
                onTap: () async{
                  await FirebaseAuth.instance.signOut();
                  // await Get.put(BooksController()).clearFavorites();
                  setState(() {
                    isLoggedIn = false;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
      ]
            ),
      )

    );



  }
  Widget searchBar(){
    return
      Center(
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
        child: const TextField(
          decoration: InputDecoration(
            icon: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(Icons.search),
            ),
            hintText: 'Find Stories, blogs, books..',

          ),
        ),
      ),
    );
  }


  Widget explore(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20,right: 20),
          child:
              Text('Explore',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600)),
          ),
        const SizedBox(height: 5,),
        SizedBox(
          height: 200,
          child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context,index){
                ExploreItem item = exploreItems[index];
                return  Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child:
                  Column(
                    children:[
                      GestureDetector(
                        onTap: () {
                          // Navigate to BooksPage when the book is tapped
                          if (item.name == 'Books') {
                            Get.to(() => BooksPage());
                          }
                          if (item.name == 'Blogs') {
                            Get.to(() =>  BlogPage());
                          }
                          if (item.name == 'Author'){
                            Get.to(() =>  AuthorScreen());
                          }
                          },
                        child: Container(
                        height: 140,
                        width: 130,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            image: DecorationImage(
                              image: AssetImage(item.imagePath),
                              fit: BoxFit.cover
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  offset: const Offset(0,5),
                                  blurRadius: 7,
                                  spreadRadius: 2
                              )
                            ]
                        ),
                    ),
                      ),
                      Text(item.name,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
                  ]
                  ),


                );

              }),
        ),
      ],
    );
  }


  Widget topBlogs() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 300, // Adjust the height as needed
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('blogData').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // Access the last document in the QuerySnapshot
            final lastDocument = snapshot.data!.docs.last;

            return Stack(
              children: [
                buildImageBackground(lastDocument['ImageURL']), // Use a function to build the image background
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 300,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), // Adjust the corner radius as needed
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7), // Adjust the opacity as needed
                        ],
                      ),
                    ),
                    child: GestureDetector(
                      onTap: (){
                        Get.to(BlogDescription(title: lastDocument['Title'], description: lastDocument['Description'], imageUrl: lastDocument['ImageURL'], creatorName: lastDocument['CreatorName'], creatorProfilePhoto: lastDocument['CreatorProfilePhoto']));
                      },
                      child: ListTile(
                        title: Center(
                          child: Text(
                            lastDocument['Title'],
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ),


                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 3,
                  right: 8,
                  child: Text(
                    lastDocument['CreatorName'] != null ? "- ${lastDocument['CreatorName']}" : 'Anonymous',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

// Function to build the image background
  Widget buildImageBackground(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Adjust the corner radius to match the ListTile
        image: DecorationImage(
          image: NetworkImage(imageUrl), // Assuming the image URL is from a network source
          fit: BoxFit.cover, // Make the image cover the entire container
        ),
      ),
    );
  }




  Widget buildImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: 100,
        width: 50,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/images/explore_images/blog.jpg',
        height: 100,
        width: 50,
        fit: BoxFit.cover,
      );
    }
  }

  Widget categories(){
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20,right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600)),
              Text('View All')
            ],
          ),
        ),
        const SizedBox(height: 5,),
        SizedBox(
            height: 200,
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context,index){
                  return  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child:
                    Container(
                      height: 150,
                      width: 120,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: const Offset(0,5),
                                blurRadius: 7,
                                spreadRadius: 2
                            )
                          ]
                      ),
                    ),


                  );

                }),
          ),
      ],
    );
  }

  Future<void> fetchUserData() async {
    // Check if the user is logged in
    if (isLoggedIn) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(widget.user?.uid)
            .get();

        if (userDoc.exists) {
          // Fetch all the information from Firestore
          // Update the state or perform actions as needed
          phoneNumber = (userDoc.data() as Map<String, dynamic>)['phoneNumber'];
          displayName = (userDoc.data() as Map<String, dynamic>)['username'];
          imageUrl = (userDoc.data() as Map<String, dynamic>)['imageUrl'];
          setState(() {

          });

          print(phoneNumber);
          print(imageUrl);

          // Now you can use phoneNumber, displayName, and imageUrl as needed
          // You might want to update the state or use these values in your UI
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }


  Future<void> checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User is not logged in
      setState(() {
        isLoggedIn = false;
      });
    } else {
      // User is logged in, fetch user data
      await fetchUserData();
      setState(() {
        isLoggedIn = true;
      });
    }

    // Now navigate based on the login status
    // navigateToScreen();
  }

}
