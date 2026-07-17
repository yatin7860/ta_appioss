import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/home_screen.dart';
import '../screens/apply_tour_screen.dart';
import '../screens/my_tour_list_screen.dart';
import '../screens/action_list_screen.dart';
import '../screens/employee_tour_list_screen.dart';
import '../screens/drivers_tour_list.dart';
import '../screens/profile_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatefulWidget {

  final String name;
  final String email;

  const AppDrawer({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String role = "";
  @override
void initState() {
  super.initState();
  loadRole();
}

Future<void> loadRole() async {

  final prefs =
      await SharedPreferences.getInstance();

  role = prefs.getString("role") ?? "";

  print("DRAWER ROLE = $role");

  setState(() {});

}
bool isApprover() {

  String r = role.toUpperCase();

  return

      r.contains("REPORTING_INCHARGE")

      ||

      r.contains("PROJECT_INCHARGE")

      ||

      r.contains("VEHICLE_INCHARGE")

      ||

      r.contains("ACCOUNT")

      ||

      r.contains("DIRECTOR");

}

  bool isDriver() {
    return role.toUpperCase().contains("DRIVER,USER");
  }
 Future<void> logout(BuildContext context) async {

    bool? confirm = await showDialog(

      context: context,

      builder: (context) => AlertDialog(

        title: const Text("Logout"),

        content: const Text(
          "Are you sure you want to logout?",
        ),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(context,false);

            },

            child: const Text("Cancel"),

          ),

          TextButton(

            onPressed: () {

              Navigator.pop(context,true);

            },

            child: const Text("Logout"),

          ),

        ],

      ),

    );

    if(confirm==true){

      final prefs =
      await SharedPreferences.getInstance();

      await prefs.clear();

      if(!context.mounted) return;

      Navigator.pushAndRemoveUntil(

        context,

        MaterialPageRoute(

          builder: (_)=>const LoginScreen(),

        ),

        (route)=>false,

      );

    }

  }

  @override
  Widget build(BuildContext context) {

    print("DRAWER BUILD");
print("CURRENT ROLE : $role");

    return Drawer(

      child: Column(

        children: [

          UserAccountsDrawerHeader(

            decoration: const BoxDecoration(

              color: Color(0xFF1E2F5B),

            ),

            accountName: Text(widget.name),

            accountEmail: Text(widget.email),

            currentAccountPicture: const CircleAvatar(

              backgroundImage:
              AssetImage("assets/logo.png"),

            ),

          ),

          ListTile(

            leading: const Icon(Icons.dashboard),

            title: const Text("Dashboard"),

            onTap: () {

              Navigator.pushReplacement(

                context,

                MaterialPageRoute(

                  builder: (_)=>HomeScreen(name: widget.name),

                ),

              );

            },

          ),

          ListTile(

            leading: const Icon(Icons.flight),

            title: const Text("Apply Tour"),

            onTap: () {

              Navigator.pushReplacement(

                context,

                MaterialPageRoute(

                  builder: (_)=>const ApplyTourScreen(),

                ),

              );

            },

          ),

          ListTile(

            leading: const Icon(Icons.list_alt),

            title: const Text("My Tour List"),

            onTap: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_)=>const MyTourListScreen(),

                ),

              );

            },

          ),

         if (isApprover())

  ListTile(

    leading: const Icon(Icons.check_circle),

    title: const Text("Action List"),

    onTap: () {

      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) => const ActionListScreen(),

        ),

      );

    },

  ),

          if (isApprover())

  ListTile(

    leading: const Icon(Icons.groups),

    title: const Text("Employee Tour List"),

    onTap: () {

      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) => const EmployeeTourListScreen(),

        ),

      );

    },

  ),

          if (isDriver())
            ListTile(
              leading: const Icon(Icons.local_taxi),
              title: const Text("Drivers Tour List"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DriversTourListScreen(),
                  ),
                );
              },
            ),

          ListTile(

            leading: const Icon(Icons.person),

            title: const Text("Profile"),

            onTap: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_)=>const ProfileScreen(),

                ),

              );

            },

          ),

          ListTile(

            leading: const Icon(Icons.lock),

            title: const Text("Change Password"),

            onTap: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_)=>ChangePasswordScreen(),

                ),

              );

            },

          ),

          const Spacer(),

          const Divider(),

          ListTile(

            leading: const Icon(Icons.logout),

            title: const Text("Logout"),

            onTap: ()=>logout(context),

          ),

        ],

      ),

    );

  }

}