import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Librería',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: UploadImageScreen(),
    );
  }
}

class UploadImageScreen extends StatefulWidget {
  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  File? _image;

  Future<void> _chooseImage() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage!.path);
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      return;
    }

    final url = Uri.parse('http://192.168.100.12/image_upload_php_mysql/upload.php');
    final request = http.MultipartRequest('POST', url);
    request.fields['titulo'] = _titleController.text;
    request.fields['autor'] = _authorController.text;
    request.files.add(await http.MultipartFile.fromPath('imagen', _image!.path));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData['message']); // Imprime el mensaje del servidor
      // Aquí puedes procesar la respuesta del servidor, por ejemplo, mostrar un mensaje al usuario
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Libreria'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: 'Autor'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _chooseImage,
              child: Text('Seleccionar imagen'),
            ),
            SizedBox(height: 16.0),
            _image != null
                ? Image.file(
              _image!,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            )
                : Container(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Subir imagen'),
            ),
          ],
        ),
      ),
    );
  }
}
