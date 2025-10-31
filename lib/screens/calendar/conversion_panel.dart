import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/hijri_date.dart';
import '../../services/hijri_api.dart';

class ConversionPanel extends StatefulWidget {
  final HijriApi api;
  final DateTime initialG;

  const ConversionPanel({
    super.key,
    required this.api,
    required this.initialG,
  });

  @override
  State<ConversionPanel> createState() => _ConversionPanelState();
}

class _ConversionPanelState extends State<ConversionPanel> {
  late DateTime _gDate;
  HijriDate? _hDate;
  String? _error;

  @override
  void initState() {
    super.initState();
    _gDate = widget.initialG;
    _convertGtoH();
  }

  Future<void> _convertGtoH() async {
    try {
      final h = await widget.api.gToH(_gDate);
      setState(() {
        _hDate = h;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'فشل التحويل: $e');
    }
  }

  Future<void> _convertHtoG() async {
    if (_hDate == null) return;
    try {
      final g = await widget.api.hToG(_hDate!);
      setState(() {
        _gDate = g;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'فشل التحويل: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تحويل التاريخ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        if (_error != null)
          Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الميلادي:'),
                  Text(DateFormat.yMMMMd('ar').format(_gDate)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: _convertHtoG,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الهجري:'),
                  if (_hDate != null)
                    Text('${_hDate!.day} ${_hDate!.monthAr} ${_hDate!.year} هـ'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}