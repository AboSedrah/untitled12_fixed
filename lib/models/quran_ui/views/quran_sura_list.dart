import 'dart:convert';
import 'dart:ui' as ui;

import 'package:fazkorony/widgets/easy_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fazkorony/models/quran_audio/quran_page_player_bloc.dart';
import 'package:fazkorony/core/constants.dart';
import 'package:fazkorony/core/hive_helper.dart';
import 'package:fazkorony/models/quran_ui/views/quran_details_page.dart';
import 'package:fazkorony/models/surah.dart';

import 'package:quran/quran.dart' as quran;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:group_list_view/group_list_view.dart';
import '../helpers/convert_number_to_ar.dart';
import 'package:string_validator/string_validator.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  bool isLoading = true;
  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    // overlays: SystemUiOverlay.values); // TODO: implement dispose
    super.dispose();
  }

  List pageNumbers = [];
  TextEditingController textEditingController = TextEditingController();
  var searchQuery = "";
  List<dynamic> surahList = [];
  List bookmarks = [];
  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300.withOpacity(.5),
          highlightColor: getValue("darkMode")
              ? darkModeSecondaryColor
              : quranPagesColorLight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.h),
            child: ListTile(
              leading: Container(
                width: 45,
                height: 45,
                color: backgroundColor, // Shimmer effect
              ),
              title: Container(
                height: 15,
                color: backgroundColor, // Shimmer effect
              ),
              subtitle: Container(
                height: 12,
                color: backgroundColor, // Shimmer effect
              ),
            ),
          ),
        );
      },
    );
  }

  final ItemScrollController _juzScrollController = ItemScrollController();

  Future<void> _loadSurahs() async {
    final String response = await rootBundle.loadString('assets/quran/json/surahs.json');
    final data = await json.decode(response);
    setState(() {
      surahList = data['surahs'];
      isLoading = false;
    });
  }

  int juzNumberLastRead = 0;

  // Define the tabs
  final List<Tab> tabs = const <Tab>[
    Tab(text: 'سورة'),
    Tab(text: 'جزء'),
    Tab(text: 'ربع'),
  ];
  var ayatFiltered;
  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();
  Set<String> starredVerses = {};

  Future<void> getStarredVerse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the data as a string, not as a map
    final String? savedData = prefs.getString("starredVerses");

    if (savedData != null) {
      // Decode the JSON string to a List<String>
      starredVerses = Set<String>.from(json.decode(savedData));
    }
    setState(() {});
  }

  Future<void> getJuzNumber() async {
    try {
      final rawLastRead = getValue("lastRead");
      int? lastRead;
      if (rawLastRead == null || rawLastRead == "non") {
        lastRead = null;
      } else if (rawLastRead is int) {
        lastRead = rawLastRead;
      } else {
        lastRead = int.tryParse(rawLastRead.toString());
      }

      if (lastRead != null && lastRead >= 1 && lastRead <= 604) {
        final pageData = quran.getPageData(lastRead);
        if (pageData.isNotEmpty) {
          // pageData[0] contains surah and start (ayah)
          juzNumberLastRead =
              quran.getJuzNumber(pageData[0]["surah"], pageData[0]["start"]);
        } else {
          juzNumberLastRead = 0;
        }
      } else {
        juzNumberLastRead = 0;
      }
    } catch (e) {
      juzNumberLastRead = 0;
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Defer heavy work until after first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // populate the filtered data with provided json data and stop loading shimmer
      await _loadSurahs();

      // load starred verses and juz number
      await getStarredVerse();
      await getJuzNumber();

      // attempt to load bookmarks from persisted storage if present
      try {
        final b = getValue("bookmarks");
        if (b != null && b is List) {
          bookmarks = List.from(b);
        }
      } catch (_) {}

      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: KeyboardDismissOnTap(
        dismissOnCapturedTaps: true,
        child: Container(
          decoration: BoxDecoration(
              color: getValue("darkMode")
                  ? quranPagesColorDark
                  : quranPagesColorLight),
          child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: getValue("darkMode")
                  ? quranPagesColorDark
                  : quranPagesColorLight,
              endDrawer: SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width * .7,
                  color: getValue("darkMode")
                      ? quranPagesColorDark
                      : quranPagesColorLight,
                  child: ListView(shrinkWrap: true, children: [
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        if (bookmarks.isNotEmpty)
                          ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: bookmarks.length,
                              itemBuilder: (c, i) {
                                return EasyContainer(
                                  borderRadius: 18,
                                  color: primaryColors[0].withOpacity(.05),
                                  onTap: () async {
                                    {
                                      await Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (builder) =>
                                                  BlocProvider(
                                                    create: (context) =>
                                                        QuranPagePlayerBloc(),
                                                    child: QuranDetailsPage(
                                                        shouldHighlightSura:
                                                            false,
                                                        pageNumber:
                                                            quran.getPageNumber(
                                                          int.parse(bookmarks[i]
                                                                  ["suraNumber"]
                                                              .toString()),
                                                          int.parse(bookmarks[i]
                                                                  ["verseNumber"]
                                                              .toString()),
                                                        ),
                                                        shouldHighlightText:
                                                            true,
                                                        highlightVerse:
                                                            quran.getVerse(
                                                          int.parse(bookmarks[i]
                                                                  ["suraNumber"]
                                                              .toString()),
                                                          int.parse(bookmarks[i]
                                                                  ["verseNumber"]
                                                              .toString()),
                                                        )),
                                                  )));
                                    }
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.bookmark,
                                              color: Color(int.parse(
                                                  "0x${bookmarks[i]["color"]}")),
                                            ),
                                            SizedBox(
                                              width: 20.w,
                                            ),
                                            Text(bookmarks[i]["name"],
                                                style: TextStyle(
                                                    fontFamily: "cairo",
                                                    fontSize: 14.sp,
                                                    color: getValue("darkMode")
                                                        ? Colors.white
                                                            .withOpacity(.87)
                                                        : primaryColors[0])),
                                          ],
                                        ),
                                        const Divider(),
                                        SizedBox(
                                          child: Text(
                                              quran.getVerse(
                                                int.parse(bookmarks[i]
                                                        ["suraNumber"]
                                                    .toString()),
                                                int.parse(bookmarks[i]
                                                        ["verseNumber"]
                                                    .toString()),
                                              ),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: fontFamilies[0],
                                                fontSize: 18.sp,
                                                color: getValue("darkMode")
                                                    ? Colors.white
                                                        .withOpacity(.87)
                                                    : primaryColors[0],
                                              )),
                                        ),
                                        const Divider(),
                                        Text(
                                          quran.getSurahNameArabic(int.parse(
                                              bookmarks[i]["suraNumber"]
                                                  .toString())),
                                          style: TextStyle(
                                              color: getValue("darkMode")
                                                  ? Colors.white
                                                      .withOpacity(.87)
                                                  : Colors.black87),
                                        ),
                                        Text(
                                            "${convertToArabicNumber(int.parse(bookmarks[i]["verseNumber"].toString()).toString())} " //               quran.getVerseEndSymbol()
                                            ,
                                            style: TextStyle(
                                                fontSize: 24.sp,
                                                color: Colors.blueAccent,
                                                fontFamily:
                                                    "KFGQPC Uthmanic Script HAFS Regular"))
                                      ],
                                    ),
                                  ),
                                );
                              }),
                      ],
                    ),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 8.0.h),
                      child: Text(
                        "الآيات المفضلة",
                        style: TextStyle(
                          color: getValue("darkMode")
                              ? Colors.white.withOpacity(.87)
                              : Colors.black,
                          fontSize: 18.sp,
                        ),
                      ),
                    )),
                    Center(
                      child: Icon(Icons.keyboard_arrow_down, size: 18.sp),
                    ),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: starredVerses
                          .map((e) => EasyContainer(
                              color: primaryColors[0].withOpacity(.05),
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (builder) => BlocProvider(
                                              create: (context) =>
                                                  QuranPagePlayerBloc(),
                                              child: QuranDetailsPage(
                                                  shouldHighlightSura: false,
                                                  pageNumber:
                                                      quran.getPageNumber(
                                                          int.parse(
                                                              e.split("-")[0]),
                                                          int.parse(
                                                              e.split("-")[1])),
                                                  shouldHighlightText: true,
                                                  highlightVerse:
                                                      quran.getVerse(
                                                          int.parse(
                                                              e.split("-")[0]),
                                                          int.parse(
                                                              e.split("-")[1]))),
                                            )));
                              },
                              child: Column(
                                children: [
                                  Text(
                                    quran.getVerse(int.parse(e.split("-")[0]),
                                        int.parse(e.split("-")[1])),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: fontFamilies[0],
                                      fontSize: 18.sp,
                                      color: getValue("darkMode")
                                          ? Colors.white.withOpacity(.87)
                                          : primaryColors[0],
                                    ),
                                  ),
                                  Text(
                                    quran.getSurahNameArabic(
                                        int.parse(e.split("-")[0])),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                      "${convertToArabicNumber((int.parse(e.split("-")[1]).toString()))} " //               quran.getVerseEndSymbol()
                                      ,
                                      style: TextStyle(
                                          fontSize: 24.sp,
                                          color: Colors.blueAccent,
                                          fontFamily:
                                              "KFGQPC Uthmanic Script HAFS Regular"))
                                ],
                              )))
                          .toList(),
                    )
                  ]),
                ),
              ),
              key: scaffoldKey,
              appBar: PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width.w, 80.h),
                child: AppBar(
                  actions: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.0.w, vertical: 8.h),
                      child: Builder(builder: (context) {
                        return IconButton(
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                            icon: const Icon(
                              Iconsax.bookmark,
                              color: backgroundColor,
                            ));
                      }),
                    )
                  ],
                  leading: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.h),
                    child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height * 0.04,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.04,
                      decoration: BoxDecoration(
                        color: Colors
                            .transparent, // Change this to your desired color
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TabBar(
                        indicatorPadding:
                            EdgeInsets.symmetric(horizontal: 20.w),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorColor: Colors.white,
                        indicatorWeight: 4,
                        tabs: tabs,
                        onTap: (index) {
                          // setState(() {
                          //   _currentIndex = index;
                          // });
                        },
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(16.r))),
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor:
                      getValue("darkMode") ? darkModeSecondaryColor : blueColor,
                  title: Text(
                    "القرآن الكريم",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              ),
              body: TabBarView(
                children: [
                  SafeArea(
                    child: Container(
                      color: getValue("darkMode")
                          ? quranPagesColorDark
                          : quranPagesColorLight,
                      child: Column(
                        children: [
                          // Safely parse and validate lastRead before using it
                          Builder(builder: (context) {
                            final rawLast = getValue("lastRead");
                            int? lastRead;
                            if (rawLast == null || rawLast == "non") {
                              lastRead = null;
                            } else if (rawLast is int) {
                              lastRead = rawLast;
                            } else {
                              lastRead = int.tryParse(rawLast.toString());
                            }

                            if (lastRead != null &&
                                lastRead >= 1 &&
                                lastRead <= 604) {
                              final int safeLastRead = lastRead;
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: EasyContainer(
                                    color: orangeColor,
                                    height: 60.h,
                                    padding: 0,
                                    margin: 0,
                                    borderRadius: 15.r,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.0.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "آخر قراءة",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          Text(
                                              "${quran.getSurahNameArabic(quran.getPageData(safeLastRead)[0]["surah"])} - $safeLastRead",
                                              style: const TextStyle(
                                                  color: Colors.white)),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 18,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    ),
                                    onTap: () async {
                                      await Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (builder) =>
                                                  BlocProvider(
                                                    create: (context) =>
                                                        QuranPagePlayerBloc(),
                                                    child: QuranDetailsPage(
                                                        shouldHighlightSura:
                                                            false,
                                                        pageNumber:
                                                            safeLastRead,
                                                        shouldHighlightText:
                                                            false,
                                                        highlightVerse: ""),
                                                  )));
                                      setState(() {});
                                    }),
                              );
                            }

                            return const SizedBox.shrink();
                          }),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0.w),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: goldColor.withOpacity(.05),
                                          borderRadius:
                                              BorderRadius.circular(12.r)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0.w),
                                              child: TextField(
                                                textDirection:
                                                    ui.TextDirection.rtl,
                                                controller:
                                                    textEditingController,
                                                onChanged: (value) {
                                                  setState(() {
                                                    searchQuery = value;
                                                  });
                                                  if (value == "") {
                                                    _loadSurahs();
                                                    pageNumbers = [];
                                                    setState(() {});
                                                  }

                                                  if (searchQuery.isNotEmpty &&
                                                      isInt(searchQuery)) {
                                                    pageNumbers.add(
                                                        toInt(searchQuery));
                                                  }
                                                  if (searchQuery.length > 3 ||
                                                      searchQuery
                                                          .toString()
                                                          .contains(" ")) {
                                                    setState(() {
                                                      ayatFiltered = [];
                                                      searchQuery = value;

                                                      ayatFiltered =
                                                          quran.searchWords(
                                                              searchQuery);
                                                      surahList = surahList
                                                          .where((sura) {
                                                        final suraName =
                                                            sura['name']
                                                                .toLowerCase();

                                                        return suraName.contains(
                                                                searchQuery
                                                                    .toLowerCase()) ||
                                                            quran
                                                                .getSurahNameArabic(
                                                                    sura[
                                                                        "number"])
                                                                .contains(
                                                                    searchQuery
                                                                        .toLowerCase());
                                                      }).toList();
                                                    });
                                                  }
                                                },
                                                style: TextStyle(
                                                    fontFamily: "aldahabi",
                                                    color: getValue("darkMode")
                                                        ? const Color.fromARGB(
                                                            228, 255, 255, 255)
                                                        : const Color.fromARGB(
                                                            190, 0, 0, 0)),
                                                cursorColor:
                                                    getValue("darkMode")
                                                        ? quranPagesColorDark
                                                        : quranPagesColorLight,
                                                decoration: InputDecoration(
                                                  hintText: 'ابحث في القرآن',
                                                  hintStyle: TextStyle(
                                                      fontFamily: "aldahabi",
                                                      color:
                                                          getValue("darkMode")
                                                              ? Colors.white70
                                                              : const Color
                                                                  .fromARGB(
                                                                  73, 0, 0, 0)),
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (searchQuery.isNotEmpty) {
                                                textEditingController.clear();
                                                pageNumbers.clear();
                                                setState(() {
                                                  searchQuery = "";
                                                });
                                              }
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: searchQuery.isNotEmpty
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Icon(Icons.close,
                                                            color: getValue(
                                                                    "darkMode")
                                                                ? Colors.white70
                                                                : const Color
                                                                    .fromARGB(
                                                                    73,
                                                                    0,
                                                                    0,
                                                                    0)),
                                                      ),
                                                    )
                                                  : Container(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Icon(
                                                            Icons.search,
                                                            color: getValue(
                                                                    "darkMode")
                                                                ? Colors.white70
                                                                : const Color
                                                                    .fromARGB(
                                                                    73,
                                                                    0,
                                                                    0,
                                                                    0)),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: isLoading
                                ? _buildShimmerLoading()
                                : ListView(
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    children: [
                                      if (pageNumbers.isNotEmpty)
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("صفحة"),
                                          ),
                                        ),
                                      ListView.separated(
                                          reverse: true,
                                          itemBuilder: (ctx, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: EasyContainer(
                                                color:
                                                    goldColor.withOpacity(.05),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      CupertinoPageRoute(
                                                          builder:
                                                              (builder) =>
                                                                  BlocProvider(
                                                                    create: (context) =>
                                                                        QuranPagePlayerBloc(),
                                                                    child: QuranDetailsPage(
                                                                        shouldHighlightSura:
                                                                            true,
                                                                        shouldHighlightText:
                                                                            false,
                                                                        highlightVerse:
                                                                            "",
                                                                        pageNumber:
                                                                            pageNumbers[index]),
                                                                  )));
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(pageNumbers[index]
                                                          .toString()),
                                                      Text(() {
                                                        final p =
                                                            pageNumbers[index];
                                                        final pageData = (p
                                                                    is int &&
                                                                p >= 1 &&
                                                                p <=
                                                                    quran
                                                                        .totalPagesCount)
                                                            ? quran
                                                                .getPageData(p)
                                                            : <dynamic>[];
                                                        return pageData
                                                                .isNotEmpty
                                                            ? quran.getSurahName(
                                                                pageData[0]
                                                                    ["surah"])
                                                            : "";
                                                      }())
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          separatorBuilder: (context, index) =>
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.0.w),
                                                child: Divider(
                                                  color: Colors.grey
                                                      .withOpacity(.5),
                                                ),
                                              ),
                                          itemCount: pageNumbers.length),
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        separatorBuilder: (context, index) =>
                                            Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0.w),
                                          child: Divider(
                                            color: Colors.grey.withOpacity(.5),
                                          ),
                                        ),
                                        itemCount: surahList.length,
                                        itemBuilder: (context, index) {
                                          int suraNumber = index + 1;
                                          String suraName = surahList[index]
                                              ["name"];
                                          String suraNameEnglishTranslated =
                                              surahList[index]
                                                  ["englishNameTranslation"];
                                          int suraNumberInQuran =
                                              surahList[index]["number"];
                                          int ayahCount =
                                              quran.getVerseCount(suraNumber);

                                          return Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: Container(
                                              child: ListTile(
                                                leading: Container(
                                                  width: 45,
                                                  height: 45,
                                                  decoration:
                                                      const BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                    image: AssetImage(
                                                      "assets/quran/images/sura_frame.png",
                                                    ),
                                                  )),
                                                  child: Center(
                                                    child: Text(
                                                      suraNumberInQuran
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: orangeColor,
                                                          fontSize: 14.sp),
                                                    ),
                                                  ),
                                                ) //  Material

                                                ,
                                                minVerticalPadding: 0,
                                                title: SizedBox(
                                                  width: 90.w,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        suraName,
                                                        style: TextStyle(
                                                            // fontWeight: FontWeight.bold,
                                                            color: getValue(
                                                                    "darkMode")
                                                                ? Colors.white70
                                                                : blueColor,
                                                            fontSize: 14.sp,
                                                            fontWeight: FontWeight
                                                                .w700, // Text color
                                                            fontFamily:
                                                                "uthmanic"),
                                                      ),
                                                      if (bookmarks
                                                              .indexWhere((a) {
                                                            return a
                                                                    .toString()
                                                                    .split(
                                                                        "-")[0] ==
                                                                "$suraNumberInQuran";
                                                          }) !=
                                                          -1)
                                                        Icon(Icons.bookmark,
                                                            size: 16.sp,
                                                            color: colorsOfBookmarks2[
                                                                    bookmarks
                                                                        .indexWhere(
                                                                            (a) {
                                                              return a
                                                                  .toString()
                                                                  .startsWith(
                                                                      "$suraNumberInQuran");
                                                            })]
                                                                .withOpacity(
                                                                    .7))
                                                    ],
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "$suraNameEnglishTranslated ($ayahCount)",
                                                  style: TextStyle(
                                                      fontFamily: "uthmanic",
                                                      fontSize: 14.sp,
                                                      color: Colors.grey
                                                          .withOpacity(.8)),
                                                ),
                                                trailing: RichText(
                                                  text: TextSpan(
                                                    text: "$suraNumber",
                                                    style: TextStyle(
                                                        // fontWeight: FontWeight.bold,
                                                        color: getValue(
                                                                "darkMode")
                                                            ? Colors.white70
                                                            : Colors
                                                                .black, //fontWeight: FontWeight.bold,
                                                        fontSize:
                                                            28.sp, // Text color
                                                        fontFamily: "arsura"),
                                                  ),
                                                ),
                                                onTap: () async {
                                                  await Navigator.push(
                                                      context,
                                                      CupertinoPageRoute(
                                                          builder: (builder) =>
                                                              BlocProvider(
                                                                create: (context) =>
                                                                    QuranPagePlayerBloc(),
                                                                child: QuranDetailsPage(
                                                                    shouldHighlightSura:
                                                                        true,
                                                                    shouldHighlightText:
                                                                        false,
                                                                    highlightVerse:
                                                                        "",
                                                                    pageNumber:
                                                                        quran.getPageNumber(
                                                                            suraNumberInQuran,
                                                                            1)),
                                                              )));
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      if (ayatFiltered != null) const Divider(),
                                      if (ayatFiltered != null)
                                        ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:
                                              ayatFiltered["occurences"] > 10
                                                  ? 10
                                                  : ayatFiltered["occurences"],
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: EasyContainer(
                                                color: getValue("darkMode")
                                                    ? darkModeSecondaryColor
                                                    : Colors.white70,
                                                borderRadius: 14,
                                                onTap: () async {
                                                  await Navigator.push(
                                                      context,
                                                      CupertinoPageRoute(
                                                          builder:
                                                              (builder) =>
                                                                  BlocProvider(
                                                                    create: (context) =>
                                                                        QuranPagePlayerBloc(),
                                                                    child: QuranDetailsPage(
                                                                        shouldHighlightSura:
                                                                            false,
                                                                        pageNumber: quran.getPageNumber(
                                                                            ayatFiltered["result"][index][
                                                                                "surah"],
                                                                            ayatFiltered["result"][index][
                                                                                "verse"]),
                                                                        shouldHighlightText:
                                                                            true,
                                                                        highlightVerse: quran.getVerse(
                                                                            ayatFiltered["result"][index]["surah"],
                                                                            ayatFiltered["result"][index]["verse"])),
                                                                  )));
                                                },
                                                child: Text(
                                                  "سورة ${quran.getSurahNameArabic(ayatFiltered["result"][index]["surah"])} - ${quran.getVerse(ayatFiltered["result"][index]["surah"], ayatFiltered["result"][index]["verse"], verseEndSymbol: true)}",
                                                  textDirection:
                                                      ui.TextDirection.rtl,
                                                  style: TextStyle(
                                                      color:
                                                          getValue("darkMode")
                                                              ? Colors.white
                                                              : Colors.black,
                                                      fontFamily: "uthmanic",
                                                      fontSize: 17.sp),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ScrollablePositionedList.builder(
                    itemCount: 30,
                    itemScrollController: _juzScrollController,
                    itemBuilder: (BuildContext context, index) {
                      return Card(
                        color: getValue("darkMode")
                            ? darkModeSecondaryColor.withOpacity(.8)
                            : quranPagesColorLight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                              title: Text(
                                quran.getSurahNameArabic(quran
                                    .getSurahAndVersesFromJuz(index + 1)
                                    .keys
                                    .first),
                                style: TextStyle(
                                    color: getValue("darkMode")
                                        ? const Color.fromARGB(
                                            234, 255, 255, 255)
                                        : const Color.fromARGB(228, 0, 0, 0)),
                              ),
                              subtitle: Text(
                                quran.getVerse(
                                    quran
                                        .getSurahAndVersesFromJuz(index + 1)
                                        .keys
                                        .first,
                                    quran
                                        .getSurahAndVersesFromJuz(index + 1)
                                        .values
                                        .first[0]),
                                style: TextStyle(
                                    fontFamily: "UthmanicHafs13",
                                    fontSize: 18.sp,
                                    color: getValue("darkMode")
                                        ? const Color.fromARGB(
                                            234, 255, 255, 255)
                                        : const Color.fromARGB(228, 0, 0, 0)),
                              ),
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (builder) => BlocProvider(
                                              create: (context) =>
                                                  QuranPagePlayerBloc(),
                                              child: QuranDetailsPage(
                                                  shouldHighlightSura: false,
                                                  shouldHighlightText: true,
                                                  highlightVerse: quran.getVerse(
                                                      quran
                                                          .getSurahAndVersesFromJuz(
                                                              index + 1)
                                                          .keys
                                                          .first,
                                                      quran
                                                          .getSurahAndVersesFromJuz(
                                                              index + 1)
                                                          .values
                                                          .first[0]),
                                                  pageNumber: quran.getPageNumber(
                                                      quran
                                                          .getSurahAndVersesFromJuz(
                                                              index + 1)
                                                          .keys
                                                          .first,
                                                      quran
                                                          .getSurahAndVersesFromJuz(
                                                              index + 1)
                                                          .values
                                                          .first[0])),
                                            )));
                                getJuzNumber();
                                setState(() {});
                              },
                              leading: Container(
                                width: 33.sp,
                                height: 33.sp,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: juzNumberLastRead == index + 1
                                      ? getValue("darkMode")
                                          ? quranPagesColorDark
                                          : quranPagesColorLight
                                      : getValue("darkMode")
                                          ? quranPagesColorDark
                                          : quranPagesColorLight.withOpacity(
                                              .1), // Replace with your logic
                                ),
                                child: Center(
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: getValue("darkMode")
                                            ? orangeColor
                                            : const Color.fromARGB(
                                                228, 0, 0, 0)),
                                  ),
                                ),
                              )),
                        ),
                      );
                    },
                  ),
                  GroupListView(
                    sectionsCount: 60,
                    countOfItemInSection: (int section) {
                      return 4;
                    },
                    itemBuilder: (BuildContext context, IndexPath index) {
                      return Card(
                        color: getValue("darkMode")
                            ? darkModeSecondaryColor.withOpacity(.8)
                            : quranPagesColorLight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(
                              quran.getSurahNameArabic(quarterList[
                                      indexes[index.section][index.index] - 1]
                                  ["surah"]),
                              style: TextStyle(
                                  color: getValue("darkMode")
                                      ? const Color.fromARGB(234, 255, 255, 255)
                                      : const Color.fromARGB(228, 0, 0, 0)),
                            ),
                            subtitle: Text(
                              quran.getVerse(
                                  quarterList[indexes[index.section]
                                          [index.index] -
                                      1]["surah"],
                                  quarterList[indexes[index.section]
                                          [index.index] -
                                      1]["ayah"]),
                              style: TextStyle(
                                  fontFamily: "UthmanicHafs13",
                                  fontSize: 18.sp,
                                  color: getValue("darkMode")
                                      ? const Color.fromARGB(234, 255, 255, 255)
                                      : const Color.fromARGB(228, 0, 0, 0)),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (builder) => BlocProvider(
                                            create: (context) =>
                                                QuranPagePlayerBloc(),
                                            child: QuranDetailsPage(
                                                shouldHighlightSura: false,
                                                shouldHighlightText: true,
                                                highlightVerse: quran.getVerse(
                                                    quarterList[indexes[index.section][index.index] - 1]
                                                        ["surah"],
                                                    quarterList[indexes[index.section][index.index] - 1]
                                                        ["ayah"]),
                                                pageNumber: quran.getPageNumber(
                                                    quarterList[indexes[index.section][index.index] - 1]
                                                        ["surah"],
                                                    quarterList[
                                                        indexes[index.section]
                                                                [index.index] -
                                                            1]["ayah"])),
                                          )));

                              setState(() {});
                            },
                            leading: SizedBox(
                              width: 33.sp,
                              height: 33.sp,
                              child: Container(),
                            ),
                          ),
                        ),
                      );
                    },
                    groupHeaderBuilder: (BuildContext context, int section) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: Text(
                          "حزب ${section + 1}",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: getValue("darkMode")
                                  ? const Color.fromARGB(234, 255, 255, 255)
                                  : const Color.fromARGB(228, 0, 0, 0)),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    sectionSeparatorBuilder: (context, section) =>
                        const SizedBox(height: 10),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
