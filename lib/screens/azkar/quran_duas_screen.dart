import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class QuranDuasScreen
    extends StatelessWidget {
  final List<Dua> duas = const [
    Dua(
      text:
          "رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ",
      reference: "البقرة – آية 127",
    ),
    Dua(
      text:
          "رَبَّنَا وَاجْعَلْنَا مُسْلِمَيْنِ لَكَ وَمِن ذُرِّيَّتِنَا أُمَّةً مُّسْلِمَةً لَّكَ وَأَرِنَا مَنَاسِكَنَا وَتُبْ عَلَيْنَا ۖ إِنَّكَ أَنتَ التَّوَّابُ الرَّحِيمُ",
      reference: "البقرة – آية 128",
    ),
    Dua(
      text:
          "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
      reference: "البقرة – آية 201",
    ),
    Dua(
      text:
          "رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ",
      reference: "البقرة – آية 250",
    ),
    Dua(
      text:
          "رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنتَ مَوْلَانَا فَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ",
      reference: "البقرة – آية 286",
    ),
    Dua(
      text:
          "رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً ۚ إِنَّكَ أَنتَ الْوَهَّابُ",
      reference: "آل عمران – آية 8",
    ),
    Dua(
      text:
          "رَبَّنَا إِنَّنَا آمَنَّا فَاغْفِرْ لَنَا ذُنُوبَنَا وَقِنَا عَذَابَ النَّارِ",
      reference: "آل عمران – آية 16",
    ),
    Dua(
      text:
          "رَبِّ هَبْ لِي مِن لَّدُنكَ ذُرِّيَّةً طَيِّبَةً ۖ إِنَّكَ سَمِيعُ الدُّعَاءِ",
      reference: "آل عمران – آية 38",
    ),
    Dua(
      text:
          "رَبَّنَا آمَنَّا بِمَا أَنزَلْتَ وَاتَّبَعْنَا الرَّسُولَ فَاكْتُبْنَا مَعَ الشَّاهِدِينَ",
      reference: "آل عمران – آية 53",
    ),
    Dua(
      text:
          "رَبَّنَا اغْفِرْ لَنَا ذُنُوبَنَا وَإِسْرَافَنَا فِي أَمْرِنَا وَثَبِّتْ أَقْدَامَنَا وَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ",
      reference: "آل عمران – آية 147",
    ),
    Dua(
      text:
          "رَبَّنَا مَا خَلَقْتَ هَٰذَا بَاطِلًا سُبْحَانَكَ فَقِنَا عَذَابَ النَّارِ",
      reference: "آل عمران – آية 191",
    ),
    Dua(
      text:
          "رَبَّنَا إِنَّكَ مَن تُدْخِلِ النَّارَ فَقَدْ أَخْزَيْتَهُ ۖ وَمَا لِلظَّالِمِينَ مِنْ أَنْصَارٍ",
      reference: "آل عمران – آية 192",
    ),
    Dua(
      text:
          "رَبَّنَا إِنَّنَا سَمِعْنَا مُنَادِيًا يُنَادِي لِلْإِيمَانِ أَنْ آمِنُوا بِرَبِّكُمْ فَآمَنَّا ۚ رَبَّنَا فَاغْفِرْ لَنَا ذُنُوبَنَا وَكَفِّرْ عَنَّا سَيِّئَاتِنَا وَتَوَفَّنَا مَعَ الْأَبْرَارِ",
      reference: "آل عمران – آية 193",
    ),
    Dua(
      text:
          "رَبَّنَا وَآتِنَا مَا وَعَدتَّنَا عَلَىٰ رُسُلِكَ وَلَا تُخْزِنَا يَوْمَ الْقِيَامَةِ ۗ إِنَّكَ لَا تُخْلِفُ الْمِيعَادَ",
      reference: "آل عمران – آية 194",
    ),
    Dua(
      text:
          "رَبِّ إِنِّي أَعُوذُ بِكَ أَن أَسْأَلَكَ مَا لَيْسَ لِي بِهِ عِلْمٌ وَإِلَّا تَغْفِرْ لِي وَتَرْحَمْنِي أَكُن مِّنَ الْخَاسِرِينَ",
      reference: "هود – آية 47",
    ),
    Dua(
      text:
          "رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ",
      reference: "إبراهيم – آية 40",
    ),
    Dua(
      text:
          "رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ",
      reference: "إبراهيم – آية 41",
    ),
    Dua(
      text:
          "رَبِّ أَدْخِلْنِي مُدْخَلَ صِدْقٍ وَأَخْرِجْنِي مُخْرَجَ صِدْقٍ وَاجْعَل لِّي مِن لَّدُنكَ سُلْطَانًا نَّصِيرًا",
      reference: "الإسراء – آية 80",
    ),
    Dua(
      text:
          "رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا",
      reference: "الكهف – آية 10",
    ),
    Dua(
      text:
          "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي",
      reference: "طه – آيات 25–28",
    ),
    Dua(
      text: "رَبِّ زِدْنِي عِلْمًا",
      reference: "طه – آية 114",
    ),
    Dua(
      text:
          "لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ",
      reference: "الأنبياء – آية 87",
    ),
    Dua(
      text:
          "رَبِّ لَا تَذَرْنِي فَرْدًا وَأَنتَ خَيْرُ الْوَارِثِينَ",
      reference: "الأنبياء – آية 89",
    ),
    Dua(
      text:
          "رَبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ وَأَعُوذُ بِكَ رَبِّ أَن يَحْضُرُونِ",
      reference:
          "المؤمنون – آيات 97–98",
    ),
    Dua(
      text:
          "رَبَّنَا آمَنَّا فَاغْفِرْ لَنَا وَارْحَمْنَا وَأَنتَ خَيْرُ الرَّاحِمِينَ",
      reference: "المؤمنون – آية 109",
    ),
    Dua(
      text:
          "رَبِّ اغْفِرْ وَارْحَمْ وَأَنتَ خَيْرُ الرَّاحِمِينَ",
      reference: "المؤمنون – آية 118",
    ),
    Dua(
      text:
          "رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِمَن دَخَلَ بَيْتِيَ مُؤْمِنًا وَلِلْمُؤْمِنِينَ وَالْمُؤْمِنَاتِ وَلَا تَزِدِ الظَّالِمِينَ إِلَّا تَبَارًا",
      reference: "نوح – آية 28",
    ),
  ];

  const QuranDuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('أدعية قرآنية'),
        backgroundColor:
            Colors.green[700],
      ),
      body: ListView.builder(
        padding:
            const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16),
        itemCount: duas.length,
        itemBuilder: (context, index) {
          return DuaCard(
            dua: duas[index],
            number: index + 1,
          );
        },
      ),
    );
  }
}

class Dua {
  final String text;
  final String reference;

  const Dua(
      {required this.text,
      required this.reference});
}

class DuaCard extends StatefulWidget {
  final Dua dua;
  final int number;

  const DuaCard({
    super.key,
    required this.dua,
    required this.number,
  });

  @override
  _DuaCardState createState() =>
      _DuaCardState();
}

class _DuaCardState
    extends State<DuaCard> {
  int counter = 0;

  void incrementCounter() {
    setState(() {
      counter++;
    });
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
        margin: const EdgeInsets.only(
            bottom: 16),
        elevation: 6,
        shadowColor: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .stretch,
          children: [
            // Body with dua text
            Padding(
              padding:
                  const EdgeInsets.all(
                      20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  Text(
                    widget.dua.text,
                    textAlign:
                        TextAlign.right,
                    style:
                        const TextStyle(
                      fontSize: 22,
                      height: 1.8,
                      color: Colors
                          .black87,
                      fontFamily:
                          'Kitab',
                    ),
                  ),
                  const SizedBox(
                      height: 20),

                  // المرجع
                  Text(
                    widget
                        .dua.reference,
                    textAlign:
                        TextAlign.right,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors
                          .grey[700],
                      fontStyle:
                          FontStyle
                              .italic,
                    ),
                  ),
                ],
              ),
            ),

            // الأزرار والعدادات
            Container(
              padding: const EdgeInsets
                  .symmetric(
                  horizontal: 16,
                  vertical: 12),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  // الأزرار على اليسار
                  Row(
                    children: [
                      // زر المشاركة
                      IconButton(
                        icon: const Icon(
                            Icons.share,
                            color: Colors
                                .orange,
                            size: 24),
                        onPressed: () =>
                            Share.share(
                                widget
                                    .dua
                                    .text),
                        padding:
                            EdgeInsets
                                .zero,
                        constraints:
                            const BoxConstraints(),
                      ),
                      const SizedBox(
                          width: 16),

                      // زر إعادة التعيين
                      IconButton(
                        icon: const Icon(
                            Icons
                                .do_not_disturb,
                            color: Colors
                                .grey,
                            size: 24),
                        onPressed:
                            resetCounter,
                        tooltip:
                            'إعادة العداد',
                        padding:
                            EdgeInsets
                                .zero,
                        constraints:
                            const BoxConstraints(),
                      ),
                    ],
                  ),

                  // العدادات وزر الزيادة على اليمين
                  Row(
                    children: [
                      // زر الزيادة (+)
                      IconButton(
                        icon: const Icon(
                            Icons
                                .add_circle_outline,
                            color: Colors
                                .green,
                            size: 28),
                        onPressed:
                            incrementCounter,
                        padding:
                            EdgeInsets
                                .zero,
                        constraints:
                            const BoxConstraints(),
                      ),
                      //herer

                      const SizedBox(
                          width: 8),

                      // العداد
                      Container(
                        padding: const EdgeInsets
                            .symmetric(
                            horizontal:
                                16,
                            vertical:
                                6),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .green[50],
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      20),
                        ),
                        child: Text(
                          '$counter / 1',
                          style:
                              TextStyle(
                            fontSize:
                                16,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color: Colors
                                    .green[
                                700],
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 10),

                      // رقم البطاقة
                      Container(
                        padding: const EdgeInsets
                            .symmetric(
                            horizontal:
                                16,
                            vertical:
                                6),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .blueGrey[50],
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      20),
                        ),
                        child: Text(
                          '${widget.number}',
                          style:
                              const TextStyle(
                            fontSize:
                                16,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color: Colors
                                .blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
