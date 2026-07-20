import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// =======================================================
/// OVERALL STATUS WIDGET
/// =======================================================

class OverallStatus extends StatelessWidget {
  final Map tour;

  const OverallStatus({
    super.key,
    required this.tour,
  });

  @override
  Widget build(BuildContext context) {
    String status = "IN PROCESS";
    Color color = Colors.orange;

    if (tour["RI_STATUS"] == "REJECT" ||
        tour["PI_STATUS"] == "REJECT" ||
        tour["VI_STATUS"] == "REJECT" ||
        tour["AO_STATUS"] == "REJECT" ||
        tour["DIRECTOR_STATUS"] == "REJECT") {
      status = "REJECTED";
      color = Colors.red;
    } else if (ApiService.isFullyApproved(tour) &&
        ApiService.isConfirmationPending(tour)) {
      status = "WAITING EXECUTION";
      color = Colors.blue;
    } else if (tour["CONFIRMATION_STATUS_"] == "EXECUTED") {
      status = "EXECUTED";
      color = Colors.green;
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Chip(
        backgroundColor: color,
        label: Text(
          status,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// CONFIRMATION CARD
/// =======================================================

class ConfirmationCard extends StatelessWidget {
  final Map tour;

  const ConfirmationCard({
    super.key,
    required this.tour,
  });

  @override
  Widget build(BuildContext context) {
    final bool pending =
        tour["CONFIRMATION_STATUS_"] == "PENDING";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pending
            ? Colors.orange.shade100
            : Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            pending
                ? Icons.pending_actions
                : Icons.check_circle,
            color: Colors.blue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Confirmation : ${tour["CONFIRMATION_STATUS_"]}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// ACTION BUTTONS SECTION
/// =======================================================
class ActionButtonsSection extends StatefulWidget {
  final Map tour;
  final List<String> userRoles;
  final TextEditingController remarksController;

  final Function(
      String vehicle,
      String driver,
      ) onApprove;

  final VoidCallback onReject;
  final VoidCallback onExecute;
  final VoidCallback onNotExecute;

  const ActionButtonsSection({
    super.key,
    required this.tour,
    required this.userRoles,
    required this.remarksController,
    required this.onApprove,
    required this.onReject,
    required this.onExecute,
    required this.onNotExecute,
  });

  @override
  State<ActionButtonsSection> createState() =>
      _ActionButtonsSectionState();
}

class _ActionButtonsSectionState
    extends State<ActionButtonsSection> {

  List<String> vehicles = [];

  List<String> drivers = [];

  String? selectedVehicle;

  String? selectedDriver;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadVehicleData();
  }

  Future<void> loadVehicleData() async {
    final data =
    await ApiService.getVehicleDriverOptions();

    if (data != null &&
        data["success"] == true) {

      vehicles =
          (data["vehicle_number"] as List)
              .map(
                (e) => e["VEHICLE_NUMBER"]
                .toString(),
          )
              .toList();

      drivers =
          (data["driver_name"] as List)
              .map(
                (e) => e["DRIVER_NAME"]
                .toString(),
          )
              .toList();
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final fullyApproved =
    ApiService.isFullyApproved(
      widget.tour,
    );

    final confirmationPending =
    ApiService.isConfirmationPending(
      widget.tour,
    );

    final isReportingIncharge =
    widget.userRoles.contains(
      "REPORTING_INCHARGE",
    );

    debugPrint(
      "===== EXECUTION CHECK =====",
    );

    debugPrint(
      "Fully Approved : $fullyApproved",
    );

    debugPrint(
      "Confirmation Pending : $confirmationPending",
    );

    debugPrint(
      "Reporting Incharge : $isReportingIncharge",
    );

    return Column(
      children: [

        /// ================================
        /// APPROVAL SECTION
        /// ================================

        if (ApiService.canCurrentRoleApprove(
          widget.tour,
          widget.userRoles,
        )) ...[

// Vehicle & Driver Dropdown only for Vehicle Incharge
          if (widget.userRoles.contains("VEHICLE_INCHARGE") ||
              widget.userRoles.contains("VEHICLE_INCHARGE_1") ||
              widget.userRoles.contains("VEHICLE_INCHARGE_2")) ...[

            DropdownButtonFormField<String>(
              value: selectedVehicle,
              decoration: InputDecoration(
                labelText: "Vehicle Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: vehicles.map((vehicle) {
                return DropdownMenuItem<String>(
                  value: vehicle,
                  child: Text(vehicle),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedVehicle = value;
                });
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedDriver,
              decoration: InputDecoration(
                labelText: "Driver Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: drivers.map((driver) {
                return DropdownMenuItem<String>(
                  value: driver,
                  child: Text(driver),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDriver = value;
                });
              },
            ),

            const SizedBox(height: 15),
          ],

          TextField(
            controller: widget.remarksController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Remarks",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [

              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.check),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    widget.onApprove(
                      selectedVehicle ?? "",
                      selectedDriver ?? "",
                    );
                  },
                  label: const Text("Approve"),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.close),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: widget.onReject,
                  label: const Text("Reject"),
                ),
              ),

            ],
          ),

          const SizedBox(height: 20),

        ],





        /// EXECUTION SECTION
        /// ================================
        if (ApiService.isFullyApproved(widget.tour) &&
            ApiService.isConfirmationPending(widget.tour) &&
            widget.userRoles.contains("REPORTING_INCHARGE")) ...[

          TextField(
            controller: widget.remarksController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Execution Remarks",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [

              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: widget.onExecute,
                  child: const Text(
                    "Execute All",
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: widget.onNotExecute,
                  child: const Text(
                    "Not Execute",
                  ),
                ),
              ),

            ],
          ),

        ],

      ],
    );
  }
}
