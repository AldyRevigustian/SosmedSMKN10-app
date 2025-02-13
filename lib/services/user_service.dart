import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:smkn10sosmed/models/api_response.dart';
import 'package:smkn10sosmed/models/search.dart';
import 'package:smkn10sosmed/models/user.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:smkn10sosmed/screens/main/search/search.dart';

import '../widget/constant.dart';

// login
Future<ApiResponse> login(String email, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(Uri.parse(loginURL),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password});
    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}

// Register
Future<ApiResponse> register(String name, String fullname, String email,
    String password, String image) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(Uri.parse(registerURL), headers: {
      'Accept': 'application/json'
    }, body: {
      'name': name,
      'fullname': fullname,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'image': image
    });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// User
Future<ApiResponse> getUserDetail() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(userURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// User
Future<ApiResponse> getUserDetailId(int id) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.post(Uri.parse(userIdURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: {
      'id': id.toString()
    });

    // log(response.body);

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['user']
            .map((p) => SearchModel.fromJson(p))
            .toList();
        apiResponse.data as List<dynamic>;
        print(apiResponse.data);
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// Update user
Future<ApiResponse> updateUser(
    String username, String image, String fullname) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.put(Uri.parse(userURL),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: image == null
            ? {
                'name': username,
                'fullname': fullname,
              }
            : {'name': username, 'fullname': fullname, 'image': image});
    // user can update his/her name or name and image

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

Future<ApiResponse> searchUser(String search) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.post(Uri.parse(searchURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: {
      'name': search
    });
    print(search);
    // print(response.body);
    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['user']
            .map((p) => SearchModel.fromJson(p))
            .toList();
        apiResponse.data as List<dynamic>;
        print(apiResponse.data);
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// get token
Future<String> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('token') ?? '';
}

// get user id
Future<int> getUserId() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt('userId') ?? 0;
}

// logout
Future<bool> logout() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return await pref.remove('token');
}

// Get base64 encoded image
String getStringImage(File file) {
  if (file == null) return null;
  return base64Encode(file.readAsBytesSync());
}

String getStringImageByte(Uint8List image) {
  if (image == null) return null;
  return base64Encode(image);
}
