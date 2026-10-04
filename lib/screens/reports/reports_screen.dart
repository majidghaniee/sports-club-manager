import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart' as intl;
import '../../providers/attendance_provider.dart';
import '../../providers/payments_provider.dart';
import '../../providers/database_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();
  String _type = 'attendance';
  bool _busy = false;

  Future<void> _pick(bool isFrom) async {
    final d = await showDatePicker(context: context,
        initialDate: isFrom ? _from : _to,
        firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (d != null) setState(() => isFrom ? _from = d : _to = d);
  }

  Future<pw.Document> _buildPdf() async {
    final db = ref.read(databaseProvider);
    final fromS = toShamsi(_from), toS = toShamsi(_to);
    final settings = ref.read(clubSettingsProvider);
    final doc = pw.Document();
    final rows = <List<String>>[];
    String header;

    if (_type == 'attendance') {
      header = 'گزارش حضورغیاب';
      final items = await db.attendanceDao.range(fromS, toS);
      for (final a in items) {
        Member? m;
        try { m = await db.membersDao.getById(a.memberId); } catch (_) {}
        final inT = intl.DateFormat('HH:mm').format(a.checkIn);
        final outT = a.checkOut != null ? intl.DateFormat('HH:mm').format(a.checkOut!) : '—';
        rows.add([m?.name ?? '#${a.memberId}', a.date, inT, outT]);
      }
    } else {
      header = 'گزارش مالی (سرسیدها)';
      final items = await db.paymentsDao.range(fromS, toS);
      for (final p in items) {
        Member? m;
        try { m = await db.membersDao.getById(p.memberId); } catch (_) {}
        rows.add([
          m?.name ?? '#${p.memberId}', p.dueDate,
          intl.NumberFormat.decimalPattern().format(p.amount),
          p.isPaid ? 'پرداخت‌شده' : 'پرداخت‌نشده',
        ]);
      }
    }

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(base: await PdfGoogleFonts.vazirmatnRegular()),
      build: (context) => pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('${settings.clubName} — $header',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('بازه: از $fromS تا $toS'),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: _type == 'attendance'
                ? ['نام', 'تاریخ', 'ورود', 'خروج']
                : ['نام', 'سرسید', 'مبلغ', 'وضعیت'],
            data: rows,
          ),
        ]),
      ),
    ));
    return doc;
  }

  Future<void> _generate() async {
    setState(() => _busy = true);
    try {
      final doc = await _buildPdf();
      await Printing.layoutPdf(onLayout: (_) => doc.save());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final doc = await _buildPdf();
      final file = await Printing.sharePdf(
          bytes: await doc.save(),
          filename: _type == 'attendance' ? 'attendance_report.pdf' : 'payment_report.pdf');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = intl.DateFormat('yyyy/MM/dd');
    return Scaffold(
      appBar: AppBar(title: const Text('گزارشات')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'attendance', label: Text('حضورغیاب'), icon: Icon(Icons.fact_check)),
            ButtonSegment(value: 'payments', label: Text('مالی'), icon: Icon(Icons.payments)),
          ],
          selected: {_type},
          onSelectionChanged: (s) => setState(() => _type = s.first),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => _pick(true),
            icon: const Icon(Icons.date_range),
            label: Text('از: ${df.format(_from)}'))),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(
            onPressed: () => _pick(false),
            icon: const Icon(Icons.date_range),
            label: Text('تا: ${df.format(_to)}'))),
        ]),
        const SizedBox(height: 24),
        if (_busy) const Center(child: CircularProgressIndicator()),
        if (!_busy) ...[
          FilledButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.picture_as_pdf), label: const Text('ساخت و چاپ PDF')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _share,
            icon: const Icon(Icons.share), label: const Text('اشتراک‌گذاری PDF')),
        ],
      ]),
    );
  }
}
