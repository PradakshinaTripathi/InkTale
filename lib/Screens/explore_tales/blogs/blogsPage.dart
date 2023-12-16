import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ink_tale_version1/auth/login_screen.dart';

import 'blogDescription.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});


  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Blogs'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogData').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index){
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 80,
                    margin: EdgeInsets.all(8), // Add some margin
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          offset:
                          Offset(0, 1), // Adjust the offset for the shadow
                          blurRadius:
                          2, // Adjust the blur radius for the shadow
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: ()async{
                        if (FirebaseAuth.instance.currentUser != null){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlogDescription(
                              title: snapshot.data!.docs[index]['Title'],
                              description: snapshot.data!.docs[index]['Description'],
                              imageUrl: snapshot.data!.docs[index]['ImageURL'],
                              creatorName: snapshot.data!.docs[index]['CreatorName'],
                                creatorProfilePhoto : snapshot.data!.docs[index]['CreatorProfilePhoto']

                            ),
                          ),
                        );  }else{
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        }

                        },
                      child: Stack(
                        children:[
                          ListTile(
                          title: Text(snapshot.data!.docs[index]['Title'],
                            style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Text('${snapshot.data!.docs[index]['Description']}',
                            style: TextStyle(
                            fontWeight: FontWeight.w300,
                          ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          leading: buildImage(snapshot.data!.docs[index]['ImageURL']),
                            trailing: SizedBox.shrink(),
                        ),
                    Positioned(
                        bottom: 3,
                        right: 8,
                        child: Text(
                          snapshot.data!.docs[index]['CreatorName'] != null
                              ? "- ${snapshot.data!.docs[index]['CreatorName']}"
                              : 'Anonymous',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w200,
                          ),
                        ),)
                        ]
                      ),
                    ),
                  ),
                );
              }


          );
        },
        
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
}
