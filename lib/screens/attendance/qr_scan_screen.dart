import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/database_provider.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});
  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  final _controller = MobileScannerController();
  bool _handled = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    for (final code in capture.barcodes) {
      final raw = code.rawValue;
      if (raw != null && raw.startsWith('member:')) {
        final id = int.tryParse(raw.substring(7));
        if (id == null) continue;
        _handled = true;
        try {
          final member = await ref.read(databaseProvider).membersDao.getById(id);
          await ref.read(attendanceActionsProvider).checkIn(id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ورود «${member.name}» ثبت شد')));
            context.pop();
          }
        } catch (_) {
          _handled = false;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('عضو یافت نشد')));
          }
        }
        return;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اسکن QR عضو')),
      body: Stack(children: [
        MobileScanner(controller: _controller, onDetect: _onDetect),
        Positioned(
          bottom: 24, left: 24, right: 24,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
            child: const Text('دوربین را روی کد QR کارت عضویت بگیرید',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}
