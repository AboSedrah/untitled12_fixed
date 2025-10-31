import 'package:flutter/material.dart';

class QuranEntryScreen extends StatefulWidget {
  const QuranEntryScreen({super.key});

  @override
  State<QuranEntryScreen> createState() => _QuranEntryScreenState();
}

class _QuranEntryScreenState extends State<QuranEntryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}


