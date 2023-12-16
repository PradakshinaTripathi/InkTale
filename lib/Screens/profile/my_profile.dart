import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ProfileEditPage extends StatefulWidget {
  final User? user;

  const ProfileEditPage({Key? key, this.user}) : super(key: key);

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  File? _image;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.displayName);
    _phoneController = TextEditingController(text: '');
    _emailController = TextEditingController(text: widget.user?.email);
    _image = null;
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        centerTitle: true,
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 50,),
              CircleAvatar(
                backgroundColor: Colors.black,
                radius: 60.0,
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 58.0,
                  child: ClipOval(
                    child: SizedBox(
                      width: 120.0,
                      height: 120.0,
                      child: ((widget.user?.photoURL) != null) ?
                      Image.network(
                        widget.user!.photoURL!,
                        fit: BoxFit.fill,
                      ) : (_image != null && _image is File)
                          ? Image.file(
                        _image!,
                        fit: BoxFit.fill,
                      )
                          : (_image != null)
                          ? Image.file(
                        _image!,
                        fit: BoxFit.fill,
                      )
                          : Center(
                        child: Text(
                          widget.user?.displayName?[0].toUpperCase() ?? '',
                          style: TextStyle(fontSize: 20.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10,),
              GestureDetector(
                onTap: () {
                  print('picking image');
                  _openImagePicker();
                },
                child: Text(
                  'Change Photo',
                  style: TextStyle(color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 60,),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name', style: TextStyle(color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600)),
                    SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Phone No', style: TextStyle(color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600)),
                    SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        hintText: 'Enter your phone number',
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Email', style: TextStyle(color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600)),
                    SizedBox(
                      height: 8,
                    ),
                    TextField(
                      readOnly: true,
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email Address',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      _saveChanges();
                    },
                    child: Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openImagePicker() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
          source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _image = null; // Set to null before assigning a new local image
          _image = File(pickedImage.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      // Handle the error as needed (e.g., show an error message)
    }
  }

  Future<String> uploadImageToFirebase() async {
    try {
      if (_image == null) {
        throw Exception("Image not selected");
      }
      String fileName = '${widget.user?.uid}_${DateTime
          .now()
          .millisecondsSinceEpoch
          .toString()}';
      Reference storageReference =
      FirebaseStorage.instance.ref().child('user_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(_image!);
      await uploadTask.whenComplete(() => null);
      String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // Handle the error as needed
    }
  }

  void _saveChanges() async {
    try {
      String newName = _nameController.text.trim();
      String newPhone = _phoneController.text.trim();

      print('UID: ${widget.user?.uid}');

      // Log values for debugging
      print('New Name: $newName');
      print('New Phone: $newPhone');


      // Update user name in Firebase Authentication
      await widget.user?.updateDisplayName(newName);

      // Ensure the document with the UID exists before updating
      bool documentExists = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.user?.uid)
          .get()
          .then((doc) => doc.exists);

      if (documentExists) {
        String imageUrl = await uploadImageToFirebase();
        // Update user data in Firestore
        await FirebaseFirestore.instance.collection('user').doc(
            widget.user?.uid).set({
          'phoneNumber': newPhone,
          'username': newName,
          'imageUrl': imageUrl,
        }, SetOptions(merge: true));

        // Update text controllers with the new values
        setState(() {
          _nameController.text = newName;
          _phoneController.text = newPhone;
        });

        Navigator.pop(context, {
          'name': newName,
          'phone': newPhone,
          'imageUrl': imageUrl,
        });
      } else {
        print('Document does not exist for UID: ${widget.user?.uid}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not found')));
      }
    } catch (e) {
      // Handle errors, and log or show a relevant message
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')));
    }
  }

  void _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.user?.uid)
          .get();

      if (userDoc.exists) {
        String phoneNumber = (userDoc.data() as Map<String,
            dynamic>)['phoneNumber'];
        setState(() {
          _phoneController.text = phoneNumber ?? '';
        });

        String displayName = (userDoc.data() as Map<String,
            dynamic>)['username'];
        setState(() {
          _nameController.text = displayName ?? '';
        });

        String imageUrl = (userDoc.data() as Map<String, dynamic>)['imageUrl'];
        if (imageUrl != null && imageUrl.isNotEmpty) {
          // Download the image and set the state
          await _downloadImage(imageUrl);
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = '${widget.user?.uid}_profile_image.jpg';
      final File imageFile = File('${appDir.path}/$fileName');
      await imageFile.writeAsBytes(response.bodyBytes);

      setState(() {
        _image = imageFile;
      });
    } catch (e) {
      print('Error downloading image: $e');
    }
  }
}