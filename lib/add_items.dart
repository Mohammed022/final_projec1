import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Add Items Page Example',
      home: AddItemsPage(),
    );
  }
}

class AddItemsPage extends StatefulWidget {
  const AddItemsPage({Key? key}) : super(key: key);

  @override
  State<AddItemsPage> createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  XFile? _image;

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    super.dispose();
  }

  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      imageController.text = _image?.path ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Add Items',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: 30,
                  ),
                ),
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Item Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Item Price',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item price';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Item Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _getImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 10),
              // Display the picked image if available
              if (_image != null)
                Image.file(
                  File(_image!.path),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text('Add Item'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print('Item Name: ${nameController.text}');
                    print('Item Price: ${priceController.text}');
                    print('Item Description: ${descriptionController.text}');
                    print('Item Image: ${imageController.text}');
                    // You can also add the item to a list or a database here
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
