import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class ApplyTourScreen extends StatefulWidget {
  const ApplyTourScreen({super.key});

  @override
  State<ApplyTourScreen> createState() => _ApplyTourScreenState();
}

class _ApplyTourScreenState extends State<ApplyTourScreen> {

  // ================= USER =================
  String empId = "";
  String name = "";
  String email = "";
  String group = "";
  String contact = "";
  String designation = "";

  // ================= CONTROLLERS =================
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final purposeController = TextEditingController();
  final sanctionController = TextEditingController();
  final placeController = TextEditingController();
  final remarksController = TextEditingController();
  final advanceController = TextEditingController();

  DateTime? startDate, endDate;

  String journeyMode = "";
  String tourType = "";

  bool showAdvance = false;
  List<PlatformFile> files = [];

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      empId = prefs.getString('emp_id') ?? "86";
      name = prefs.getString('username') ?? "Test name";
      email = prefs.getString('email') ?? "test@gmail.com";
      group = prefs.getString('group') ?? "GITS";

      // ✅ NEW FIELDS (you can store later in login)
      contact = prefs.getString('contact') ?? "1234567890";
      designation = prefs.getString('designation') ?? "XYZ";
    });
  }

  // ================= DATE =================
  Future<void> pickDate(bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) startDate = picked;
        else endDate = picked;
      });
    }
  }

  int getDays() {
    if (startDate != null && endDate != null) {
      return endDate!.difference(startDate!).inDays + 1;
    }
    return 1;
  }

  // ================= FILE PICK =================
  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        files = result.files;
      });
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Apply Tour"),
        backgroundColor: const Color(0xFF1E2F5B),
      ),
      backgroundColor: Colors.grey[200],

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [

            // ================= EMPLOYEE DETAILS =================
            sectionCard(
              title: "Employee Details",
              children: [
                buildField("Employee Id", empId),
                buildField("Email", email),
                buildField("Group", group),
                buildField("Name", name),
                buildField("Contact", contact),
                buildField("Designation", designation),
              ],
            ),

            // ================= TOUR DETAILS =================
            sectionCard(
              title: "Tour Details",
              children: [
                buildInput("Purpose of Visit", purposeController),
                buildInput("Sanction Amount", sanctionController),

                dateField("Date From", startDate, () => pickDate(true)),
                dateField("Date To", endDate, () => pickDate(false)),

                buildField("Days", getDays().toString()),

                dropdownField(
                  "Tour Type",
                  ["Field", "Meeting", "Other"],
                      (val) => setState(() => tourType = val),
                ),

                buildInput("Place to be Visited", placeController),
              ],
            ),

            // ================= JOURNEY =================
            sectionCard(
              title: "Journey Details",
              children: [
                buildInput("From", fromController),
                buildInput("To", toController),

                dropdownField(
                  "Mode of Journey",
                  ["Air", "Train", "Taxi", "Bus"],
                      (val) => setState(() => journeyMode = val),
                ),

                buildInput("Remarks", remarksController),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Journey Added")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text("Add Journey"),
                ),
              ],
            ),

            // ================= ADVANCE =================
            sectionCard(
              title: "Advance",
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Enable Advance"),
                    Switch(
                      value: showAdvance,
                      onChanged: (val) {
                        setState(() => showAdvance = val);
                      },
                    ),
                  ],
                ),

                if (showAdvance) ...[
                  const SizedBox(height: 10),
                  buildInput("Grant for Advance", advanceController),
                  dateField(
                    "Amount should be submitted by",
                    endDate,
                        () => pickDate(false),
                  ),
                ]
              ],
            ),

            // ================= FILE =================
            sectionCard(
              title: "Upload File",
              children: [
                ElevatedButton(
                  onPressed: pickFiles,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text("CHOOSE FILE"),
                ),

                const SizedBox(height: 10),

                if (files.isNotEmpty)
                  Column(
                    children: files.map((f) {
                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(f.name),
                      );
                    }).toList(),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2F5B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= COMMON =================
  Widget sectionCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: value,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget dropdownField(
      String label, List<String> items, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((e) {
          return DropdownMenuItem(value: e, child: Text(e));
        }).toList(),
        onChanged: (val) => onChanged(val!),
      ),
    );
  }

  Widget dateField(String label, DateTime? date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              labelText: label,
              hintText: date == null
                  ? "Select Date"
                  : date.toString().split(" ")[0],
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }

  void submitData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Submitted Successfully")),
    );
  }
}