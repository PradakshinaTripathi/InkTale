import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../explore_tales/blogs/blogsPage.dart';

class CreateBlog extends StatefulWidget {
  const CreateBlog({super.key});

  @override
  State<CreateBlog> createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  bool controllerNotNull = false;
  File? _image;
  final _picker = ImagePicker();
  String creatorName = '';
  String creatorProfilePhotoUrl = '';


  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    // Add listeners to the controllers to track changes
    titleController.addListener(updateButtonState);
    bodyController.addListener(updateButtonState);
  }

  @override
  void dispose() {
    titleController.removeListener(updateButtonState);
    bodyController.removeListener(updateButtonState);
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Create Blog')),
          backgroundColor: Colors.black,
        ),
        body: Container(
          margin: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Title'),
                      Expanded(
                        child: TextField(
                          controller: titleController,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Body'),
                      TextField(
                        controller: bodyController,
                        maxLines: 10,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      uploadImage(),
                      const SizedBox(height: 35),
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey[300],
                        child: _image != null
                            ? Image.file(_image!, fit: BoxFit.fill)
                            : const Text('Please select an image'),
                      ),
                      const SizedBox(height: 25),


                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(onPressed: controllerNotNull
                            ? ()async{
                          String imageUrl = await uploadImageToFirebase();
                          print(imageUrl);
                          final User? user = FirebaseAuth.instance.currentUser;
                          CollectionReference collectionReference = FirebaseFirestore.instance.collection('blogData');
                          collectionReference.add({
                            'Title': titleController.text,
                            'Description': bodyController.text,
                            'ImageURL': imageUrl,
                            'CreatorName': creatorName,
                            'CreatorProfilePhoto': creatorProfilePhotoUrl,
                          });
                          print(creatorName);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => BlogPage()),
                          );
                        }:null, child: Text('Post Blog'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black)),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

    
    );
  }

  Widget uploadImage(){
    return  Container(
      width: 150,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black,),
        onPressed: (){
          print('picking image');
          _openImagePicker();
        },
        child: Row(
          children: [
            Icon(Icons.image),
            SizedBox(width: 20,),
            Text('Pick Image'),
          ],
        ),
      ),
    );

  }

  void updateButtonState() {
    setState(() {
      controllerNotNull =
          titleController.text.isNotEmpty && bodyController.text.isNotEmpty;
    });
  }

  Future<void> _openImagePicker() async {
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<String> uploadImageToFirebase() async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
      FirebaseStorage.instance.ref().child('blog_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(_image!);
      await uploadTask.whenComplete(() => null);
      String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // Handle the error as needed
    }
  }
  void fetchUserDetails() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          creatorName = (userDoc.data() as Map<String, dynamic>)['username'] ?? '';
          creatorProfilePhotoUrl = (userDoc.data() as Map<String, dynamic>)['imageUrl'] ?? '';
          setState(() {
          });
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

}
