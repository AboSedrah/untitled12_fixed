import 'dart:async';
import 'package:fazkorony/widgets/easy_container.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart' as quran;
import 'package:fazkorony/core/hive_helper.dart';
import 'package:fazkorony/models/quran_ui/basmallah.dart';
import 'package:fazkorony/models/quran_ui/header_widget.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class QuranViewPage extends StatefulWidget {
  final int pageNumber;
  final dynamic jsonData;
  final dynamic shouldHighlightText;
  final dynamic highlightVerse;
  const QuranViewPage({
    super.key,
    required this.pageNumber,
    required this.jsonData,
    required this.shouldHighlightText,
    required this.highlightVerse,
  });

  @override
  State<QuranViewPage> createState() => _QuranViewPageState();
}

class _QuranViewPageState extends State<QuranViewPage> {
  var highlightVerse;
  var shouldHighlightText;
  List<GlobalKey> richTextKeys = List.generate(
    604, // Replace with the number of pages in your PageView
    (_) => GlobalKey(),
  );
  void setIndex() {
    setState(() {
      index = widget.pageNumber;
    });
  }

  int index = 0;
  late PageController _pageController;
  late Timer timer;
  String selectedSpan = "";

  Color? get quranPagesColor => null;

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
  void initState() {
    setIndex();
    _pageController = PageController(initialPage: index);
    highlightVerseFunction();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
// TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // timer.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
        body: PageView.builder(
      reverse: true,
      scrollDirection: Axis.horizontal,
      onPageChanged: (a) {
        setState(() {
          selectedSpan = "";
        });
        index = a;
        // print(index)  ;
      },
      controller: _pageController,
      // onPageChanged: _onPageChanged,
      itemCount: quran.totalPagesCount + 1,
      itemBuilder: (context, index) {
        // Precompute safe page data. quran.getPageData expects pages 1..totalPagesCount.
        final List pageData = (index >= 1 && index <= quran.totalPagesCount)
            ? quran.getPageData(index)
            : <dynamic>[];

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
            color: quranPagesColor,
          ),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0, left: 12),
                child: SingleChildScrollView(
                  // physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(
                        width: screenSize.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: (screenSize.width * .27),
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(
                                        Icons.arrow_back_ios,
                                        size: 24,
                                      )),
                                  Text(
                                      pageData.isNotEmpty
                                          ? widget.jsonData[
                                              pageData[0]["surah"] - 1]["name"]
                                          : "",
                                      style: const TextStyle(
                                          fontFamily: "Taha", fontSize: 14)),
                                ],
                              ),
                            ),
                            EasyContainer(
                              borderRadius: 12,
                              color: Colors.orange.withOpacity(.5),
                              showBorder: true,
                              height: 20,
                              width: 120,
                              padding: 0,
                              margin: 0,
                              child: Center(
                                child: Text(
                                  "${"page"} $index ",
                                  style: const TextStyle(
                                    fontFamily: 'aldahabi',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: (screenSize.width * .27),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.settings,
                                        size: 24,
                                      ))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      if ((index == 1 || index == 2))
                        SizedBox(
                          height: (screenSize.height * .15),
                        ),
                      const SizedBox(
                        height: 30,
                      ),
                      Directionality(
                          textDirection: TextDirection.rtl,
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: RichText(
                                key: richTextKeys[index - 1],
                                textDirection: TextDirection.rtl,
                                textAlign:
                                    (index == 1 || index == 2 || index > 570)
                                        ? TextAlign.center
                                        : TextAlign.center,
                                softWrap: true,
                                locale: const Locale("ar"),
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 23.sp.toDouble(),
                                  ),
                                  children: pageData.expand((e) {
                                    List<InlineSpan> spans = [];
                                    for (var i = e["start"];
                                        i <= e["end"];
                                        i++) {
                                      // Header
                                      if (i == 1) {
                                        spans.add(WidgetSpan(
                                          child: HeaderWidget(
                                              e: e, jsonData: widget.jsonData),
                                        ));
                                        if (index != 187 && index != 1) {
                                          spans.add(WidgetSpan(
                                            child: Basmallah(index: 0),
                                          ));
                                        }
                                        if (index == 187) {
                                          spans.add(WidgetSpan(
                                            child: Container(
                                              height: 10.h,
                                            ),
                                          ));
                                        }
                                      }

                                      // Verses
                                      spans.add(TextSpan(
                                        recognizer: LongPressGestureRecognizer()
                                          ..onLongPress = () {
                                            // showAyahOptionsSheet(
                                            //     index,
                                            //     e["surah"],
                                            //     i);
                                            print("longpressed");
                                          }
                                          ..onLongPressDown = (details) {
                                            setState(() {
                                              selectedSpan = " ${e["surah"]}$i";
                                            });
                                          }
                                          ..onLongPressUp = () {
                                            setState(() {
                                              selectedSpan = "";
                                            });
                                            print("finished long press");
                                          }
                                          ..onLongPressCancel =
                                              () => setState(() {
                                                    selectedSpan = "";
                                                  }),
                                        text: i == e["start"]
                                            ? "${quran.getVerse(e["surah"], i).replaceAll(" ", "").substring(0, 1)}\u200A${quran.getVerse(e["surah"], i).replaceAll(" ", "").substring(1)}"
                                            : quran
                                                .getVerse(e["surah"], i)
                                                .replaceAll(' ', ''),
                                        style: TextStyle(
                                          color: Colors.black,
                                          height: (index == 1 || index == 2)
                                              ? 2.h
                                              : 1.95.h,
                                          letterSpacing: 0.w,
                                          wordSpacing: 0,
                                          fontFamily:
                                              getValue("selectedFontFamily") ??
                                                  "UthmanicHafs13",
                                          fontSize: index == 1 || index == 2
                                              ? 28.sp
                                              : index == 145 || index == 201
                                                  ? index == 532 || index == 533
                                                      ? 22.5.sp
                                                      : 22.4.sp
                                                  : 23.1.sp,
                                          backgroundColor: Colors.transparent,
                                        ),
                                        children: const <TextSpan>[],
                                      ));
                                    }
                                    return spans;
                                  }).toList(),
                                ),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ); /* Your page content */
      },
    ));
  }
}
