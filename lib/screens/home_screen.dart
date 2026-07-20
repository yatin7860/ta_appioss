import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';
import 'profile_screen.dart';
import 'apply_tour_screen.dart';
import 'my_tour_list_screen.dart';
import 'action_list_screen.dart';
import 'employee_tour_list_screen.dart';
import 'drivers_tour_list.dart';
import '../widgets/app_drawer.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final String name;

  const HomeScreen({required this.name, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String email = "";
  String role = "";
  int myTourCount = 0;
  int employeeTourCount = 0;
  int actionTourCount = 0;
  int driverTourCount = 0;

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadDashboardCount();
  }

  void loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      email = prefs.getString("email") ?? "";

      role = prefs.getString("role") ?? "";
    });

    print("HOME ROLE : $role");
  }
//
  Future<void> loadDashboardCount() async {

    final result = await ApiService.getDashboardCount();

    if (result != null && result["success"] == true) {

      final data = result["data"];

      setState(() {

        // API key is My_tour_list_Count (with underscore before Count)
        myTourCount =
            data["My_tour_list_Count"] ?? 0;

        employeeTourCount =
            data["Employee_tour_listcount"] ?? 0;

        actionTourCount =
            data["Action_tour_listcount"] ?? 0;

        driverTourCount =
            data["driverlistcount"] ?? 0;

      });

    }

  }

  // ================= LOGOUT =================
  void logout(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Logout"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ================= DASHBOARD CARDS =================
    List<Widget> cards = [
      buildCard(
        icon: Icons.flight,
        title: "Apply Tour",
        color: Colors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ApplyTourScreen(),
            ),
          );
        },
      ),

      buildCard(
        icon: Icons.calendar_today,
        title: "My Tour List",
        color: Colors.green,
        count: myTourCount,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyTourListScreen(),
            ),
          );
        },
      ),

      if (

      role.contains("PROJECT_INCHARGE") ||

          role.contains("REPORTING_INCHARGE") ||

          role.contains("ACCOUNT") ||

          role.contains("DIRECTOR") ||

          role.contains("VEHICLE_INCHARGE")

      )

        buildCard(

          icon: Icons.check_circle,

          title: "Action List",

          color: Colors.red,

          count: actionTourCount,

          onTap: () {
            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) => const ActionListScreen(),

              ),

            );
          },

        ),

      if (

      role.contains("PROJECT_INCHARGE") ||

          role.contains("REPORTING_INCHARGE") ||

          role.contains("ACCOUNT") ||

          role.contains("DIRECTOR") ||

          role.contains("VEHICLE_INCHARGE")

      )

        buildCard(

          icon: Icons.groups,

          title: "Employee Tour List",

          color: Colors.amber,

          count: employeeTourCount,

          onTap: () {
            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) => const EmployeeTourListScreen(),

              ),

            );
          },

        ),
      if (

      role.contains("DRIVER,USER")

      )

        buildCard(

          icon: Icons.local_taxi,

          title: "Drivers Tour List",

          color: Colors.amber,

          count: driverTourCount,

          onTap: () {
            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) => const DriversTourListScreen(),

              ),

            );
          },

        ),

      buildCard(
        icon: Icons.person,
        title: "Profile",
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileScreen(),
            ),
          );
        },
      ),

      buildCard(
        icon: Icons.key,
        title: "Change Password",
        color: Colors.blueAccent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangePasswordScreen(),
            ),
          );
        },
      ),
    ];

    return Scaffold(

      ///drawer
      drawer: AppDrawer(
        name: widget.name,
        email: email,
      ),

      // ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2F5B),
        title: const Text("Dashboard"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == "logout") {
                logout(context);
              }
            },
            itemBuilder: (context) =>
            [
              const PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text("Logout"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      backgroundColor: Colors.grey[200],

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Text(
              "Welcome ${widget.name} to TA App",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                itemCount: cards.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.8,
                ),
                itemBuilder: (context, index) {
                  return cards[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD UI =================
  Widget buildCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    int count = -1,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [

            if (count >= 0)
              Positioned(
                top: 10,
                right: 12,
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Icon(icon, color: Colors.white),

                  const SizedBox(width: 10),

                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}