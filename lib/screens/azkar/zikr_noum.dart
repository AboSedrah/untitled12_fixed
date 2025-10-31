import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fazkorony/services/dhikr_events.dart';

class ZikrNoumScreen
    extends StatelessWidget {
  final List<Zikr> azkar = const [
    Zikr(
      text:
          '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
﴿ قُلْ هُوَ اللَّهُ أَحَدٌ * اللَّهُ الصَّمَدُ * لَمْ يَلِدْ وَلَمْ يُولَدْ * وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ ﴾
(الإخلاص 1–4)
بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
﴿ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ * مِن شَرِّ مَا خَلَقَ * وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ * وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ * وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ ﴾
(الفلق 1–5)
بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
﴿ قُلْ أَعُوذُ بِرَبِّ النَّاسِ * مَلِكِ النَّاسِ * إِلَٰهِ النَّاسِ * مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ * الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ * مِنَ الْجِنَّةِ وَالنَّاسِ ﴾
(الناس 1–6)
ثم يمسح بهما ما استطاع من جسده، يبدأ بهما على رأسه ووجهه، وما أقبل من جسده (ثلاث مرات)''',
      repeat: 3,
    ),
    Zikr(
      text:
          '''أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ 
﴿ ٱللَّهُ لَا إِلَٰهَ إِلَّا هُوَ ٱلْحَيُّ ٱلْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُۥ مَا فِى ٱلسَّمَٰوَٰتِ وَمَا فِى ٱلْأَرْضِ ۗ مَن ذَا ٱلَّذِى يَشْفَعُ عِندَهُۥٓ إِلَّا بِإِذْنِهِۦ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَىْءٍۢ مِّنْ عِلْمِهِۦٓ إِلَّا بِمَا شَآءَ ۚ وَسِعَ كُرْسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلْأَرْضَ ۖ وَلَا يَئُودُهُُۥ حِفْظُهُمَا ۚ وَهُوَ ٱلْعَلِىُّ ٱلْعَظِيمُ ﴾
(البقرة 255)
آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِّن رُّسُلِهِ ۚ وَقَالُوا سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ. لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنتَ مَوْلَانَا فَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ ﴾
(البقرة 285-286)
من قرأهما في ليلة كفتاه (رواه البخاري ومسلم)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''بِاسْمِكَ رَبِّـي وَضَعْـتُ جَنْـبي ، وَبِكَ أَرْفَعُـه، فَإِنْ أَمْسَـكْتَ نَفْسـي فارْحَـمْها ، وَإِنْ أَرْسَلْتَـها فَاحْفَظْـها بِمـا تَحْفَـظُ بِه عِبـادَكَ الصّـالِحـينَ
(رواه البخاري ومسلم)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''اللّهُـمَّ إِنَّـكَ خَلَـقْتَ نَفْسـي وَأَنْـتَ تَوَفّـاهـا لَكَ ممَـاتـها وَمَحْـياها ، إِنْ أَحْيَيْـتَها فَاحْفَظْـها ، وَإِنْ أَمَتَّـها فَاغْفِـرْ لَـها . اللّهُـمَّ إِنَّـي أَسْـأَلُـكَ العـافِـيَة
(رواه مسلم)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''اللّهُـمَّ قِنـي عَذابَـكَ يَـوْمَ تَبْـعَثُ عِبـادَكَ
(رواه الترمذي)
ثلاث مرات''',
      repeat: 3,
    ),
    Zikr(
      text:
          '''بِاسْـمِكَ اللّهُـمَّ أَمـوتُ وَأَحْـيا
(رواه البخاري)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''سُبْحَانَ اللَّهِ (٣٣ مرة) 
الْحَمْدُ لِلَّهِ (٣٣ مرة) 
اللَّهُ أَكْبَرُ (٣٤ مرة)
(رواه مسلم)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''اللّهُـمَّ رَبَّ السَّمـواتِ وَرَبَّ الأَرْضِ وَرَبَّ العَـرْشِ العَظـيم، رَبَّـنا وَرَبَّ كُـلِّ شَـيءٍ، فالِـقَ الحَـبِّ وَالنَّـوى، وَمُنـزِلَ التَّـوراةِ وَالإِنجـيلِ وَالقُـرآنِ، أَعـوذُ بِكَ مِن شَـرِّ كُـلِّ شَـيءٍ أَنْـتَ آخِـذٌ بِناصِـيَتِه. اللّهُـمَّ أَنْـتَ الأَوَّـل فَلَيْـسَ قَبْلَـكَ شَـيء، وَأَنْـتَ الآخِـر فَلَيْـسَ بَعْـدَكَ شَـيء، وَأَنْـتَ الظّـاهِـر فَلَيْـسَ فَـوقَكَ شَـيء، وَأَنْـتَ الباطِـن فَلَيْـسَ دُونَكَ شَـيء. اِقْـضِ عَـنّـا الدَّيـنَ، وَأَغْـنِـنا مِنَ الفَقْـر
(رواه مسلم)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَكَفَانَا وَآوَانَا، فَكَمْ مِمَّنْ لَا كَافِيَ لَهُ وَلَا مُؤْوِي
(رواه مسلم)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ، فَاطِرَ السَّمَوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى نَفْسِي سُوءًا أَوْ أَجُرَّهُ إِلَى مُسْلِم
(رواه أبو داود)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَهْبَةً وَرَغْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ، آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ، وَنَبِيِّكَ الَّذِي أَرْسَلْتَ
قال صلى الله عليه وسلم لمن قال ذلك: "فإن متَّ من ليلتك متَّ على الفطرة" (رواه البخاري)''',
      repeat: 1,
    ),
    Zikr(
      text: '''الدعاء إذا تقلب ليلاً:
لَا إِلَهَ إِلَّا اللَّهُ الْوَاحِدُ الْقَهَّارُ، رَبُّ السَّمَوَاتِ وَالْأَرْضِ وَمَا بَيْنَهُمَا الْعَزِيزُ الْغَفَّار''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''دعاء القلق والفزع في النوم ومن تخوف الوحشة:
أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ غَضَبِهِ وَعِقَابِهِ، وَشَرِّ عِبَادِهِ، وَمِنْ هَمَزَاتِ الشَّيَاطِينِ وَأَنْ يَحْضُرُون''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''ما يفعل من رأى الرؤيا أو الحلم:
1. ينفث عن يساره (ثلاث مرات)
2. يستعيذ بالله من الشيطان ومن شر ما رأى (ثلاث مرات)
3. لا يحدث بها أحداً
4. يتحول عن جنبه الذي كان عليه
5. يقوم يصلي إن أراد ذلك''',
      repeat: 1,
    ),
  ];

  const ZikrNoumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('أذكار النوم'),
        backgroundColor:
            Colors.deepPurple[700],
      ),
      body: ListView.builder(
        itemCount: azkar.length,
        itemBuilder: (context, index) {
          return ZikrCard(
              zikr: azkar[index]);
        },
      ),
    );
  }
}

class Zikr {
  final String text;
  final int repeat;

  const Zikr(
      {required this.text,
      required this.repeat});
}

class ZikrCard extends StatefulWidget {
  final Zikr zikr;

  const ZikrCard(
      {super.key, required this.zikr});

  @override
  _ZikrCardState createState() =>
      _ZikrCardState();
}

class _ZikrCardState
    extends State<ZikrCard> {
  int counter = 0;

  void incrementCounter() {
    setState(() {
      counter++;
    });
    DhikrEvents.recordRead(context, category: 'noum');
  }

  void resetCounter() {
    setState(() {
      counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: incrementCounter,
      onLongPress: resetCounter,
      child: Card(
        margin:
            const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(
              16.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                widget.zikr.text,
                textAlign:
                    TextAlign.right,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(
                  height: 16),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                            Icons.share,
                            color: Colors
                                .orange),
                        onPressed: () =>
                            Share.share(
                                widget
                                    .zikr
                                    .text),
                      ),
                      IconButton(
                        icon: const Icon(
                            Icons
                                .do_not_disturb,
                            color: Colors
                                .grey),
                        onPressed:
                            resetCounter,
                        tooltip:
                            'إعادة العداد',
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                            Icons
                                .add_circle_outline,
                            color: Colors
                                .deepPurple),
                        onPressed:
                            incrementCounter,
                        iconSize: 28,
                      ),
                      Container(
                        padding: const EdgeInsets
                            .symmetric(
                            horizontal:
                                12,
                            vertical:
                                6),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .deepPurple[50],
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '$counter',
                              style:
                                  const TextStyle(
                                fontSize:
                                    18,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors
                                    .deepPurple,
                              ),
                            ),
                            if (widget
                                    .zikr
                                    .repeat >
                                0)
                              Padding(
                                padding: const EdgeInsets
                                    .only(
                                    right:
                                        4),
                                child:
                                    Text(
                                  ' / ${widget.zikr.repeat}',
                                  style:
                                      TextStyle(
                                    fontSize:
                                        14,
                                    color:
                                        Colors.grey[600],
                                    fontStyle:
                                        FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
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
