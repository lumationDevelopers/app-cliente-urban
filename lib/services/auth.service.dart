import 'dart:convert';
import 'package:client/credentials.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class Auth extends http.BaseClient {
  http.Client _http = new http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // TODO: implement send
    throw UnimplementedError();
  }

  final baseUrl = apiUrl;

  ////SERVICES
  Future<http.Response> login(data) async {
    return _http.post('${baseUrl}oauth/token', body: data, headers: {
      "Authorization": "Basic YXBwTW92aWw6WWIzN2NwYzdqc3pCWG5hZzlsaWE3TUV0eTlxZ3JGZ0E="
    });
  }

  Future<http.Response> getByPath(BuildContext context, String path) async {
    final response = await _http.get('${baseUrl}api/v1/auth/$path', headers: {
      'Content-Type': 'application/json'
    });

    print('${baseUrl}api/v1/auth/$path');

    return response;

  }

  Future<http.Response> postByPath(BuildContext context, String path, dynamic data) async {
    final response = await _http.post('${baseUrl}api/v1/auth/$path', body: jsonEncode(data), headers: {
      'Content-Type': 'application/json'
    });
    return response;

  }

  Future<Map> putByPath(BuildContext context, String path, dynamic data) async {
    final response = await _http.put('${baseUrl}api/v1/auth/$path', body: jsonEncode(data), headers: {
      'Content-Type': 'application/json'
    });

    return {
      "statusCode": 401,
      "body": response.body
    };


    return {
      "statusCode": response.statusCode,
      "body": response.body
    };
  }

}