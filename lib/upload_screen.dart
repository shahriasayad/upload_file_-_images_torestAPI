import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;

  Future<void> _pickAndUpload() async {
    final file = await pickImage();
    if (file != null) {
      setState(() => _image = file);
      await uploadImage(file);
    }
  }

  Future<void> uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://fakestoreapi.com/products'),
    );

    // Add headers if needed (e.g., auth token)
    request.headers.addAll({"Authorization": "Bearer YOUR_TOKEN_HERE"});

    // Add file
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // <-- field name expected by API
        imageFile.path,
      ),
    );

    // Send
    var response = await request.send();

    if (response.statusCode == 200) {
      print("✅ Upload success!");
      var respStr = await response.stream.bytesToString();
      print(respStr);
    } else {
      print("❌ Upload failed: ${response.statusCode}");
    }
  }

  final picker = ImagePicker();

  Future<File?> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Image")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!, height: 150)
                : Icon(Icons.image, size: 100),
            ElevatedButton(
              onPressed: _pickAndUpload,
              child: Text("Pick & Upload"),
            ),
          ],
        ),
      ),
    );
  }
}
