// lib/services/juz_map.dart
// خريطة معيارية لبدايات الأجزاء (1..30). كل عنصر يمثل (سورة، آية) لبداية الجزء.
// المصدر: بدايات الأجزاء المعروفة في المصحف العثماني.

class _StartPoint {
  final int surah;
  final int ayah;
  const _StartPoint(this.surah, this.ayah);
}

class JuzMap {
  static const List<_StartPoint> _juzStarts = [
    _StartPoint(1, 1),   // 1
    _StartPoint(2, 142), // 2
    _StartPoint(2, 253), // 3
    _StartPoint(3, 92),  // 4
    _StartPoint(4, 24),  // 5
    _StartPoint(4, 148), // 6
    _StartPoint(5, 82),  // 7
    _StartPoint(6, 111), // 8
    _StartPoint(7, 88),  // 9
    _StartPoint(8, 41),  // 10
    _StartPoint(9, 93),  // 11
    _StartPoint(11, 6),  // 12
    _StartPoint(12, 53), // 13
    _StartPoint(15, 1),  // 14
    _StartPoint(17, 1),  // 15
    _StartPoint(18, 75), // 16
    _StartPoint(21, 1),  // 17
    _StartPoint(23, 1),  // 18
    _StartPoint(25, 21), // 19
    _StartPoint(27, 56), // 20
    _StartPoint(29, 46), // 21
    _StartPoint(33, 31), // 22
    _StartPoint(36, 28), // 23
    _StartPoint(39, 32), // 24
    _StartPoint(41, 47), // 25
    _StartPoint(46, 1),  // 26
    _StartPoint(51, 31), // 27
    _StartPoint(58, 1),  // 28
    _StartPoint(67, 1),  // 29
    _StartPoint(78, 1),  // 30
  ];

  static int juzOf(int surah, int ayah) {
    // أعثر على آخر بداية جزء <= (سورة، آية)
    int idx = 1;
    for (int i = 0; i < _juzStarts.length; i++) {
      final s = _juzStarts[i];
      if (_compare(surah, ayah, s) >= 0) {
        idx = i + 1;
      } else {
        break;
      }
    }
    return idx;
  }

  // مقارنة زوج (سورة، آية)
  static int _compare(int surah, int ayah, _StartPoint b) {
    if (surah != b.surah) return surah.compareTo(b.surah);
    return ayah.compareTo(b.ayah);
  }
}
