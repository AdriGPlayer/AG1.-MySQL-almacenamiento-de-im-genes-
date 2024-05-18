import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/book.dart';

class ApiService {
  final String baseUrl = 'http://192.168.100.12/image_upload_php_mysql';

  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/get_books.php'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((book) => Book.fromJson(book)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<void> addBook(String titulo, String autor, File image) async {
    final url = Uri.parse('$baseUrl/upload.php');
    var request = http.MultipartRequest('POST', url);
    request.fields['titulo'] = titulo;
    request.fields['autor'] = autor;
    request.files.add(await http.MultipartFile.fromPath('imagen', image.path));

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to upload book');
    }
  }
}
