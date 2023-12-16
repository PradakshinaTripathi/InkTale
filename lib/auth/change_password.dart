import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        centerTitle: true,
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: showPassword?false:true,
              decoration:  InputDecoration(labelText: 'Old Password',
                  suffixIcon: GestureDetector(
                      onTap: (){
                        setState(() {
                          showPassword = !showPassword;
                        });                      },
                      child: Icon(Icons.remove_red_eye_rounded))
              ),
            ),
            SizedBox(height: 30,),
            TextField(
              controller: _newPasswordController,
              obscureText: showPassword?false:true,
              decoration:  InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: GestureDetector(
                      onTap: (){
                        setState(() {
                          showPassword = !showPassword;
                        });                      },
                      child: Icon(Icons.remove_red_eye_rounded))
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _changePassword();
              },
              child: const Text('Change Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changePassword() async {
    try {
      // Ensure the user is authenticated
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _oldPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password changed successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
        // Password changed successfully
        // You may want to show a success message or navigate back to the home screen

      }
    } catch (error) {
      // Handle password change error
      // You may want to show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error changing password'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Error changing password: $error');
    }
  }


}
