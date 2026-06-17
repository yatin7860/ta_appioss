import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ApplyTourScreen extends StatefulWidget {

  const ApplyTourScreen({super.key});

  @override
  State<ApplyTourScreen> createState() =>
      _ApplyTourScreenState();
}

class _ApplyTourScreenState
    extends State<ApplyTourScreen> {

  // ================= USER =================

  String empId = "";

  String name = "";

  String email = "";

  String group = "";

  String contact = "";

  String designation = "";

  // ================= CONTROLLERS =================

  final fromController =
  TextEditingController();

  final toController =
  TextEditingController();

  final purposeController =
  TextEditingController();

  final sanctionController =
  TextEditingController();

  final placeController =
  TextEditingController();

  final remarksController =
  TextEditingController();

  final advanceController =
  TextEditingController();

  DateTime? startDate;

  DateTime? endDate;

  String journeyMode = "";

  String tourType = "";

  List<String> projectSchemes = [];

  List<String> journeyModes = [];

  String? selectedProjectScheme;

  String? selectedJourneyMode;

  bool showAdvance = false;

  List<PlatformFile> files = [];

  // ================= INIT =================

 @override
void initState() {

  super.initState();

  loadUser();

  fetchDropdownData();
}


  // ================= LOAD USER =================

Future<void> loadUser() async {

  try {

    final data =
    await ApiService.getProfile();

    print("PROFILE DATA: $data");

    if (data != null) {

      setState(() {

        empId =
            data['EMP_ID']
                ?.toString() ?? "";

        name =
            data['NAME']
                ?.toString() ?? "";

        email =
            data['EMAIL']
                ?.toString() ?? "";

        group =
            data['GROUP_NAME']
                ?.toString() ?? "";

        contact =
            data['CONTACT']
                ?.toString() ?? "";

        designation =
            data['DESIGNATION']
                ?.toString() ?? "";
      });
    }

  } catch (e) {

    print(
      "LOAD USER ERROR: $e",
    );
  }
}
///////
  Future<void> fetchDropdownData() async {

    try {

      final data =
      await ApiService
          .getTourDropdownData();

      print(data);

      if (data != null &&
          data["success"] == true) {

        final List<dynamic> schemes =
            data["project_schemes"] ?? [];

        final List<dynamic> journeys =
            data["journey_modes"] ?? [];

        setState(() {

          projectSchemes = schemes
              .map((e) =>
              e["Project_Name"].toString())
              .toList();

          journeyModes = journeys
              .map((e) =>
              e["JOURNEY_MODE"].toString())
              .toList();
        });

        print(projectSchemes);

        print(journeyModes);
      }

    } catch (e) {

      print(e);
    }
  }

  // ================= DATE PICKER =================

  Future<void> pickDate(
      bool isStart,
      ) async {

    DateTime? picked =
    await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2023),

      lastDate: DateTime(2100),
    );

    if (picked != null) {

      setState(() {

        if (isStart) {

          startDate = picked;

        } else {

          endDate = picked;
        }
      });
    }
  }

  // ================= DAYS =================
  String getDays() {

    if (startDate != null &&
        endDate != null) {

      int days =
          endDate!
              .difference(startDate!)
              .inDays + 1;

      return days.toString();
    }

    return "1";
  }

  // ================= FILE PICKER =================

  Future<void> pickFiles() async {

    FilePickerResult? result =
    await FilePicker.platform.pickFiles(

      allowMultiple: true,

      type: FileType.any,
    );

    if (result != null) {

      setState(() {

        files = result.files;
      });
    }
  }

  // ================= SUBMIT =================

  void submitData() {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        content: Text(
          "Submitted Successfully",
        ),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF2F2F2),

      appBar: AppBar(

        backgroundColor:
        const Color(0xFF162B63),

        elevation: 0,

        leading: IconButton(

          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),

          onPressed: () {},
        ),

        title: const Text(

          "Apply Tour",

          style: TextStyle(

            color: Colors.white,

            fontWeight:
            FontWeight.bold,

            fontSize: 22,
          ),
        ),

        actions: [

          IconButton(

            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),

            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(18),

        child: Column(

          children: [

            // ================= EMPLOYEE DETAILS =================

            sectionCard(

              title: "Employee Details",

              children: [

                buildField(
                  "Employee Id",
                  empId,
                ),

                buildField(
                  "Email",
                  email,
                ),

                buildField(
                  "Group",
                  group,
                ),

                buildField(
                  "Name",
                  name,
                ),

                buildField(
                  "Contact",
                  contact,
                ),

                buildField(
                  "Designation",
                  designation,
                ),
              ],
            ),

            // ================= TOUR DETAILS =================

            sectionCard(

              title: "Tour Details",

              children: [

                // ================= PURPOSE =================

                buildInput(
                  "Purpose of Visit",
                  purposeController,
                ),

                // ================= SANCTION =================

                buildInput(
                  "Sanction",
                  sanctionController,
                ),

                // ================= DATE FROM =================

                dateField(
                  "Date From",
                  startDate,
                      () => pickDate(true),
                ),

                if (startDate == null)

                  const Padding(

                    padding: EdgeInsets.only(
                      left: 4,
                      top: 2,
                      bottom: 12,
                    ),

                    child: Text(

                      "Start date is required",

                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),

                // ================= DATE TO =================

                dateField(
                  "Date To",
                  endDate,
                      () => pickDate(false),
                ),

                if (endDate == null)

                  const Padding(

                    padding: EdgeInsets.only(
                      left: 4,
                      top: 2,
                      bottom: 12,
                    ),

                    child: Text(

                      "End date is required",

                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),

                // ================= AUTO DAYS =================

                buildField(
                  "Days",
                  getDays(),
                ),

                // ================= TOUR TYPE =================

                dropdownField(

                  "Tour Type",

                  [
                    "Field",
                    "Meeting",
                    "Office",
                    "Other",
                  ],

                      (val) {

                    setState(() {

                      tourType = val;
                    });
                  },
                ),

                if (tourType.isEmpty)

                  const Padding(

                    padding: EdgeInsets.only(
                      left: 4,
                      top: 2,
                      bottom: 12,
                    ),

                    child: Text(

                      "tour type is Required",

                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),

                // ================= PROJECT SCHEME =================

DropdownButtonFormField<String>(

  isExpanded: true,

  value: selectedProjectScheme,

  decoration: InputDecoration(

    border: OutlineInputBorder(

      borderRadius:
      BorderRadius.circular(10),
    ),
  ),

  hint: const Text(
    "Select Project Scheme",
  ),

  items:
  projectSchemes.map((item) {

    return DropdownMenuItem(

      value: item,

      child: Text(
        item,
        overflow:
        TextOverflow.ellipsis,
      ),
    );

  }).toList(),

  onChanged: (value) {

    setState(() {

      selectedProjectScheme =
          value;
    });
  },
),
                // ================= PLACE =================

                buildInput(
                  "Place to be Visited",
                  placeController,
                ),
              ],
            ),



            // ================= JOURNEY DETAILS =================

            sectionCard(

              title: "Journey Details",

              children: [

                dateField(
                  "Date",
                  startDate,
                      () => pickDate(true),
                ),
                if (startDate == null)

                  const Padding(

                    padding: EdgeInsets.only(
                      left: 4,
                      top: 2,
                      bottom: 12,
                    ),

                    child: Text(

                      "Journey date is required",

                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),


                buildInput(
                  "From",
                  fromController,
                ),
                if (startDate == null)

                  const Padding(

                    padding: EdgeInsets.only(
                      left: 4,
                      top: 2,
                      bottom: 12,
                    ),

                    child: Text(

                      "Start date is required",

                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),


                buildInput(
                  "To",
                  toController,
                ),
////////

DropdownButtonFormField<String>(

  isExpanded: true,

  value: selectedJourneyMode,

  decoration: InputDecoration(

    border: OutlineInputBorder(

      borderRadius:
      BorderRadius.circular(10),
    ),
  ),

  hint: const Text(
    "Select Mode of Journey",
  ),

  items:
  journeyModes.map((item) {

    return DropdownMenuItem(

      value: item,

      child: Text(item),
    );

  }).toList(),

  onChanged: (value) {

    setState(() {

      selectedJourneyMode =
          value;
    });
  },
),
buildInput(
  "Remarks",
  remarksController,
),

SizedBox(
  width: double.infinity,

  child: ElevatedButton(

    onPressed: () {},

    child: const Text(
      "Add Journey",
    ),
  ),
),
],
),

            // ================= ADVANCE =================

            sectionCard(

              title: "Advance",

              children: [

                Row(

                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    const Text(

                      "Enable Advance",

                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    Switch(

                      value: showAdvance,

                      onChanged: (val) {

                        setState(() {

                          showAdvance = val;
                        });
                      },
                    ),
                  ],
                ),

                if (showAdvance) ...[

                  const SizedBox(
                    height: 15,
                  ),

                  buildInput(
                    "Grant for Advance",
                    advanceController,
                  ),

                  dateField(
                    "Amount should be submitted by",
                    endDate,
                        () => pickDate(false),
                  ),
                ],
              ],
            ),

            // ================= FILE =================

            sectionCard(

              title: "Upload File",

              children: [

                SizedBox(

                  width: double.infinity,

                  child: ElevatedButton(

                    onPressed: pickFiles,

                    style:
                    ElevatedButton.styleFrom(

                      backgroundColor:
                      Colors.blue,

                      minimumSize:
                      const Size(
                        double.infinity,
                        50,
                      ),

                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),

                    child: const Text(

                      "CHOOSE FILE",

                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                if (files.isNotEmpty)

                  Column(

                    children: files.map((f) {

                      return ListTile(

                        leading: const Icon(
                          Icons.insert_drive_file,
                        ),

                        title: Text(f.name),
                      );
                    }).toList(),
                  ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            // ================= SUBMIT =================

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: submitData,

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  const Color(0xFF162B63),

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 16,
                  ),

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),

                child: const Text(

                  "Submit",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),

        ),
    );

  }


  // ================= SECTION CARD =================

  Widget sectionCard({

    required String title,

    required List<Widget> children,

  }) {

    return Container(

      width: double.infinity,

      margin:
      const EdgeInsets.only(bottom: 20),

      padding:
      const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        border: Border.all(
          color: Colors.grey.shade400,
        ),

        borderRadius:
        BorderRadius.circular(10),
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            title,

            style: const TextStyle(

              fontSize: 20,

              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          ...children,
        ],
      ),
    );
  }

  // ================= READONLY FIELD =================

  Widget buildField(
      String label,
      String value,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 18),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            label,

            style: const TextStyle(

              fontSize: 16,

              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          TextField(

            readOnly: true,

            decoration: InputDecoration(

              hintText: value,

              contentPadding:
              const EdgeInsets.symmetric(

                horizontal: 16,

                vertical: 18,
              ),

              enabledBorder:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(10),

                borderSide: BorderSide(
                  color:
                  Colors.grey.shade300,
                ),
              ),

              focusedBorder:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(10),

                borderSide: BorderSide(
                  color:
                  Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= INPUT =================

  Widget buildInput(

      String label,

      TextEditingController controller,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 18),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            label,

            style: const TextStyle(

              fontSize: 16,

              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          TextField(

            controller: controller,

            decoration: InputDecoration(

              hintText: label,

              contentPadding:
              const EdgeInsets.symmetric(

                horizontal: 16,

                vertical: 18,
              ),

              enabledBorder:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(10),

                borderSide: BorderSide(
                  color:
                  Colors.grey.shade300,
                ),
              ),

              focusedBorder:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(10),

                borderSide: BorderSide(
                  color:
                  Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= DROPDOWN =================

  Widget dropdownField(

      String label,

      List<String> items,

      Function(String) onChanged,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 18),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            label,

            style: const TextStyle(

              fontSize: 16,

              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

  DropdownButtonFormField<String>(

  isExpanded: true,

  value: label == "Project Scheme"
      ? selectedProjectScheme
      : label == "Mode of Journey"
      ? selectedJourneyMode
      : null,

  decoration: InputDecoration(

    contentPadding:
    const EdgeInsets.symmetric(

      horizontal: 16,

      vertical: 5,
    ),

    enabledBorder:
    OutlineInputBorder(

      borderRadius:
      BorderRadius.circular(10),

      borderSide: BorderSide(
        color:
        Colors.grey.shade300,
      ),
    ),

    focusedBorder:
    OutlineInputBorder(

      borderRadius:
      BorderRadius.circular(10),

      borderSide: BorderSide(
        color:
        Colors.grey.shade400,
      ),
    ),
  ),

  hint: Text(
    "Select $label",
  ),

  items: items.map((e) {

    return DropdownMenuItem<String>(

      value: e,

      child: Text(

        e,

        overflow:
        TextOverflow.ellipsis,
      ),
    );

  }).toList(),

  onChanged: (val) {

    if (val != null) {
      onChanged(val);
            }
            },
          ),
        ],
      ),
    );
  }

  // ================= DATE FIELD =================

  Widget dateField(

      String label,

      DateTime? date,

      VoidCallback onTap,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 18),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            label,

            style: const TextStyle(

              fontSize: 16,

              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          GestureDetector(

            onTap: onTap,

            child: AbsorbPointer(

              child: TextField(

                decoration: InputDecoration(

                  hintText: date == null

                      ? "Select Date"

                      : date
                      .toString()
                      .split(" ")[0],

                  contentPadding:
                  const EdgeInsets.symmetric(

                    horizontal: 16,

                    vertical: 18,
                  ),

                  enabledBorder:
                  OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(10),

                    borderSide: BorderSide(
                      color:
                      Colors.grey.shade300,
                    ),
                  ),

                  focusedBorder:
                  OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(10),

                    borderSide: BorderSide(
                      color:
                      Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

