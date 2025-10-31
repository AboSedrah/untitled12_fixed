import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:fazkorony/models/quran_ui/views/quran_details_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fazkorony/models/quran_audio/quran_page_player_bloc.dart';

class QuranSurahListScreen extends StatefulWidget {
  const QuranSurahListScreen({super.key});

  @override
  State<QuranSurahListScreen> createState() => _QuranSurahListScreenState();
}

class _QuranSurahListScreenState extends State<QuranSurahListScreen> {
  int _surah = 1;
  final TextEditingController _ayahCtrl = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    // settings are available via provider where needed; no local reference required here
    return Scaffold(
      appBar: AppBar(title: const Text('القرآن الكريم')),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('السورة'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _surah,
                      items: List.generate(114, (i) => i + 1)
                          .map((n) =>
                              DropdownMenuItem(value: n, child: Text('$n')))
                          .toList(),
                      onChanged: (v) => setState(() => _surah = v ?? 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('الآية'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _ayahCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), hintText: '1'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.menu_book),
                label: const Text('فتح المصحف'),
                onPressed: () {
                  final ayah = int.tryParse(_ayahCtrl.text.trim()) ?? 1;
                  final pageNumber = quran.getPageNumber(_surah, ayah);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) => QuranPagePlayerBloc(),
                        child: QuranDetailsPage(
                          pageNumber: pageNumber,
                          jsonData: [],
                          quarterJsonData: [],
                          shouldHighlightText: false,
                          highlightVerse: "",
                          shouldHighlightSura: false,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/quran_stats'),
                      icon: const Icon(Icons.bar_chart),
                      label: const Text('إحصاءات القرآن'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
