// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fazkorony/core/constants.dart';
import 'package:fazkorony/core/hive_helper.dart';
import 'package:fazkorony/models/quran_audio/player_bloc_bloc.dart';
import 'package:fazkorony/models/quran_audio/quran_page_player_bloc.dart';
import 'package:fazkorony/models/quran_ui/widgets/bismallah.dart';
import 'package:fazkorony/models/quran_ui/widgets/header_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:screenshot/screenshot.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fazkorony/models/quran_ui/translation/translationdata.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuranDetailsPage extends StatefulWidget {
  final int pageNumber;
  final jsonData;
  final quarterJsonData;
  final shouldHighlightText;
  final highlightVerse;
  bool shouldHighlightSura;
  // var highlighSurah;
  QuranDetailsPage(
      {super.key,
      required this.pageNumber,
      required this.jsonData,
      required this.shouldHighlightText,
      required this.highlightVerse,
      required this.quarterJsonData,
      required this.shouldHighlightSura});

  @override
  State<QuranDetailsPage> createState() => QuranDetailsPageState();
}

class QuranDetailsPageState extends State<QuranDetailsPage> {
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
      body: Stack(
        children: [
          Builder(
            builder: (context2) {
              if (getValue("alignmentType") == "pageview") {
                return PageView.builder(
                  // physics: const CustomPageViewScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (a) {
                    setState(() {
                      selectedSpan = "";
                    });
                    index = a;
                    // Only persist lastRead for valid page numbers (1..totalPagesCount)
                    if (a >= 1 && a <= quran.totalPagesCount) {
                      updateValue("lastRead", a);
                    } else {
                      updateValue("lastRead", "non");
                    }
                  },
                  controller: _pageController,
                  // onPageChanged: _onPageChanged,
                  reverse: false,
                  itemCount: quran.totalPagesCount + 1,
                  itemBuilder: (context, index) {
                    // Note: page data is accessed directly via quran.getPageData(index)
                    // throughout the builder below. No local `pageData` is required here.
                    bool isEvenPage = index.isEven;

                    if (index == 0) {
                      return Container(
                        color: const Color(0xffFFFCE7),
                        child: Image.asset(
                          "assets/quran/images/quran.jpg",
                          fit: BoxFit.fill,
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                          color:
                              backgroundColors[getValue("quranPageolorsIndex")],
                          boxShadow: [
                            if (isEvenPage) // Add shadow only for even-numbered pages
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius:
                                    5, // Controls the spread of the shadow
                                blurRadius: 10, // Controls the blur effect
                                offset: const Offset(
                                    -5, 0), // Left side shadow for even numbers
                              ),
                          ],
                          //index % 2 == 0
                          border: Border.fromBorderSide(BorderSide(
                              color: (primaryColors[
                                      getValue("quranPageolorsIndex")] as Color)
                                  .withOpacity(.05)))),
                      child: Scaffold(
                        resizeToAvoidBottomInset: false,
                        backgroundColor: Colors.transparent,
                        body: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.only(right: 12.0.w, left: 12.w),
                            child: SingleChildScrollView(
                              // Disable vertical scrolling so each PageView page is fixed
                              physics: const NeverScrollableScrollPhysics(),
                              // keep controller for programmatic uses but prevent user scroll
                              controller: _scrollController,
                              child: Column(
                                children: [
                                  // Top header (surah name, page/juz info, settings)
                                  // Hidden by default. Will be shown on tap as a future
                                  // enhancement. Keep a small spacer so layout flows.
                                  SizedBox.shrink(),
                                  if ((index == 1 || index == 2))
                                    SizedBox(
                                      height: (screenSize.height * .15),
                                    ),
                                  BlocBuilder<QuranPagePlayerBloc,
                                          QuranPagePlayerState>(
                                      bloc: quranPagePlayerBloc,
                                      builder: (context, state) {
                                        if (state is QuranPagePlayerInitial ||
                                            state is QuranPagePlayerIdle) {
                                          return Directionality(
                                            textDirection: ui.TextDirection.rtl,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: RichText(
                                                  key: richTextKeys[index - 1],
                                                  textDirection:
                                                      ui.TextDirection.rtl,
                                                  textAlign: (index == 1 ||
                                                          index == 2 ||
                                                          index > 570)
                                                      ? TextAlign.center
                                                      : TextAlign.center,
                                                  softWrap: true,
                                                  locale: const Locale("ar"),
                                                  text: TextSpan(
                                                    style: TextStyle(
                                                      color: primaryColors[getValue(
                                                          "quranPageolorsIndex")],
                                                      fontSize: getValue(
                                                              "pageViewFontSize")
                                                          .toDouble(),
                                                      fontFamily:
                                                          "QCF_P${index.toString().padLeft(3, "0")}",
                                                    ),
                                                    locale: const Locale("ar"),
                                                    children: quran
                                                        .getPageData(index)
                                                        .expand((e) {
                                                      List<InlineSpan> spans =
                                                          [];
                                                      for (var i = e["start"];
                                                          i <= e["end"];
                                                          i++) {
                                                        // Header
                                                        if (i == 1) {
                                                          spans.add(WidgetSpan(
                                                            child: HeaderWidget(
                                                                e: e,
                                                                jsonData: widget
                                                                    .jsonData),
                                                          ));
                                                          if (index != 187) {
                                                            spans
                                                                .add(WidgetSpan(
                                                              child: Basmallah(
                                                                  index: getValue(
                                                                      "quranPageolorsIndex")),
                                                            ));
                                                          }
                                                          if (index == 187) {
                                                            spans
                                                                .add(WidgetSpan(
                                                              child: Container(
                                                                  height: 10.h),
                                                            ));
                                                          }
                                                        }

                                                        // Verses
                                                        spans.add(TextSpan(
                                                          recognizer:
                                                              LongPressGestureRecognizer()
                                                                ..onLongPress =
                                                                    () {
                                                                  showAyahOptionsSheet(
                                                                      index,
                                                                      e["surah"],
                                                                      i);
                                                                }
                                                                ..onLongPressDown =
                                                                    (details) {
                                                                  setState(() {
                                                                    selectedSpan =
                                                                        " ${e["surah"]}$i";
                                                                  });
                                                                }
                                                                ..onLongPressUp =
                                                                    () {
                                                                  setState(() {
                                                                    selectedSpan =
                                                                        " ";
                                                                  });
                                                                }
                                                                ..onLongPressCancel =
                                                                    () =>
                                                                        setState(
                                                                            () {
                                                                          selectedSpan =
                                                                              " ";
                                                                        }),
                                                          text:
                                                              quran.getVerseQCF(
                                                                  e["surah"], i,
                                                                  verseEndSymbol:
                                                                      false),
                                                          style: TextStyle(
                                                            color: bookmarks
                                                                    .where((element) =>
                                                                        element["suraNumber"] ==
                                                                            e[
                                                                                "surah"] &&
                                                                        element["verseNumber"] ==
                                                                            i)
                                                                    .isNotEmpty
                                                                ? Color(int.parse(
                                                                    "0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}"))
                                                                : primaryColors[
                                                                    getValue(
                                                                        "quranPageolorsIndex")],
                                                            height: (index ==
                                                                        1 ||
                                                                    index == 2)
                                                                ? 2.h
                                                                : 1.95.h,
                                                            letterSpacing: 0.w,
                                                            wordSpacing: 0,
                                                            fontFamily:
                                                                "QCF_P${index.toString().padLeft(3, "0")}",
                                                            fontSize:
                                                                fitFontSizeForPage(
                                                                    index),
                                                            backgroundColor:
                                                                shouldHighlightText
                                                                    ? quran.getVerse(e["surah"], i) ==
                                                                            widget
                                                                                .highlightVerse
                                                                        ? (highlightColors[getValue("quranPageolorsIndex")]
                                                                                as Color)
                                                                            .withOpacity(
                                                                                .25)
                                                                        : selectedSpan ==
                                                                                " ${e["surah"]}$i"
                                                                            ? (highlightColors[getValue("quranPageolorsIndex")] as Color).withOpacity(
                                                                                .25)
                                                                            : Colors
                                                                                .transparent
                                                                    : selectedSpan ==
                                                                            " ${e["surah"]}$i"
                                                                        ? (highlightColors[getValue("quranPageolorsIndex")]
                                                                                as Color)
                                                                            .withOpacity(
                                                                                .25)
                                                                        : Colors
                                                                            .transparent,
                                                          ),
                                                          children: const <TextSpan>[],
                                                        ));
                                                      }
                                                      return spans;
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else if (state
                                            is QuranPagePlayerPlaying) {
                                          return Directionality(
                                            textDirection: ui.TextDirection.rtl,
                                            child: StreamBuilder<Duration?>(
                                                stream: state.audioPlayerStream,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    final currentDuration =
                                                        snapshot.data!
                                                            .inMilliseconds;
                                                    if (currentDuration !=
                                                        state.durations[state
                                                                .durations
                                                                .length -
                                                            1]["endDuration"]) {
                                                      currentVersePlaying =
                                                          state.durations
                                                              .where((element) {
                                                        return (element[
                                                                    "startDuration"] <=
                                                                currentDuration &&
                                                            currentDuration <=
                                                                element[
                                                                    "endDuration"]);
                                                      }).first;
                                                    }

                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0.0),
                                                      child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: RichText(
                                                            key: richTextKeys[
                                                                index - 1],
                                                            textDirection: ui
                                                                .TextDirection
                                                                .rtl,
                                                            textAlign: (index ==
                                                                        1 ||
                                                                    index ==
                                                                        2 ||
                                                                    index > 570)
                                                                ? TextAlign
                                                                    .center
                                                                : TextAlign
                                                                    .center,
                                                            softWrap:
                                                                true, //locale: const Locale("ar"),
                                                            locale:
                                                                const Locale(
                                                                    "ar"),
                                                            text: TextSpan(
                                                              style: TextStyle(
                                                                color: primaryColors[
                                                                    getValue(
                                                                        "quranPageolorsIndex")], //wordSpacing: -.3,
                                                                fontSize: getValue(
                                                                        "pageViewFontSize")
                                                                    .toDouble() //.sp
                                                                ,
                                                                // Match the same QCF font for this page so
                                                                // highlights and measurements stay consistent.
                                                                fontFamily:
                                                                    "QCF_P${index.toString().padLeft(3, "0")}",
                                                              ),
                                                              locale:
                                                                  const Locale(
                                                                      "ar"),
                                                              children: quran
                                                                  .getPageData(
                                                                      index)
                                                                  .expand((e) {
                                                                List<InlineSpan>
                                                                    spans = [];
                                                                for (var i = e[
                                                                        "start"];
                                                                    i <=
                                                                        e["end"];
                                                                    i++) {
                                                                  // Header
                                                                  if (i == 1) {
                                                                    spans.add(
                                                                        WidgetSpan(
                                                                      child: HeaderWidget(
                                                                          e: e,
                                                                          jsonData:
                                                                              widget.jsonData),
                                                                    ));

                                                                    if (index !=
                                                                            187 &&
                                                                        index !=
                                                                            1) {
                                                                      spans.add(
                                                                          WidgetSpan(
                                                                              child: Basmallah(
                                                                        index: getValue(
                                                                            "quranPageolorsIndex"),
                                                                      )));
                                                                    }
                                                                    if (index ==
                                                                        187) {
                                                                      spans.add(
                                                                          WidgetSpan(
                                                                              child: Container(
                                                                        height:
                                                                            10.h,
                                                                      )));
                                                                    }
                                                                  }

                                                                  // Verses
                                                                  spans.add(
                                                                      TextSpan(
                                                                    locale:
                                                                        const Locale(
                                                                            "ar"),
                                                                    recognizer:
                                                                        LongPressGestureRecognizer()
                                                                          ..onLongPress =
                                                                              () {
                                                                            showAyahOptionsSheet(
                                                                                index,
                                                                                e["surah"],
                                                                                i);
                                                                          }
                                                                          ..onLongPressDown =
                                                                              (details) {
                                                                            setState(() {
                                                                              selectedSpan = " ${e["surah"]}$i";
                                                                            });
                                                                          }
                                                                          ..onLongPressUp =
                                                                              () {
                                                                            setState(() {
                                                                              selectedSpan = "";
                                                                            });
                                                                          }
                                                                          ..onLongPressCancel = () =>
                                                                              setState(() {
                                                                                selectedSpan = "";
                                                                              }),
                                                                    text: quran.getVerseQCF(
                                                                        e[
                                                                            "surah"],
                                                                        i,
                                                                        verseEndSymbol:
                                                                            false),
                                                                    style:
                                                                        TextStyle(
                                                                      color: primaryColors[
                                                                          getValue(
                                                                              "quranPageolorsIndex")],
                                                                      height: (index == 1 ||
                                                                              index ==
                                                                                  2)
                                                                          ? 2.h
                                                                          : 1.95
                                                                              .h,
                                                                      letterSpacing:
                                                                          0.w,
                                                                      fontFamily:
                                                                          "QCF_P${index.toString().padLeft(3, "0")}",
                                                                      fontSize:
                                                                          fitFontSizeForPage(
                                                                              index),
                                                                      backgroundColor: bookmarks
                                                                              .where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i)
                                                                              .isNotEmpty
                                                                          ? Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")).withOpacity(.19)
                                                                          : (i == currentVersePlaying["verseNumber"] && e["surah"] == state.suraNumber)
                                                                              ? (highlightColors[getValue("quranPageolorsIndex")] as Color).withOpacity(.28)
                                                                              : shouldHighlightText
                                                                                  ? quran.getVerse(e["surah"], i) == widget.highlightVerse
                                                                                      ? (highlightColors[getValue("quranPageolorsIndex")] as Color).withOpacity(.25)
                                                                                      : selectedSpan == " ${e["surah"]}$i"
                                                                                          ? (highlightColors[getValue("quranPageolorsIndex")] as Color).withOpacity(.25)
                                                                                          : Colors.transparent
                                                                                  : selectedSpan == " ${e["surah"]}$i"
                                                                                      ? (highlightColors[getValue("quranPageolorsIndex")] as Color).withOpacity(.25)
                                                                                      : Colors.transparent,
                                                                    ),
                                                                    children: const [],
                                                                  ));
                                                                  if (bookmarks
                                                                      .where((element) =>
                                                                          element["suraNumber"] ==
                                                                              e[
                                                                                  "surah"] &&
                                                                          element["verseNumber"] ==
                                                                              i)
                                                                      .isNotEmpty) {
                                                                    spans.add(WidgetSpan(
                                                                        alignment: PlaceholderAlignment.middle,
                                                                        child: Icon(
                                                                          Icons
                                                                              .bookmark,
                                                                          color:
                                                                              Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
                                                                        )));
                                                                  }
                                                                }
                                                                return spans;
                                                              }).toList(),
                                                            ),
                                                          )),
                                                    );
                                                  } else {
                                                    return Directionality(
                                                      textDirection:
                                                          ui.TextDirection.rtl,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.0),
                                                        child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child: RichText(
                                                              key: richTextKeys[
                                                                  index - 1],
                                                              textDirection: ui
                                                                  .TextDirection
                                                                  .rtl,
                                                              textAlign: (index ==
                                                                          1 ||
                                                                      index ==
                                                                          2 ||
                                                                      index >
                                                                          570)
                                                                  ? TextAlign
                                                                      .center
                                                                  : TextAlign
                                                                      .center,
                                                              softWrap:
                                                                  true, //locale: const Locale("ar"),
                                                              locale:
                                                                  const Locale(
                                                                      "ar"),
                                                              text: TextSpan(
                                                                style:
                                                                    TextStyle(
                                                                  color: primaryColors[
                                                                      getValue(
                                                                          "quranPageolorsIndex")], //wordSpacing: -.3,
                                                                  fontSize: getValue(
                                                                          "pageViewFontSize")
                                                                      .toDouble() //.sp
                                                                  ,
//
                                                                  fontFamily:
                                                                      getValue(
                                                                          "selectedFontFamily"),
                                                                ),
                                                                locale:
                                                                    const Locale(
                                                                        "ar"),
                                                                children: quran
                                                                    .getPageData(
                                                                        index)
                                                                    .expand(
                                                                        (e) {
                                                                  List<InlineSpan>
                                                                      spans =
                                                                      [];
                                                                  for (var i = e[
                                                                          "start"];
                                                                      i <=
                                                                          e["end"];
                                                                      i++) {
                                                                    // Header
                                                                    if (i ==
                                                                        1) {
                                                                      spans.add(
                                                                          WidgetSpan(
                                                                        child: HeaderWidget(
                                                                            e: e,
                                                                            jsonData: widget.jsonData),
                                                                      ));

                                                                      if (index !=
                                                                              187 &&
                                                                          index !=
                                                                              1) {
                                                                        spans.add(WidgetSpan(
                                                                            child: Basmallah(
                                                                          index:
                                                                              getValue("quranPageolorsIndex"),
                                                                        )));
                                                                      }
                                                                      if (index ==
                                                                          187) {
                                                                        spans.add(WidgetSpan(
                                                                            child: Container(
                                                                          height:
                                                                              10.h,
                                                                        )));
                                                                      }
                                                                    }

                                                                    // Verses
                                                                    spans.add(
                                                                        TextSpan(
                                                                      locale: const Locale(
                                                                          "ar"),
                                                                      recognizer:
                                                                          LongPressGestureRecognizer()
                                                                            ..onLongPress =
                                                                                () {
                                                                              showAyahOptionsSheet(index, e["surah"], i);
                                                                            }
                                                                            ..onLongPressDown =
                                                                                (details) {
                                                                              setState(() {
                                                                                selectedSpan = " ${e["surah"]}$i";
                                                                              });
                                                                            }
                                                                            ..onLongPressUp =
                                                                                () {
                                                                              setState(() {
                                                                                selectedSpan = "";
                                                                              });
                                                                            }
                                                                            ..onLongPressCancel = () =>
                                                                                setState(() {
                                                                                  selectedSpan = "";
                                                                                }),
                                                                      text: quran.getVerseQCF(
                                                                          e[
                                                                              "surah"],
                                                                          i,
                                                                          verseEndSymbol:
                                                                              false),
                                                                      style:
                                                                          TextStyle(
                                                                        color: primaryColors[
                                                                            getValue("quranPageolorsIndex")],
// letterSpacing: .05,
                                                                        height: (index == 1 ||
                                                                                index == 2)
                                                                            ? 2.h
                                                                            : 1.95.h,
                                                                        letterSpacing:
                                                                            0.w,
                                                                        // fontSize: 22.sp,
                                                                        // wordSpacing: -1.4,
                                                                        fontFamily:
                                                                            "QCF_P${index.toString().padLeft(3, "0")}",
                                                                        fontSize:
                                                                            fitFontSizeForPage(index),
                                                                        backgroundColor: bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).isNotEmpty
                                                                            ? Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")).withOpacity(.19)
                                                                            : shouldHighlightText
                                                                                ? quran.getVerse(e["surah"], i) == widget.highlightVerse
                                                                                    ? (highlightColors[getValue("quranPageolorsIndex")] as Color).withOpacity(.25)
                                                                                    : selectedSpan == " ${e["surah"]}$i"
                                                                                        ? (highlightColors[getValue("quranPageolorsIndex")] as Color).withOpacity(.25)
                                                                                        : Colors.transparent
                                                                                : selectedSpan == " ${e["surah"]}$i"
                                                                                    ? (highlightColors[getValue("quranPageolorsIndex")] as Color).withOpacity(.25)
                                                                                    : Colors.transparent,
                                                                      ),
                                                                      children: const [],
                                                                    ));
                                                                    if (bookmarks
                                                                        .where((element) =>
                                                                            element["suraNumber"] == e["surah"] &&
                                                                            element["verseNumber"] ==
                                                                                i)
                                                                        .isNotEmpty) {
                                                                      spans.add(WidgetSpan(
                                                                          alignment: PlaceholderAlignment.middle,
                                                                          child: Icon(
                                                                            Icons.bookmark,
                                                                            color:
                                                                                Color(int.parse("0x${bookmarks.where((element) => element["suraNumber"] == e["surah"] && element["verseNumber"] == i).first["color"]}")),
                                                                          )));
                                                                    }
                                                                  }
                                                                  return spans;
                                                                }).toList(),
                                                              ),
                                                            )),
                                                      ),
                                                    );
                                                  }
                                                }),
                                          );
                                        }
                                        return Container();
                                      })
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          )
        ],
      ),
    );
  }

  void showSettingsSheet(BuildContext context) {}

  void showAyahOptionsSheet(int index, int surah, int i) {}
}

class Result {
  bool includesQuarter;
  int index;
  int hizbIndex;
  int quarterIndex;

  Result(this.includesQuarter, this.index, this.hizbIndex, this.quarterIndex);
}
