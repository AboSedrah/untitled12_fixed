// ignore_for_file: must_be_immutable
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fazkorony/core/constants.dart';
import 'package:fazkorony/core/hive_helper.dart';
import 'package:fazkorony/models/quran_audio/player_bloc_bloc.dart';
import 'package:fazkorony/models/quran_audio/quran_page_player_bloc.dart';
import 'package:fazkorony/models/quran_ui/widgets/bismallah.dart';
import 'package:fazkorony/models/quran_ui/widgets/header_widget.dart';
import 'package:fazkorony/models/quran_ui/widgets/quran_page_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:screenshot/screenshot.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fazkorony/models/quran_ui/translation/translationdata.dart';
import 'package:fazkorony/services/quran_data_service.dart';
import 'package:provider/provider.dart';

class QuranDetailsPage extends StatefulWidget {
  final int pageNumber;
  final shouldHighlightText;
  final highlightVerse;
  bool shouldHighlightSura;
  // var highlighSurah;
  QuranDetailsPage(
      {super.key,
      required this.pageNumber,
      required this.shouldHighlightText,
      required this.highlightVerse,
      required this.shouldHighlightSura});

  @override
  State<QuranDetailsPage> createState() => QuranDetailsPageState();
}

class QuranDetailsPageState extends State<QuranDetailsPage> {
  late QuranDataService quranDataService;
  late QuranPagePlayerBloc quranPagePlayerBloc;
  late PlayerBlocBloc playerPageBloc;
  final ScrollController _scrollController = ScrollController();
  // var controller;
  final ItemScrollController itemScrollController = ItemScrollController();
// final ScrollOffsetController scrollOffsetController = ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
// final ScrollOffsetListener scrollOffsetListener = ScrollOffsetListener.create()

  // final bool _isScrolling = false;

  List bookmarks = [];
  void fetchBookmarks() {
    bookmarks = json.decode(getValue("bookmarks"));
    setState(() {});
    // print(bookmarks);
  }

  var dataOfCurrentTranslation;
  Future<void> getTranslationData() async {
    if (getValue("indexOfTranslationInVerseByVerse") > 1) {
      File file = File(
          "${appDir!.path}/${translationDataList[getValue("indexOfTranslationInVerseByVerse")].typeText}.json");

      String jsonData = await file.readAsString();
      dataOfCurrentTranslation = json.decode(jsonData);
    }
    setState(() {});
  }

  var currentVersePlaying;
  // late final ScrollController _controller;
  int index = 0;
  void setIndex() {
    setState(() {
      index = widget.pageNumber;
    });
  }

  double valueOfSlider = 0;

  late Timer timer;
  Directory? appDir;
  Future<void> initialize() async {
    appDir = await getTemporaryDirectory();
    getTranslationData();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> checkIfSelectHighlight() async {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (selectedSpan != "") {
        setState(() {
          selectedSpan = "";
        });
      }
    });
  }

  int playIndexPage = 0;

  @override
  void initState() {
    quranDataService = context.read<QuranDataService>();
    quranPagePlayerBloc = context.read<QuranPagePlayerBloc>();
    playerPageBloc = context.read<PlayerBlocBloc>();
    _pageController = PageController(initialPage: widget.pageNumber);
    fetchBookmarks();
    //var formatter = NumberFormat('', 'ar');print("ننتاا");
    initialize();
    getTranslationData();
    // reloadBookmarks();
    // verticalScrollController.addListener((event) {
    //   _handleCallbackEvent(event.direction, event.success);
    // });
    checkIfSelectHighlight();
    setIndex();

    changeHighlightSurah();
    // _model = ScrollListener.initialise(controller);

    highlightVerseFunction();
    _scrollController.addListener(_scrollListener);

    WakelockPlus.enable();
    updateValue("lastRead", widget.pageNumber);
    // addReciters(); // addValueToFontSize();
    // updateValue("quranPageolorsIndex", 0);
    super.initState();
  }

  // List<QuranPageReciter> reciters = [];
  // addReciters() {
  //   quran.getReciters().forEach((element) {
  //     // if(element.reciterName.contains(quran.getVerse(surahNumber, verseNumber).reciterName)){
  //     reciters.add(QuranPageReciter(
  //       identifier: element["identifier"],
  //       language: element["language"],
  //       name: element["name"],
  //       englishName: element["englishName"],
  //       format: element["format"],
  //       type: element["type"],
  //       direction: element["direction"],
  //     ));
  //   });
  // }

  void _scrollListener() {
    if (_scrollController.position.isScrollingNotifier.value &&
        selectedSpan != "") {
      setState(() {
        selectedSpan = "";
      });
    } else {}
  }

  var highlightVerse;
  var shouldHighlightText;
  Future<void> changeHighlightSurah() async {
    await Future.delayed(const Duration(seconds: 2));
    widget.shouldHighlightSura = false;
  }

  void highlightVerseFunction() {
    setState(() {
      shouldHighlightText = widget.shouldHighlightText;
    });
    if (widget.shouldHighlightText) {
      setState(() {
        highlightVerse = widget.highlightVerse;
      });

      Timer.periodic(const Duration(milliseconds: 400), (timer) {
        if (mounted) {
          setState(() {
            shouldHighlightText = false;
          });
        }
        Timer(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              shouldHighlightText = true;
            });
          }
          if (timer.tick == 4) {
            if (mounted) {
              setState(() {
                highlightVerse = "";

                shouldHighlightText = false;
              });
            }
            timer.cancel();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    WakelockPlus.disable();
    getTotalCharacters(quran.getVersesTextByPage(widget.pageNumber));
    super.dispose();
  }

  int total = 0;
  int total1 = 0;
  int total3 = 0;
  int getTotalCharacters(List<String> stringList) {
    total = 0;
    for (String str in stringList) {
      total += str.length;
    }
    // print(total);
    return total;
  }

  void checkIfAyahIsAStartOfSura() {}
  String? swipeDirection;
  late PageController _pageController;

  var english = RegExp(r'[a-zA-Z]');

  String selectedSpan = "";
  Result checkIfPageIncludesQuarterAndQuarterIndex(array, pageData, indexes) {
    for (int i = 0; i < array.length; i++) {
      int surah = array[i]['surah'];
      int ayah = array[i]['ayah'];
      for (int j = 0; j < pageData.length; j++) {
        int pageSurah = pageData[j]['surah'];
        int start = pageData[j]['start'];
        int end = pageData[j]['end'];
        if ((surah == pageSurah) && (ayah >= start) && (ayah <= end)) {
          int targetIndex = i + 1;
          for (int hizbIndex = 0; hizbIndex < indexes.length; hizbIndex++) {
            List<int> hizb = indexes[hizbIndex];
            for (int quarterIndex = 0;
                quarterIndex < hizb.length;
                quarterIndex++) {
              if (hizb[quarterIndex] == targetIndex) {
                return Result(true, i, hizbIndex, quarterIndex);
              }
            }
          }
        }
      }
    }
    return Result(false, -1, -1, -1);
  } //Create an instance of ScreenshotController

  ScreenshotController screenshotController = ScreenshotController();

  double currentHeight = 2.0;
  // double currentWordSpacing = 0.0;
  double currentLetterSpacing = 0.0;

  List<GlobalKey> richTextKeys = List.generate(
    604, // Replace with the number of pages in your PageView
    (_) => GlobalKey(),
  );
  // Cache fitted font sizes per page to avoid recomputing on every build
  final Map<int, double> _fittedFontSizes = {};
  // Cached verse positions per page (computed after layout)
  final Map<int, List<Map<String, dynamic>>> versePositions = {};
  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Helper to compute a fitted font size for a page so the content does not overflow.
    double fitFontSizeForPage(int pageIndex) {
      if (_fittedFontSizes.containsKey(pageIndex)) {
        return _fittedFontSizes[pageIndex]!;
      }

      // Safety: if pageIndex is out of range, return default
      if (pageIndex < 1 || pageIndex > quran.totalPagesCount) {
        return getValue("pageViewFontSize").toDouble();
      }

      // Build combined QCF text for the page (verses only). We add newlines to preserve wrapping.
      final pageData = quran.getPageData(pageIndex);
      final buffer = StringBuffer();
      for (final e in pageData) {
        for (var i = e["start"]; i <= e["end"]; i++) {
          // Keep spaces when measuring so wrapping in TextPainter matches
          // the actual rendered text. Removing spaces earlier caused
          // inconsistent line breaks between measurement and rendering.
          // Do NOT programmatically append the verse-end symbol here. The
          // per-page QCF font may already include the verse marker glyph,
          // and appending it in code can cause duplicated numbers.
          buffer
              .writeln(quran.getVerseQCF(e["surah"], i, verseEndSymbol: false));
        }
      }
      final combined = buffer.toString();

      // Compute available width and height for the text area. Subtract UI chrome/paddings.
      final contentWidth = (screenSize.width -
          (12.0.w * 2)); // left/right padding used in layout
      // Reserve space for header row and footer paddings; this is an approximation.
      final reservedHeight = 120.0.h; // header + some spacing
      final availableHeight = screenSize.height - reservedHeight;

      // Binary search font size between min and max (in logical pixels)
      double minFont = 12.0;
      double maxFont = 36.0;
      double best = getValue("pageViewFontSize").toDouble();

      while ((maxFont - minFont) > 0.5) {
        final mid = (minFont + maxFont) / 2;
        final span = TextSpan(
          text: combined,
          style: TextStyle(
            fontFamily: "QCF_P${pageIndex.toString().padLeft(3, "0")}",
            fontSize: mid,
            // Use slightly larger line height for page 1 and 2 to match
            // Mushaf-like vertical spacing seen in the attachments.
            height: (pageIndex == 1 || pageIndex == 2) ? 2.0 : 1.95,
            letterSpacing: 0,
          ),
        );
        final tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: ui.TextDirection.rtl,
          maxLines: null,
        );
        tp.layout(maxWidth: contentWidth);

        if (tp.height > availableHeight) {
          // Too tall, decrease font
          maxFont = mid;
        } else {
          // Fits, try bigger
          minFont = mid;
          best = mid;
        }
      }

      // Clamp best to sensible bounds and cache
      best = best.clamp(12.0, 36.0);
      _fittedFontSizes[pageIndex] = best;
      return best;
    }

    return Scaffold(
      key: scaffoldKey,
      endDrawer: SizedBox(
        height: screenSize.height,
        width: screenSize.width * .5,
      ),
      backgroundColor: Colors.transparent,
      body: PageView.builder(
        itemCount: quran.totalPagesCount + 1,
        controller: _pageController,
        onPageChanged: (a) {
          setState(() {
            index = a;
          });
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              color: const Color(0xffFFFCE7),
              child: Image.asset(
                "assets/quran/images/quran.jpg",
                fit: BoxFit.fill,
              ),
            );
          }
          return QuranPageWidget(
            pageNumber: index,
            quranDataService: quranDataService,
          );
        },
      ),
    );
  }

  void showSettingsSheet(BuildContext context) {}

  /// Compute on-screen start/end positions for each verse on [pageIndex].
  ///
  /// Returns a list of maps with keys:
  /// - 'surah', 'ayah' (int)
  /// - 'startRect' and 'endRect' (global Offset wrapped as Map {'dx':..., 'dy':...} via Offset.toString() or Offset itself)
  /// - 'startWord', 'endWord' (String)
  ///
  /// This relies on the rendered RichText available via [richTextKeys]. Call
  /// after frame render (e.g., in a post-frame callback) for the currently
  /// visible page.
  Future<List<Map<String, dynamic>>> computeVersePositions(
      int pageIndex) async {
    final List<Map<String, dynamic>> results = [];
    if (pageIndex < 1 || pageIndex > quran.totalPagesCount) return results;

    final int keyIndex = pageIndex - 1;
    if (keyIndex < 0 || keyIndex >= richTextKeys.length) return results;

    final ctx = richTextKeys[keyIndex].currentContext;
    if (ctx == null) return results;

    final renderObject = ctx.findRenderObject();
    if (renderObject == null) return results;

    // We expect a RenderParagraph somewhere in the render tree for the RichText.
    RenderParagraph? rp;
    if (renderObject is RenderParagraph) {
      rp = renderObject;
    } else {
      // Search descendants for a RenderParagraph
      void finder(RenderObject child) {
        if (rp != null) return;
        if (child is RenderParagraph) {
          rp = child;
          return;
        }
        child.visitChildren(finder);
      }

      renderObject.visitChildren(finder);
    }

    if (rp == null) return results;

    // Use the nearest RenderBox for coordinate conversion
    final RenderBox renderBox = renderObject is RenderBox
        ? renderObject
        : (ctx.findRenderObject() as RenderBox);

    // Build flattened verse text order the same way the RichText does and
    // compute start/end offsets for each verse in that flattened text.
    final pageData = quran.getPageData(pageIndex);
    int offset = 0;

    for (final e in pageData) {
      for (int i = e['start']; i <= e['end']; i++) {
        final String verseText =
            quran.getVerseQCF(e['surah'], i, verseEndSymbol: false) + ' ';
        final int start = offset;
        final int end = offset + verseText.length;
        offset = end;

        try {
          final boxes = rp!.getBoxesForSelection(
              TextSelection(baseOffset: start, extentOffset: end));

          if (boxes.isNotEmpty) {
            final firstRect = boxes.first.toRect();
            final lastRect = boxes.last.toRect();
            final Offset startGlobal =
                renderBox.localToGlobal(Offset(firstRect.left, firstRect.top));
            final Offset endGlobal = renderBox
                .localToGlobal(Offset(lastRect.right, lastRect.bottom));

            final words = verseText.trim().split(RegExp(r'\s+'));

            results.add({
              'surah': e['surah'],
              'ayah': i,
              'startOffset': start,
              'endOffset': end,
              'startRect': startGlobal,
              'endRect': endGlobal,
              'startWord': words.isNotEmpty ? words.first : '',
              'endWord': words.isNotEmpty ? words.last : '',
            });
          } else {
            results.add({
              'surah': e['surah'],
              'ayah': i,
              'startOffset': start,
              'endOffset': end,
              'startRect': null,
              'endRect': null,
              'startWord': '',
              'endWord': '',
            });
          }
        } catch (ex) {
          // If selection is out-of-range or other layout errors happen,
          // return a placeholder entry to preserve order.
          results.add({
            'surah': e['surah'],
            'ayah': i,
            'startOffset': start,
            'endOffset': end,
            'startRect': null,
            'endRect': null,
            'startWord': '',
            'endWord': '',
          });
        }
      }
    }

    // Cache and notify listeners
    versePositions[pageIndex] = results;
    if (mounted) setState(() {});
    return results;
  }

  void showAyahOptionsSheet(int index, int surah, int i) {}
}

class Result {
  bool includesQuarter;
  int index;
  int hizbIndex;
  int quarterIndex;

  Result(this.includesQuarter, this.index, this.hizbIndex, this.quarterIndex);
}
