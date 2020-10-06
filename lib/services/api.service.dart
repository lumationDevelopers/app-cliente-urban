import 'dart:convert';
import 'package:client/credentials.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class Api extends http.BaseClient {
  http.Client _http = new http.Client();

  final baseUrl = apiUrl + 'api/v1/';

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + (storage.getString('user_token') ?? '')
    });
    return _http.send(request);
  }

  @override
  Future<http.Response> get(url, {Map<String, String> headers}) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + (storage.getString('user_token') ?? '')
    };

    return  await _http.get(url, headers: headers);
  }

  @override
  Future<http.Response> post(url, {headers, body, Encoding encoding}) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + (storage.getString('user_token') ?? '')
    };
    return _http.post(url, body: body, headers: headers, encoding: encoding);
  }

  @override
  Future<http.Response> put(url,{Map<String, String> headers, body, Encoding encoding}) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + (storage.getString('user_token') ?? '')
    };
    return _http.put(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<http.Response> delete(url, {Map<String, String> headers}) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + (storage.getString('user_token') ?? '')
    };
    return _http.delete(url, headers: headers);
  }

  ////SERVICES

  Future<http.Response> getByPath(BuildContext context, String path, {String filters: '' }) async {
    final response = await get('$baseUrl$path');

    if (response.statusCode == 401) {
      print('401');
      Navigator.of(context).pushReplacementNamed('/login');
      return response;
    }

    return response;
  }

  Future<http.Response> postByPath(BuildContext context, String path, dynamic data) async {
    final response = await post('$baseUrl$path', body: jsonEncode(data));

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed('/login');
      return response;
    }

    return response;
  }

  Future<http.Response> putByPath(BuildContext context, String path, dynamic data) async {
    final response = await put('$baseUrl$path', body: jsonEncode(data));

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed('/login');
      return response;
    }

    return response;
  }

  Future<http.Response> deleteByPath(BuildContext context, String path) async {
    final response = await delete('$baseUrl$path');

    if (response.statusCode == 401) {
      Navigator.of(context).pushReplacementNamed('/login');
      return response;
    }

    return response;
  }

  Future<http.StreamedResponse> uploadFile(File imageFile, String path, String fieldName, { String method = 'POST' }) async {
    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse('$baseUrl$path');

    print(uri.toString());

    var request = new http.MultipartRequest(method, uri);
    var multipartFile = new http.MultipartFile(fieldName, stream, length, filename: basename(imageFile.path), contentType: MediaType('image', 'png'));

    request.files.add(multipartFile);
    SharedPreferences storage = await SharedPreferences.getInstance();
    request.headers.addAll({ 'Accept': 'application/json', 'Authorization': 'Bearer ' + (storage.getString('user_token') ?? '') });

    return await request.send();

    //return response.stream.transform(utf8.decoder).toString();
  }
}