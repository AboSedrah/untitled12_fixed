import 'package:quran/quran.dart' as quran;

/// Helper that returns the verses for a given Mushaf page in reading order.
///
/// Each returned item is a map with keys: 'surah' (int), 'ayah' (int), 'text' (String).
List<Map<String, dynamic>> getVersesForPage(int page,
    {bool verseEndSymbol = false}) {
  final List<dynamic> pageData = quran.getPageData(page);
  final List<Map<String, dynamic>> result = [];

  if (pageData.isEmpty) return result;

  for (var i = 0; i < pageData.length; i++) {
    final segment = pageData[i];
    final int surah = segment['surah'];
    final int startAyah = segment['start'];

    // Determine end ayah for this segment: either before next segment start, or end of surah
    int endAyah;
    if (i + 1 < pageData.length) {
      final nextSegment = pageData[i + 1];
      endAyah = (nextSegment['start'] as int) - 1;
    } else {
      endAyah = quran.getVerseCount(surah);
    }

    for (int ay = startAyah; ay <= endAyah; ay++) {
      final String verseText =
          quran.getVerse(surah, ay, verseEndSymbol: verseEndSymbol);
      result.add({'surah': surah, 'ayah': ay, 'text': verseText});
    }
  }

  return result;
}
