import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:room_finder/screens/add_new_room/components/price_text_field.dart';
import 'package:uuid/uuid.dart';

import '../login_screen/components/my_button.dart';
import '../login_screen/components/my_textfield.dart';
import '../login_screen/components/square_tile.dart';
import '../login_screen/google_auth.dart';

class RegisterScreen extends StatefulWidget {
  final Function()? onTap;

  RegisterScreen({Key? key, required this.onTap}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  String userRole = 'user';


  late BuildContext loadingContext;

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        loadingContext = context; // store the context of the loading dialog
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void hideLoadingDialog() {
    Navigator.pop(loadingContext); // use the stored context to remove the loading dialog
  }


  void registerUser() async {

    //String userId = Uuid().v4();

    if(nameController.text.isEmpty || emailController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name or Email can\'t be empty'),duration:Duration(seconds: 2) ,),
      );
    }else if(phoneController.text.length != 10){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter Valid Phone No.'),duration:Duration(seconds: 2) ,),
      );
    }else if(passwordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a Valid Password'),duration:Duration(seconds: 2) ,),
      );
    }
    else{

      if (passwordController.text == confirmPasswordController.text) {
        try {
          showLoadingDialog(context);
          final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          hideLoadingDialog();

          addUserToFirestore(credential.user!.uid, nameController.text, emailController.text,phoneController.text);

        } on FirebaseAuthException catch (e) {
          hideLoadingDialog();
          if (e.code == 'weak-password') {
            showErrorMessage('The password provided is too weak.');
          } else if (e.code == 'email-already-in-use') {
            showErrorMessage('The account already exists for that email.');
          }
        } catch (e) {
          hideLoadingDialog();
          showErrorMessage(e.toString());
        }
      } else {
        //show error message
        showErrorMessage('Passwords don\'t match');
      }
    }

  }

  void addUserToFirestore(String userId, String name, String email,String phone) async {
    // Get a reference to the Firestore collection that will store the users
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

    // Create a new document in the users collection with the specified ID
    DocumentReference userDocument = usersCollection.doc(userId);

    // Add the user details as fields to the document
    await userDocument.set({
      'name': name,
      'email': email,
      'phone': phone,
      'favoriteRooms': [],
      'profile_picture': '',
      'about':'About text',
      'userId':userId,
      'pushToken' : 'Push Added',
      'chatIds':[],
      'role':userRole,
    });
  }


  void showErrorMessage(String mess) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(mess),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(height: 25),
                Text(
                  'Let\'s create an account for You!',
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: nameController,
                  hintText: 'Enter Full Name',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: emailController,
                  hintText: 'Enter Email',
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                PriceTextField(isPrice: false, myController: phoneController, hintText: 'Enter Phone No.'),
                const SizedBox(height: 10,),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Enter Password',
                  obscureText: true,
                ),
                SizedBox(
                  height: 10,
                ),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  child: DropdownButtonFormField<String>(
                    value: userRole,
                    onChanged: (value) {
                      setState(() {
                        userRole = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Role',
                      focusColor: Colors.black26,
                      labelStyle: TextStyle(fontSize: 20,color: Colors.black87),
                      hintText: 'Choose your role',
                      border: InputBorder.none,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'owner',
                        child: Text('PG Owner',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.deepOrange),),
                      ),
                      DropdownMenuItem(
                        value: 'user',
                        child: Text('PG Seeker',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.green.shade600),),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),

                MyButton(
                  buttonText: 'Register',
                  onTap: registerUser,
                ),
                const SizedBox(
                  height: 20,
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                //   child: Row(
                //     //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Expanded(
                //         child: Divider(
                //           thickness: 0.5,
                //           color: Colors.grey.shade400,
                //         ),
                //       ),
                //       Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
                //         child: Text(
                //           'Or continue with',
                //           style: TextStyle(color: Colors.grey.shade600),
                //         ),
                //       ),
                //       Expanded(
                //         child: Divider(
                //           thickness: 0.5,
                //           color: Colors.grey.shade400,
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                // const SizedBox(
                //   height: 25,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     SquareTile(
                //         onTap: () => GoogleAuth().signInWithGoogle(),
                //         imagePath: 'assets/images/google.png'),
                //     const SizedBox(
                //       width: 25,
                //     ),
                //     SquareTile(
                //         onTap: () {}, imagePath: 'assets/images/apple.png'),
                //   ],
                // ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Login Now',
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
