import 'package:fazkorony/widgets/easy_container.dart';
import 'package:flutter/material.dart';

class QuranPage extends StatefulWidget {
  final suraJsonData;

  const QuranPage({super.key, required this.suraJsonData});

  @override
  _QuranPageState createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.suraJsonData['name']),
              background: Image.asset(
                'assets/quran/images/quran.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: EasyContainer(
              padding: 10,
              child: Text(
                widget.suraJsonData['verses'].join('\n'),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  height: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}