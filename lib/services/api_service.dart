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
      "http://192.168.1.99:8090/prsc_ta/authenticateApi",
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
        "http://192.168.1.99:8090/prsc_ta/changePasswordApi",
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
        "http://192.168.1.99:8090/prsc_ta/userprofileApi",
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
// ================= SUBMIT TOUR API =================
static Future<Map<String, dynamic>?> submitTour(
    Map<String, dynamic> body,
) async {

  try {

    print("========== INSIDE submitTour ==========");

    var url = Uri.parse(
      "http://192.168.1.99:8090/prsc_ta/inserttourApi",
    );

    var request = http.MultipartRequest(
      "POST",
      url,
    );

    body.forEach((key, value) {

      if (key == "journey_details") {
        request.fields[key] = jsonEncode(value);
      } else {
        request.fields[key] = value.toString();
      }

    });

    print("REQUEST FIELDS:");
    print(request.fields);

    var response = await request.send().timeout(
  const Duration(seconds: 20),
);

    print("SUBMIT TOUR STATUS : ${response.statusCode}");

    var res = await response.stream.bytesToString();

    print("SUBMIT TOUR RESPONSE : $res");

    if (response.statusCode == 200) {
      return jsonDecode(res);
    }

    return {
      "success": false,
      "message": "HTTP Error ${response.statusCode}"
    };

  } catch (e, stackTrace) {

    print("SUBMIT TOUR ERROR : $e");
    print(stackTrace);

    return {
      "success": false,
      "message": e.toString()
    };
  }
}


//================ MY TOUR LIST API =================//

  static Future<Map<String, dynamic>?> getMyTourList() async {

    try {

      final prefs = await SharedPreferences.getInstance();

      String logId = prefs.getString("log_id") ?? "";

      print("MY TOUR LIST LOG ID : $logId");

      var url = Uri.parse(
        "http://192.168.1.99:8090/prsc_ta/mytourlistApi",
      );

      var request = http.MultipartRequest(
        "POST",
        url,
      );

      request.fields["log_id"] = logId;

      print("REQUEST FIELDS : ${request.fields}");

      var response = await request.send();

      var res = await response.stream.bytesToString();

      print("MY TOUR LIST STATUS : ${response.statusCode}");
      print("MY TOUR LIST RESPONSE : $res");

      if (response.statusCode == 200) {
        return jsonDecode(res);
      }

    } catch (e) {

      print("MY TOUR LIST ERROR : $e");

    }

    return null;
  }
  //================ TOUR DETAILS API =================//

static Future<Map<String, dynamic>?> getTourDetails(
    String tourId,
) async {

  try {

    var url = Uri.parse(
      "http://192.168.1.99:8090/prsc_ta/longtour",
    );

    var request = http.MultipartRequest(
      "POST",
      url,
    );

    request.fields["tour_id"] = tourId;

    print("TOUR DETAILS REQUEST : ${request.fields}");

    var response = await request.send();

    var res = await response.stream.bytesToString();

    print("TOUR DETAILS STATUS : ${response.statusCode}");
    print("TOUR DETAILS RESPONSE : $res");

    if (response.statusCode == 200) {

      return jsonDecode(res);

    }

  } catch (e) {

    print("TOUR DETAILS ERROR : $e");

  }

  return null;
}
//================ ACTION LIST API =================//

static Future<Map<String, dynamic>?> getActionList() async {

  try {

    final prefs = await SharedPreferences.getInstance();

    String logId = prefs.getString("log_id") ?? "";

    var url = Uri.parse(
      "http://192.168.1.99:8090/prsc_ta/actionlistApi",
    );

    var request = http.MultipartRequest(
      "POST",
      url,
    );

    request.fields["log_id"] = logId;

    print("ACTION LIST REQUEST");
    print(request.fields);

    var response = await request.send();

    var res = await response.stream.bytesToString();

    print("ACTION LIST STATUS : ${response.statusCode}");

    print("ACTION LIST RESPONSE : $res");

    if (response.statusCode == 200) {

      return jsonDecode(res);

    }

  } catch(e){

    print("ACTION LIST ERROR : $e");

  }

  return null;

}
//================ APPROVAL API =================//

static Future<Map<String, dynamic>?> approveTour({

  required String tourId,

  required String action,

  required String remarks,

  required String email,

  String vehicleName = "",

  String driverName = "",

}) async {

  try {

    var url = Uri.parse(

      "http://192.168.1.99:8090/prsc_ta/approveApi",

    );

    var request = http.MultipartRequest(

      "POST",

      url,

    );

    request.fields["tour_id"] = tourId;

    request.fields["action"] = action;

    request.fields["remarks"] = remarks;

    request.fields["email"] = email;

    request.fields["VEHICLE_NAME"] = vehicleName;

    request.fields["DRIVER_NAME"] = driverName;

    print("APPROVAL REQUEST");

    print(request.fields);

    var response = await request.send();

    var res = await response.stream.bytesToString();

    print("APPROVAL STATUS : ${response.statusCode}");

    print("APPROVAL RESPONSE : $res");

    if(response.statusCode==200){

      return jsonDecode(res);

    }

  }catch(e){

    print("APPROVAL ERROR : $e");

  }

  return null;

}
//================ CONFIRM JOURNEY API =================//

static Future<Map<String,dynamic>?> confirmJourney({

  required String tourId,

  required String confirmationStatus,

  required String remarks,

}) async {

  try{

    var url = Uri.parse(

      "http://192.168.1.99:8090/prsc_ta/confirmJourneyApi",

    );

    var request = http.MultipartRequest(

      "POST",

      url,

    );

    request.fields["tour_id"]=tourId;

    request.fields["confirmation_status"]=confirmationStatus;

    request.fields["remarks"]=remarks;

    print("CONFIRM REQUEST");

    print(request.fields);

    var response=await request.send();

    var res=await response.stream.bytesToString();

    print("CONFIRM STATUS : ${response.statusCode}");

    print("CONFIRM RESPONSE : $res");

    if(response.statusCode==200){

      return jsonDecode(res);

    }

  }catch(e){

    print("CONFIRM ERROR : $e");

  }

  return null;

}
//================ GET USER ROLE =================//

static Future<String> getUserRole() async {

  final profile = await getProfile();

  if(profile!=null){

    return profile["ROLE"] ?? "";

  }

  return "";

}
//================ GET USER EMAIL =================//

static Future<String> getLoggedUserEmail() async {

  final profile = await getProfile();

  if(profile!=null){

    return profile["EMAIL"] ?? "";

  }

  return "";

}
//================ CAN APPROVE =================//

static Future<bool> canApprove() async {

  String role = await getUserRole();

  return role != "USER";

}
static bool isFullyApproved(Map tour){

  return

      tour["RI_STATUS"]=="APPROVE"

      &&

      tour["PI_STATUS"]=="APPROVE"

      &&

      tour["VI_STATUS"]=="APPROVE"

      &&

      tour["AO_STATUS"]=="APPROVE"

      &&

      tour["DIRECTOR_STATUS"]=="APPROVE";

}
static bool isConfirmationPending(Map tour){

  return

      tour["CONFIRMATION_STATUS_"]=="PENDING";

}
static bool canCurrentRoleApprove(

Map tour,

String role,

){

  switch(role){

    case "REPORTING_INCHARGE":

      return tour["RI_STATUS"]=="PENDING";

    case "PROJECT_IN":

      return tour["PI_STATUS"]=="PENDING";

    case "VEHICLE_INCHARGE":

      return tour["VI_STATUS"]=="PENDING";

    case "ACCOUNT_OFFICE":

      return tour["AO_STATUS"]=="PENDING";

    case "DIRECTOR":

      return tour["DIRECTOR_STATUS"]=="PENDING";

    default:

      return false;

  }

}
}
