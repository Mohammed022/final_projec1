import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Admin Page Example',
      home: AdminPage(),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Admin Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchUserDataFromFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No users found.');
            } else {
              return _buildList('Users', snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildList(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'List of $title:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];
            return ListTile(
              title: Text(item['name']),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDeleteConfirmationDialog(context, item['id']);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> fetchUserDataFromFirebase() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name']})
        .toList();
  }

  Future<void> deleteUser(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    print('User $userId deleted!');
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context,
      String userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف المستخدم'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('هل أنت متأكد من أنك تريد حذف هذا المستخدم؟'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('تراجع'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حذف'),
              onPressed: () {
                deleteUser(userId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}