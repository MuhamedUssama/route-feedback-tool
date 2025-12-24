import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mentor_assistant/features/report/data/models/weekly_report_model.dart';
import 'package:intl/intl.dart';

class PdfGeneratorService {
  static const PdfColor _routeBlue = PdfColor.fromInt(0xFF004182);
  static const PdfColor _lightGrey = PdfColor.fromInt(0xFFF5F5F5);
  static const PdfColor _textGrey = PdfColor.fromInt(0xFF616161);

  Future<Uint8List> generateReport(WeeklyReportModel report) async {
    final pdf = pw.Document();

    // 1. Load Assets (Logo & Font)
    final regularFont = await rootBundle.load(
      'assets/fonts/OpenSans-Regular.ttf',
    );
    final boldFont = await rootBundle.load('assets/fonts/OpenSans-Bold.ttf');

    final pngLogoBytes = (await rootBundle.load(
      'assets/images/route_logo.png',
    )).buffer.asUint8List();

    // 2. Define Theme with the Custom Font 🎨
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(regularFont),
      bold: pw.Font.ttf(boldFont),
    );

    pdf.addPage(
      pw.MultiPage(
        theme: theme, // Apply font theme
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        // footer logic handles page numbering
        footer: (context) => _buildFooter(context),
        build: (pw.Context context) {
          return [
            _buildHeader(report, pngLogoBytes),
            pw.SizedBox(height: 20),

            _buildSummarySection(report),
            pw.SizedBox(height: 20),

            // Fix: Title separated from Grid to allow Grid to break pages
            _buildSectionTitle('Groups Performance'),
            pw.SizedBox(height: 10),

            // CHANGED: Use Tables instead of Grid
            ..._buildGroupsTables(report),
            pw.SizedBox(height: 20),

            _buildWorkshopSection(report),
            pw.SizedBox(height: 20),

            if (report.logistics.isNotEmpty) ...[
              _buildSectionTitle('Branches Attendance'),
              pw.SizedBox(height: 10),
              _buildLogisticsSection(report),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ... _buildHeader (Same as before) ...
  pw.Widget _buildHeader(WeeklyReportModel report, Uint8List pngLogo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          height: 60,
          width: 60,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            borderRadius: pw.BorderRadius.circular(1000),
          ),
          child: pw.Image(pw.MemoryImage(pngLogo)),
        ),

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Mentor Weekly Report',
              style: pw.TextStyle(
                fontSize: 18,
                color: _routeBlue,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              DateFormat('MMMM dd, yyyy').format(report.reportDate),
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.Text(
              'Mentor: Mohamed Osama',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  // ... _buildSummarySection (Added SizedConstraint to Chart Stack) ...
  pw.Widget _buildSummarySection(WeeklyReportModel report) {
    int totalSubmitted = 0;
    int totalMissing = 0;
    for (var g in report.groups) {
      totalSubmitted += g.submittedCount;
      totalMissing += g.missingCount;
    }
    final total = totalSubmitted + totalMissing;
    final submittedPct = total > 0
        ? (totalSubmitted / total * 100).toStringAsFixed(1)
        : '0';

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _lightGrey,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Performance Summary',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 8),
                _buildStatRow('Total Students', '$total'),
                _buildStatRow(
                  'Submitted',
                  '$totalSubmitted',
                  color: PdfColors.green700,
                ),
                _buildStatRow(
                  'Missing',
                  '$totalMissing',
                  color: PdfColors.orange700,
                ),
              ],
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Column(
              children: [
                pw.Text(
                  'Submission Rate',
                  style: pw.TextStyle(fontSize: 10, color: _textGrey),
                ),
                pw.SizedBox(height: 5),
                // FIX: Ensure Stack has a defined size context
                pw.SizedBox(
                  width: 60,
                  height: 60,
                  child: pw.Stack(
                    alignment: pw.Alignment.center,
                    children: [
                      pw.CircularProgressIndicator(
                        value: total > 0 ? totalSubmitted / total : 0,
                        color: _routeBlue,
                        backgroundColor: PdfColors.orange200,
                        strokeWidth: 6,
                      ),
                      pw.Text(
                        '$submittedPct%',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... _buildStatRow, _buildWorkshopSection (Same as before) ...
  pw.Widget _buildStatRow(String label, String value, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildWorkshopSection(WeeklyReportModel report) {
    final w = report.workshop;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Workshop Details'),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          context: null,
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            fontSize: 10,
          ),
          headerDecoration: const pw.BoxDecoration(color: _routeBlue),
          rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
          cellAlignment: pw.Alignment.center,
          cellStyle: const pw.TextStyle(fontSize: 10, color: _textGrey),
          cellPadding: const pw.EdgeInsets.all(5),
          headers: ['Topic', 'Date'],
          data: [
            [w.topic, DateFormat('dd/MM/yyyy').format(w.date)],
          ],
        ),
      ],
    );
  }

  // 🟢 NEW: Build a list of tables (one per group)
  List<pw.Widget> _buildGroupsTables(WeeklyReportModel report) {
    return report.groups.map((group) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Group Name Title
            pw.Text(
              group.groupName,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: _routeBlue,
              ),
            ),
            pw.SizedBox(height: 4),
            // The Table
            _buildGroupTable(group),
          ],
        ),
      );
    }).toList();
  }

  pw.Widget _buildGroupTable(GroupReportModel group) {
    return pw.TableHelper.fromTextArray(
      context: null,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(color: _routeBlue),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
      cellAlignment: pw.Alignment.center,
      cellStyle: const pw.TextStyle(fontSize: 10, color: _textGrey),
      cellPadding: const pw.EdgeInsets.all(5),
      headers: [
        'Assignment No.',
        'Assignment Name',
        'Submitted',
        'Unsubmitted',
        'Feedback',
        'Deadline',
      ],
      data: [
        [
          group.assignmentNumber,
          group.assignmentName,
          group.submittedCount.toString(),
          group.missingCount.toString(),
          group.feedbackDone ? 'Done' : 'Pending',
          group.deadline != null
              ? DateFormat('MMMM dd, yyyy').format(group.deadline!)
              : '-',
        ],
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: _lightGrey,
        borderRadius: pw.BorderRadius.only(
          bottomRight: pw.Radius.circular(4),
          topRight: pw.Radius.circular(4),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Container(width: 2, height: 24, color: _routeBlue),
          pw.SizedBox(width: 8),
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: _routeBlue,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '-';

    // 1. Create a dummy DateTime with the TimeOfDay values
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    // 2. Use intl to format it nicely (e.g., "10:30 AM")

    return DateFormat('h:mm a').format(dt);
  }

  pw.Widget _buildLogisticsSection(WeeklyReportModel report) {
    return pw.TableHelper.fromTextArray(
      context: null,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(color: _routeBlue),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
      cellAlignment: pw.Alignment.center,
      cellStyle: const pw.TextStyle(fontSize: 10, color: _textGrey),
      cellPadding: const pw.EdgeInsets.all(5),
      headers: ['Group', 'Attended', 'Arrival', 'Leave', 'Exception'],
      data: report.logistics
          .map(
            (info) => [
              info.groupName,
              info.visited ? 'Yes' : 'No',
              _formatTime(info.arrivalTime),
              _formatTime(info.leavingTime),
              info.exceptionReason ?? '-',
            ],
          )
          .toList(),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount} - Generated by Mentor Assistant',
        style: const pw.TextStyle(color: PdfColors.grey, fontSize: 8),
      ),
    );
  }
}
