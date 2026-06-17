import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  // ================= LOGIN API =================

  static Future<Map<String, dynamic>?> login(
      String username,
      String password,
      ) async {

    var url = Uri.parse(
      "http://202.164.39.167:2345/prsc_ta/authenticateApi",
    );

    var request =
    http.MultipartRequest(
      "POST",
      url,
    );

    request.fields['username'] =
        username;

    request.fields['password'] =
        password;

    var response =
    await request.send();

    if (response.statusCode == 200) {

      var res =
      await response.stream
          .bytesToString();

      var data =
      jsonDecode(res);

      print(
        "LOGIN RESPONSE: $data",
      );

      if (data['success'] ==
          "Login successful") {

        return data;
      }
    }

    return null;
  }

  // ================= CHANGE PASSWORD =================

  static Future<bool> changePassword(

      String oldPassword,

      String newPassword,

      ) async {

    try {

      var url = Uri.parse(
        "http://202.164.39.167:2345/prsc_ta/changePasswordApi",
      );

      var request =
      http.MultipartRequest(
        "POST",
        url,
      );

      final prefs =
      await SharedPreferences
          .getInstance();

      String logId =
          prefs.getString('log_id')
              ?? "";

      print(
        "LOG ID SENT: $logId",
      );

      if (logId.isEmpty) {

        print(
          "ERROR: log_id is empty",
        );

        return false;
      }

      request.fields['log_id'] =
          logId;

      request.fields['old_password'] =
          oldPassword;

      request.fields['new_password'] =
          newPassword;

      request.fields[
      'confirm_password'] =
          newPassword;

      var response =
      await request.send();

      if (response.statusCode == 200) {

        var res =
        await response.stream
            .bytesToString();

        var data =
        jsonDecode(res);

        print(
          "CHANGE PASSWORD RESPONSE: $data",
        );

        if (data['success'] ==
            "Password changed successfully") {

          return true;

        } else {

          print(
            "CHANGE FAILED: "
                "${data['success']}",
          );

          return false;
        }

      } else {

        print(
          "HTTP ERROR: "
              "${response.statusCode}",
        );
      }

    } catch (e) {

      print("ERROR: $e");
    }

    return false;
  }

  // ================= PROFILE API =================

  static Future<Map<String, dynamic>?>
  getProfile({

    bool forceRefresh = false,

  }) async {

    try {

      final prefs =
      await SharedPreferences
          .getInstance();

      // ================= CACHE =================

      if (!forceRefresh) {

        String? cached =
        prefs.getString(
          'profile_data',
        );

        if (cached != null) {

          print(
            "PROFILE FROM CACHE",
          );

          return jsonDecode(cached);
        }
      }

      // ================= API =================

      var url = Uri.parse(
        "http://202.164.39.167:2345/prsc_ta/userprofileApi",
      );

      String logId =
          prefs.getString('log_id')
              ?? "";
      print(
        "PROFILE LOG ID: $logId",
      );

      var request =
      http.MultipartRequest(
        "POST",
        url,
      );

      request.fields['log_id'] =
          logId;

      var response =
      await request.send();

      if (response.statusCode == 200) {

        var res =
        await response.stream
            .bytesToString();

        var data =
        jsonDecode(res);

        print(
          "PROFILE API: $data",
        );

        if (data['success'] == true) {

          await prefs.setString(

            'profile_data',

            jsonEncode(
              data['profile'],
            ),
          );

          return data['profile'];
        }
      }

    } catch (e) {

      print(
        "PROFILE ERROR: $e",
      );
    }

    return null;
  }

  // ================= TOUR DROPDOWN API =================

static Future<Map<String, dynamic>?>
getTourDropdownData() async {

  try {

    final prefs =
    await SharedPreferences
        .getInstance();

    String logId =
        prefs.getString('log_id')
            ?? "";

    print("LOG ID: $logId");

    var url = Uri.parse(
      "http://202.164.39.167:2345/prsc_ta/applytourApi",
    );

    // ================= POST REQUEST =================

    var request =
    http.MultipartRequest(
      "POST",
      url,
    );

    // ================= REQUIRED FIELD =================

    request.fields['log_id'] =
        logId;

    var response =
    await request.send();

    print(
      "TOUR API STATUS: "
          "${response.statusCode}",
    );

    var res =
    await response.stream
        .bytesToString();

    print(
      "TOUR API RESPONSE: $res",
    );

    if (response.statusCode == 200) {

      var data =
      jsonDecode(res);

      return data;
    }

  } catch (e) {

    print(
      "TOUR API ERROR: $e",
    );
  }

  return null;
}
}
