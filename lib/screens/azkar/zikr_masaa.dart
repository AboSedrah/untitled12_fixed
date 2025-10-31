// lib/screens/azkar/evening_azkar_screen.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fazkorony/services/dhikr_events.dart';
import 'package:fazkorony/services/stats_controller.dart';

class EveningAzkarScreen
    extends StatelessWidget {
  final List<Zikr> azkar = const [
    Zikr(
      text:
          '''أعوذ بالله من الشيطان الرجيم 
﴿ ٱللَّهُ لَا إِلَٰهَ إِلَّا هُوَ ٱلْحَيُّ ٱلْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُۥ مَا فِى ٱلسَّمَٰوَٰتِ وَمَا فِى ٱلْأَرْضِ ۗ مَن ذَا ٱلَّذِى يَشْفَعُ عِندَهُۥٓ إِلَّا بِإِذْنِهِۦ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَىْءٍۢ مِّنْ عِلْمِهِۦٓ إِلَّا بِمَا شَآءَ ۚ وَسِعَ كُرْسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلْأَرْضَ ۖ وَلَا يَئُودُهُُۥ حِفْظُهُمَا ۚ وَهُوَ ٱلْعَلِىُّ ٱلْعَظِيمُ ﴾
(البقرة: 255)
من قالها حين يُمسي أُجير من الجن حتى يُصبح، ومن قالها حين يُصبح أُجير من الجن حتى يُمسي''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
﴿ قُلْ هُوَ اللَّهُ أَحَدٌ * اللَّهُ الصَّمَدُ * لَمْ يَلِدْ وَلَمْ يُولَدْ * وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ ﴾
(الإخلاص 1-4)
ثلاث مرات''',
      repeat: 3,
    ),
    Zikr(
      text:
          '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
﴿ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ * مِن شَرِّ مَا خَلَقَ * وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ * وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ * وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ ﴾
(الفلق 1-5)
ثلاث مرات''',
      repeat: 3,
    ),
    Zikr(
      text:
          '''بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
﴿ قُلْ أَعُوذُ بِرَبِّ النَّاسِ * مَلِكِ النَّاسِ * إِلَٰهِ النَّاسِ * مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ * الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ * مِنَ الْجِنَّةِ وَالنَّاسِ ﴾
(الناس 1-6)
ثلاث مرات''',
      repeat: 3,
    ),
    Zikr(
      text:
          '''أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد، وهو على كل شيء قدير،
رب أسألك خير ما في هذه الليلة وخير ما بعدها، وأعوذ بك من شر ما في هذه الليلة وشر ما بعدها،
رب أعوذ بك من الكسل وسوء الكبر، رب أعوذ بك من عذاب في النار وعذاب في القبر
(رواه مسلم)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''اللهم بك أمسينا وبك أصبحنا، وبك نحيا، وبك نموت، وإليك المصير
(رواه الترمذي)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''اللهم أنت ربي لا إله إلا أنت، خلقتني وأنا عبدك، وأنا على عهدك ووعدك ما استطعت،
أعوذ بك من شر ما صنعت، أبوء لك بنعمتك علي، وأبوء بذنبي فاغفر لي، فإنه لا يغفر الذنوب إلا أنت.
من قالها حين يمسي فمات من ليلته دخل الجنة وكذلك حين يصبح
(رواه البخاري)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''اللهم إني أمسيت أشهدك، وأشهد حملة عرشك، وملائكتك وجميع خلقك،
أنك أنت الله لا إله إلا أنت وحدك لا شريك لك، وأن محمداً عبدك ورسولك
من قالها حين يمسي أو يصبح أربع مرات أعتقه الله من النار
(رواه أبو داود)''',
      repeat: 4,
    ),
    Zikr(
      text:
          '''اللهم ما أمسى بي من نعمة أو بأحد من خلقك، فمنك وحدك لا شريك لك، فلك الحمد ولك الشكر
من قالها حين يمسي أدى شكر ليلته
(رواه أبو داود)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''اللهم عافني في بدني، اللهم عافني في سمعي، اللهم عافني في بصري،
لا إله إلا أنت، اللهم إني أعوذ بك من الكفر والفقر، وأعوذ بك من عذاب القبر، لا إله إلا أنت
(رواه أحمد)
ثلاث مرات''',
      repeat: 3,
    ),
    Zikr(
      text:
          '''اللهم إني أعوذ بك من الهم والحزن، وأعوذ بك من العجز والكسل،
وأعوذ بك من الجبن والبخل، وأعوذ بك من غلبة الدين وقهر الرجال
(رواه أبو داود)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''حسبي الله لا إله إلا هو عليه توكلت وهو رب العرش العظيم
من قالها كفاه الله ما أهمه من أمر الدنيا والآخرة
(رواه ابن السني)
سبع مرات''',
      repeat: 7,
    ),
    Zikr(
      text:
          '''اللهم إني أسألك العفو والعافية في الدنيا والآخرة،
اللهم إني أسألك العفو والعافية في ديني ودنياي وأهلي ومالي،
اللهم استر عوراتي، وآمن روعاتي،
اللهم احفظني من بين يدي ومن خلفي، وعن يميني، وعن شمالي، ومن فوقي،
وأعوذ بعظمتك أن أُغتال من تحتي
(رواه أبو داود)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''اللهم عالم الغيب والشهادة، فاطر السماوات والأرض، رب كل شيء ومليكه،
أشهد أن لا إله إلا أنت، أعوذ بك من شر نفسي، ومن شر الشيطان وشركه،
وأن أقترف على نفسي سوءاً أو أجره إلى مسلم
(رواه الترمذي)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''بسم الله الذي لا يضر مع اسمه شيء في الأرض ولا في السماء وهو السميع العليم
من قالها ثلاثاً لم يضره شيء
(رواه ابن ماجه)
ثلاث مرات''',
      repeat: 3,
    ),
    Zikr(
      text:
          '''رضيت بالله رباً، وبالإسلام ديناً، وبمحمد صلى الله عليه وسلم نبياً
من قالها حين يمسي وحين يصبح كان حقاً على الله أن يرضيه يوم القيامة
(رواه أحمد)
ثلاث مرات''',
      repeat: 3,
    ),
    Zikr(
      text:
          '''يا حي يا قيوم برحمتك أستغيث، أصلح لي شأني كله، ولا تكلني إلى نفسي طرفة عين
(رواه الترمذي)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''أمسينا وأمسى الملك لله رب العالمين،
اللهم إني أسألك خير هذه الليلة، فتحها ونصرها ونورها وبركتها وهداها،
وأعوذ بك من شر ما فيها وشر ما بعدها
(رواه أبو داود)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''أمسينا على فطرة الإسلام، وعلى كلمة الإخلاص،
وعلى دين نبينا محمد صلى الله عليه وسلم،
وعلى ملة أبينا إبراهيم حنيفاً مسلماً وما كان من المشركين
(رواه أحمد)''',
      repeat: 1,
    ),
    Zikr(
      text:
          '''لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير
من قالها مائة مرة حين يمسي وحين يصبح، لم يأت أحد يوم القيامة بأفضل مما جاء به، إلا أحد قال مثل ما قال أو زاد
(رواه مسلم)''',
      repeat: 100,
    ),
    Zikr(
      text:
          '''سبحان الله وبحمده عدد خلقه ورضا نفسه وزنة عرشه ومداد كلماته
(رواه مسلم)
ثلاث مرات''',
      repeat: 3,
    ),
    Zikr(
      text:
          '''أعوذ بكلمات الله التامات من شر ما خلق
ثلاث مرات''',
      repeat: 3,
    ),
    Zikr(
      text: '''أستغفر الله وأتوب إليه
(رواه البخاري)
مائة مرة''',
      repeat: 100,
    ),
    Zikr(
      text:
          '''اللهم صل وسلم على نبينا محمد
قال النبي صلى الله عليه وسلم: "من صلى عليّ حين يمسي عشراً وحين يصبح عشراً أدركته شفاعتي يوم القيامة"
(رواه الطبراني)
عشر مرات''',
      repeat: 10,
    ),
  ];

  const EveningAzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('أذكار المساء'),
        backgroundColor:
            Colors.indigo[700],
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
    DhikrEvents.recordRead(context, category: 'masa');
    final id = 'masa_${widget.zikr.hashCode}';
    final label = widget.zikr.text.length > 20 ? widget.zikr.text.substring(0, 20) : widget.zikr.text;
    StatsController().onZikrReadItem(category: 'masa', itemId: id, itemLabel: label);
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
                                .indigo),
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
                              .indigo[50],
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
                                    .indigo,
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
