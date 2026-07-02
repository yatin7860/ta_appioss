import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<void> printTour({
    required Map<String, dynamic> tour,
    Map<String, dynamic>? profile,
    required List journeyList,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [

          /// HEADER
          pw.Center(
            child: pw.Text(
              "TOUR DETAILS REPORT",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 20),

          /// BASIC DETAILS
          pw.Text(
            "Basic Details",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.Divider(),

          ...tour.entries.map(
                (e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                children: [

                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      e.key,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),

                  pw.Expanded(
                    flex: 3,
                    child: pw.Text("${e.value ?? "-"}"),
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(height: 20),

          /// PROFILE
          if (profile != null) ...[

            pw.Text(
              "Approval Details",
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.Divider(),

            ...profile.entries.map(
                  (e) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  children: [

                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        e.key,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),

                    pw.Expanded(
                      flex: 3,
                      child: pw.Text("${e.value ?? "-"}"),
                    ),
                  ],
                ),
              ),
            ),
          ],

          pw.SizedBox(height: 20),

          /// JOURNEY DETAILS

          pw.Text(
            "Journey Details",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.Divider(),

          ...journeyList.asMap().entries.map((entry) {

            final journey = entry.value;

            return pw.Column(

              crossAxisAlignment: pw.CrossAxisAlignment.start,

              children: [

                pw.Text(
                  "Journey ${entry.key + 1}",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                pw.SizedBox(height: 8),

                ...journey.entries.map(
                      (e) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 5),
                    child: pw.Row(
                      children: [

                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            e.key,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),

                        pw.Expanded(
                          flex: 3,
                          child: pw.Text("${e.value ?? "-"}"),
                        ),
                      ],
                    ),
                  ),
                ),

                pw.Divider(),

              ],

            );

          }),

        ],
      ),
    );

    final bytes = await pdf.save();

// Save PDF locally
    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      "${directory.path}/Tour_${tour["TOUR_ID"]}.pdf",
    );

    await file.writeAsBytes(bytes);

// Open print dialog
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
    );
  }
}