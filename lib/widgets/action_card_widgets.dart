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

class ActionButtonsSection extends StatelessWidget {
  final Map tour;
  final List<String> userRoles;
  final TextEditingController remarksController;

  final VoidCallback onApprove;
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
  Widget build(BuildContext context) {
    return Column(
      children: [

        /// ================================
        /// APPROVAL SECTION
        /// ================================
        if (ApiService.canCurrentRoleApprove(
          tour,
          userRoles,
        )) ...[

          TextField(
            controller: remarksController,
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
                  onPressed: onApprove,
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
                  onPressed: onReject,
                  label: const Text("Reject"),
                ),
              ),

            ],
          ),

          const SizedBox(height: 20),

        ],

                /// ================================
        /// EXECUTION SECTION
        /// ================================
        if (ApiService.isFullyApproved(tour) &&
            ApiService.isConfirmationPending(tour) &&
            userRoles.contains("REPORTING_INCHARGE")) ...[

          TextField(
            controller: remarksController,
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
                  onPressed: onExecute,
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
                  onPressed: onNotExecute,
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