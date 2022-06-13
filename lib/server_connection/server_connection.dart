import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

detect(File image) async {
  String url = 'http://192.168.20.166:8000/upload';

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(url),
  );
  Map<String, String> header = {"Content-type": "multipart/form-data"};
  request.files.add(
    http.MultipartFile(
      'image',
      image.readAsBytes().asStream(),
      image.lengthSync(),
      filename: image.path.split('/').last,
      contentType: MediaType('image', 'jpg'),
    ),
  );
  request.headers.addAll(header);
  print(request);
  final response = await request.send();
  http.Response res = await http.Response.fromStream(response);
  print(res.body);
  return res.body;

  //http.Response response = await http.get(Uri.parse(url));
  //return response.body;
}

Image fileFromBase64String(String base64String) {
  Image img = Image.memory(base64Decode(base64String));

  return img;
}

Future<String> fetchHistory() async {
  String url = 'http://192.168.20.166:8000/history';
  http.Response response = await http.get(Uri.parse(url));
  return response.body;
}

Future<String> delete(String filename) async {
  String url = 'http://192.168.20.166:8000/delete?filename=$filename';
  print(url);
  http.Response response = await http.get(Uri.parse(url));
  return response.body;
}