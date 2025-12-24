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

    // 1. Load Assets (Logo & Font) 📥
    // Loading Font is CRITICAL to fix the "Helvetica" error
    final fontData = await rootBundle.load('assets/fonts/OpenSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // Load Logo (Safe handling)
    String? logoSvg;
    try {
      logoSvg = await rootBundle.loadString('assets/images/route_logo.svg');
    } catch (_) {}

    // 2. Define Theme with the Custom Font 🎨
    final theme = pw.ThemeData.withFont(
      base: ttf,
      bold: ttf, // Use bold variant if you have it, otherwise regular serves
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
            _buildHeader(report, logoSvg),
            pw.SizedBox(height: 20),

            _buildSummarySection(report),
            pw.SizedBox(height: 20),

            _buildWorkshopSection(report),
            pw.SizedBox(height: 20),

            // Fix: Title separated from Grid to allow Grid to break pages
            _buildSectionTitle('Groups Performance'),
            pw.SizedBox(height: 10),

            // FIX: Use GridView instead of Wrap.
            // GridView supports spanning across multiple pages! 🚀
            _buildGroupsGrid(report),

            if (report.logistics.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Divider(color: _lightGrey, thickness: 1),
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
  pw.Widget _buildHeader(WeeklyReportModel report, String? logoSvg) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logoSvg != null)
          pw.Container(height: 40, width: 120, child: pw.SvgImage(svg: logoSvg))
        else
          pw.Text(
            "ROUTE",
            style: const pw.TextStyle(fontSize: 24, color: _routeBlue),
          ),

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Weekly Report Dashboard',
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
              'Mentor: Nourhan Gimaey',
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
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Topic: ${w.topic}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(w.date)}'),
            ],
          ),
        ),
      ],
    );
  }

  // 🔥 NEW: GridView instead of Wrap to fix the "Widget won't fit" error
  pw.Widget _buildGroupsGrid(WeeklyReportModel report) {
    return pw.GridView(
      crossAxisCount: 2, // 2 Columns
      childAspectRatio: 1.6, // Adjust ratio to fit card content
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: report.groups.map((g) => _buildGroupCard(g)).toList(),
    );
  }

  pw.Widget _buildGroupCard(GroupReportModel group) {
    // Keep your existing card design, it's good.
    // Ensure no "Expanded" is used inside here.
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _routeBlue, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            group.groupName,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: _routeBlue,
              fontSize: 11,
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                group.assignmentName,
                maxLines: 1,
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Task #${group.assignmentNumber}',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Sub: ${group.submittedCount}',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.green700),
              ),
              pw.Text(
                'Miss: ${group.missingCount}',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.orange700),
              ),
            ],
          ),
          if (group.feedbackDone)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.green100,
                borderRadius: pw.BorderRadius.circular(2),
              ),
              child: pw.Text(
                'Feedback Done',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.green800),
              ),
            ),
        ],
      ),
    );
  }

  // ... _buildLogisticsSection, _buildSectionTitle, _buildFooter (Same as before) ...
  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _routeBlue, width: 2)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: _routeBlue,
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '-';

    // 1. Create a dummy DateTime with the TimeOfDay values
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    // 2. Use intl to format it nicely (e.g., "10:30 AM")
    // 'jm' pattern gives "5:08 PM"
    // 'HH:mm' gives "17:08"
    return DateFormat('h:mm a').format(dt);
  }

  pw.Widget _buildLogisticsSection(WeeklyReportModel report) {
    return pw.TableHelper.fromTextArray(
      context: null,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: _routeBlue),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      cellAlignment: pw.Alignment.center,
      headers: ['Group', 'Visited', 'Arrival', 'Departure', 'Exceptions'],
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
