import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  void fetchProfile() async {
    var data = await ApiService.getProfile();

    setState(() {
      profile = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Color(0xFF1E2F5B),
      ),
      backgroundColor: Colors.grey[200],

      body: loading
          ? Center(child: CircularProgressIndicator())
          : profile == null
          ? Center(child: Text("Failed to load profile"))
          : Center(
        child: Card(
          margin: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // 👤 ICON
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF1E2F5B),
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),

                SizedBox(height: 10),

                // NAME
                Text(
                  profile!['NAME'] ?? "",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2F5B),
                  ),
                ),

                SizedBox(height: 5),

                // EMAIL
                Text(
                  profile!['EMAIL'] ?? "",
                  style: TextStyle(color: Colors.grey[700]),
                ),

                SizedBox(height: 20),

                Divider(),

                // DETAILS
                buildRow("Employee ID", profile!['EMP_ID']),
                buildRow("Designation", profile!['DESIGNATION']),
                buildRow("Contact", profile!['CONTACT']),
                buildRow("Group", profile!['GROUP_NAME']),
                buildRow("Service Type", profile!['SERVICE_TYPE']),
                buildRow("Role", profile!['ROLE']),
                buildRow("Reporting", profile!['REPORTING_INCHARGE']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value?.toString() ?? ""),
          ),
        ],
      ),
    );
  }
}