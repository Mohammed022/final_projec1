import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late User _user; // Firebase User object
  late String _userName;
  late String _userEmail;
  late String _userPhone;
  late String _userRegion;
  late String _userAvatar;
  late String _userSocial;
  late String _userDescription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // تحميل الصورة إلى Firebase Storage
      String fileName = path.basename(image.path);
      Reference storageRef = FirebaseStorage.instance.ref().child('avatar/$fileName');
      UploadTask uploadTask = storageRef.putFile(File(image.path));

      try {
        await uploadTask;
        final String imageUrl = await storageRef.getDownloadURL();

        // تحديث البيانات في Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user.uid)
            .update({'avatar': imageUrl});

        setState(() {
          _userAvatar = imageUrl;
        });
      } catch (e) {
        print('Error uploading image: $e');
        // Handle the error, e.g., display an error message to the user
      }
    }
  }

  Future<void> _initializeUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is signed in
      setState(() {
        _user = user;
      });
      await _fetchUserData();
    } else {
      // Handle user not signed in
      // Redirect to login or handle accordingly
    }
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _userName = userData['name'];
          _userEmail = userData['email'];
          _userPhone = userData['phone'];
          _userRegion = userData['region'];
          _userAvatar = userData['avatar'];
          _userSocial = userData['social'];
          _userDescription = userData['description'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Handle the error, e.g., display an error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showEditDialog(String fieldName, String initialValue,
      Function(String) onEdit) async {
    String? newValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller =
        TextEditingController(text: initialValue);

        return AlertDialog(
          title: Text('Edit $fieldName'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'New $fieldName'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _showConfirmationDialog(fieldName, controller.text, onEdit);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmationDialog(String field, String value,
      Function(String) onEdit) async {
    bool confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Edit'),
          content: Text('Are you sure you want to update $field?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ??
        false;

    if (confirmed) {
      onEdit(value);
      await _updateUserData(field, value);
    }
  }

  Future<void> _updateUserData(String field, String value) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .update({field: value});

      setState(() {
        switch (field) {
          case 'name':
            _userName = value;
            break;
          case 'email':
            _userEmail = value;
            break;
          case 'phone':
            _userPhone = value;
            break;
          case 'region':
            _userRegion = value;
            break;
          case 'avatar':
            _userAvatar = value;
            break;
          case 'social':
            _userSocial = value;
            break;
          case 'description':
            _userDescription = value;
            break;
        }
      });
    } catch (e) {
      print('Error updating user data: $e');
      // Handle the error, e.g., display an error message to the user
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Account Page',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
            fontSize: 30,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users')
              .doc(_user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text("No user data available"));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            _userName = userData['name'];
            _userEmail = userData['email'];
            _userPhone = userData['phone'];
            _userRegion = userData['region'];
            _userAvatar = userData['avatar'];
            _userDescription = userData['description'];
            _userSocial = userData['social'];

            return Column(
              children: [
                // Display Avatar
                ListTile(
                  title: const Text('Avatar'),
                  subtitle: Text(_userAvatar),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _pickImage();

                    },
                    child: const Text('Edit'),
                  ),
                ),
                const Divider(),

                // Display Name
                ListTile(
                  title: const Text('Name'),
                  subtitle: Text(_userName),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _showEditDialog('name', _userName, (value) {
                        setState(() {
                          _userName = value;
                        });
                      });
                    },
                    child: const Text('Edit'),
                  ),
                ),
                const Divider(),

                // Display Name
                ListTile(
                  title: const Text('Email'),
                  subtitle: Text(_userEmail),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _showEditDialog('email', _userEmail, (value) {
                        setState(() {
                          _userEmail = value;
                        });
                      });
                    },
                    child: const Text('Edit'),
                  ),
                ),
                const Divider(),

                // Display Phone
                ListTile(
                  title: const Text('Phone'),
                  subtitle: Text(_userPhone),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _showEditDialog('phone', _userPhone, (value) {
                        setState(() {
                          _userPhone = value;
                        });
                      });
                    },
                    child: const Text('Edit'),
                  ),
                ),
                const Divider(),

                // Display Region
                ListTile(
                  title: const Text('Region'),
                  subtitle: Text(_userRegion),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _showEditDialog('region', _userRegion, (value) {
                        setState(() {
                          _userRegion = value;
                        });
                      });
                    },
                    child: const Text('Edit'),
                  ),
                ),
                const Divider(),

                ListTile(
                  title: const Text('Social'),
                  subtitle: Text(_userSocial),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _showEditDialog('social', _userSocial, (value) {
                        setState(() {
                          _userSocial = value;
                        });
                      });
                    },
                    child: const Text('Edit'),
                  ),
                ),
                const Divider(),

                ListTile(
                  title: const Text('Description'),
                  subtitle: Text(_userDescription),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _showEditDialog('description', _userDescription, (value) {
                        setState(() {
                          _userDescription = value;
                        });
                      });
                    },
                    child: const Text('Edit'),
                  ),
                ),
                // ... (other ListTile widgets with userData fields)
                // Each ListTile can be similar to what you had before, but using userData fields.
              ],
            );
          },
        ),
      ),
    );
  }
}

