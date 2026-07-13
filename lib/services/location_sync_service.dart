import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/tracking_storage_service.dart';
import 'retry_service.dart';

class LocationSyncService {

  static const String api =
      "http://192.168.1.99:8090/prsc_ta/savelocationdata";

  static Future<bool> uploadLocations() async {

    const int batchSize = 250;

    final allPoints =
    TrackingStorageService.getPendingPoints();

    if (allPoints.isEmpty) {

      debugPrint("No pending locations to upload.");

      return true;

    }

    final points =
    allPoints.take(batchSize).toList();

    if (points.isEmpty) {

      debugPrint("Batch is empty.");

      return true;

    }

    final body = points.map((e) {

      return e.toApiJson();

    }).toList();

    debugPrint("====================================");
    debugPrint("STARTING LOCATION UPLOAD");
    debugPrint("Uploading ${points.length} locations");
    debugPrint("Request JSON:");
    debugPrint(jsonEncode(body));
    debugPrint("====================================");

    try {

      final response = await http.post(

        Uri.parse(api),

        headers: {

          "Content-Type": "application/json",

        },

        body: jsonEncode(body),

      );

      debugPrint(
        "API STATUS : ${response.statusCode}",
      );

      debugPrint(
        "API RESPONSE : ${response.body}",
      );

      final data = jsonDecode(response.body);

      // ============================
      // SUCCESS
      // ============================

      if (response.statusCode == 200 &&
          data["success"] == true) {

        debugPrint("UPLOAD SUCCESS");

        debugPrint(
          "Inserted : ${data["inserted"]}",
        );

        debugPrint(
          "Skipped : ${data["skipped"]}",
        );

        await TrackingStorageService
            .markUploadedBatch(points);

        await TrackingStorageService
            .removeUploaded();

        // Reset retry counter
        RetryService.reset();

        debugPrint(
          "Uploaded locations removed from local storage.",
        );

        return true;

      }

      // ============================

      // SERVER FAILED
      // ============================

      debugPrint("UPLOAD FAILED");

      debugPrint(
        "Server Message : ${data["message"]}",
      );

      RetryService.retryCount++;

      final delay =
      RetryService.nextDelay();

      debugPrint(
        "Retry after $delay",
      );

      RetryService.retryTimer?.cancel();

      RetryService.retryTimer =
          Timer(delay, () async {

            await uploadLocations();

          });

      return false;

    }

    // ============================

    // EXCEPTION
    // ============================

    catch (e) {

      debugPrint(
        "LOCATION SYNC ERROR : $e",
      );

      RetryService.retryCount++;

      final delay =
      RetryService.nextDelay();

      debugPrint(
        "Retry after $delay",
      );

      RetryService.retryTimer?.cancel();

      RetryService.retryTimer =
          Timer(delay, () async {

            await uploadLocations();

          });

      return false;

    }

  }

}