import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class GeneralDuasScreen
    extends StatelessWidget {
  final List<DuaCategory>
      duaCategories = _duaCategories;
  
  static const List<DuaCategory> _duaCategories = [
    DuaCategory(
      title: "دعاء صلاة الاستخارة",
      duas: [
        Dua(
          text:
              "قال جابر بن عبد الله رضي الله عنهما: كان رسول الله صلى الله عليه وسلم، يعلمنا الاستخارة في الأمور كلها كما يعلمنا السورة من القرآن، يقول: إذا هم أحدكم بالأمر فليركع ركعتين من غير الفريضة، ثم ليقل: اللهم إني أستخيرك بعلمك، وأستقدرك بقدرتك، وأسألك من فضلك العظيم، فإنك تقدر ولا أقدر، وتعلم ولا أعلم، وأنت علام الغيوب، اللهم إن كنت تعلم أن هذا الأمر - ويسمي حاجته - خير لي في ديني ومعاشي وعاقبة أمري - أو قال: عاجله وآجله - فاقدره لي ويسره لي، ثم بارك لي فيه، وإن كنت تعلم أن هذا الأمر شر لي في ديني ومعاشي وعاقبة أمري - أو قال: عاجله وآجله - فاصرفه عني واصرفني عنه، واقدر لي الخير حيث كان، ثم رضني به.",
          reference: "",
        ),
        Dua(
          text:
              "وما ندم من استخار الخالق، واستشار المخلوقين المؤمنين وثبت في أمره، فقد قال سبحانه: ﴿وَشَاوِرْهُمْ فِي الْأَمْرِ فَإِذَا عَزَمْتَ فَتَوَكَّلْ عَلَى اللَّهِ﴾",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "دعاء قنوت الوتر",
      duas: [
        Dua(
          text:
              "اللهم اهدني فيمن هديت، وعافني فيمن عافيت، وتولني فيمن توليت، وبارك لي فيما أعطيت، وقني شر ما قضيت، فإنك تقضي ولا يقضى عليك، إنه لا يذل من واليت، ولا يعز من عاديت تباركت ربنا وتعاليت.",
          reference: "",
        ),
        Dua(
          text:
              "اللهم إني أعوذ برضاك من سخطك، وأعوذ بمعافاتك من عقوبتك، وأعوذ بك منك لا أحصي ثناءً عليك، أنت كما أثنيت على نفسك.",
          reference: "",
        ),
        Dua(
          text:
              "اللهم إياك نعبد، ولك نصلي ونسجد، وإليك نسعى ونحفد، نرجو رحمتك، ونخشى عذابك، إن عذابك بالكافرين ملحق، اللهم إنا نستعينك، ونستغفرك، ونثني عليك الخير، ولا نكفرك، ونؤمن بك، ونخضع لك، ونخلع من يكفرك.",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "دعاء الهم والحزن",
      duas: [
        Dua(
          text:
              "اللهم إني عبدك ابن عبدك ابن أمتك ناصيتي بيدك ماضٍ في حكمك، عدل في قضاؤك، أسألك بكل اسم هو لك سميت به نفسك أو أنزلته في كتابك، أو علمته أحداً من خلقك أو استأثرت به في علم الغيب عندك أن تجعل القرآن ربيع قلبي، ونور صدري، وجلاء حزني وذهاب همي.",
          reference: "",
        ),
        Dua(
          text:
              "اللهم إني أعوذ بك من الهم والحزن، والعجز والكسل، والجبن والبخل، وضلع الدين وغلبة الرجال.",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "دعاء الكرب",
      duas: [
        Dua(
          text:
              "لا إله إلا الله العظيم الحليم، لا إله إلا الله رب العرش العظيم، لا إله إلا الله رب السموات ورب الأرض ورب العرش الكريم.",
          reference: "",
        ),
        Dua(
          text:
              "اللهم رحمتك أرجو فلا تكلني إلى نفسي طرفة عين، وأصلح لي شأني كله لا إله إلا أنت.",
          reference: "",
        ),
        Dua(
          text:
              "لا إله إلا أنت سبحانك إني كنت من الظالمين",
          reference: "",
        ),
        Dua(
          text:
              "اللهم لا سهل إلا ما جعلته سهلاً وأنت تجعل الحزن إذا شئت سهلاً.",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title:
          "ما يقول ويفعل من أذنب ذنباً",
      duas: [
        Dua(
          text:
              "ما من عبد يذنب ذنباً فيحسن الطهور، ثم يقوم فيصلي ركعتين، ثم يستغفر الله إلا غفر الله له",
          reference: "(رواه أبو داود)",
        ),
      ],
    ),
    DuaCategory(
      title: "دعاء التعزية",
      duas: [
        Dua(
          text:
              "إن لله ما أخذ وله ما أعطى.. وكل شيء عنده بأجل مسمى... فلتصبر ولتحتسب.",
          reference: "",
        ),
        Dua(
          text:
              "أعظم الله أجرك وأحسن عزاءك وغفر لميتك",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "دعاء زيارة القبور",
      duas: [
        Dua(
          text:
              "السلام عليكم أهل الديار، من المؤمنين والمسلمين، وإنا إن شاء الله بكم لاحقون، يرحم الله المستقدمين منا والمستأخرين، نسأل الله لنا ولكم العافية.",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "الدعاء إذا نزل المطر",
      duas: [
        Dua(
          text: "اللهم صيباً نافعاً",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "دعاء رؤية الهلال",
      duas: [
        Dua(
          text:
              "الله أكبر، اللهم أهله علينا بالأمن والإيمان، والسلامة والإسلام، والتوفيق لما تحب وترضى، ربي وربك الله.",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "الدعاء عند إفطار الصائم",
      duas: [
        Dua(
          text:
              "ذهب الظمأ، وابتلت العروق، وثبت الأجر إن شاء الله.",
          reference: "",
        ),
        Dua(
          text:
              "اللهم إني أسألك برحمتك التي وسعت كل شيء أن تغفر لي.",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "الدعاء قبل الطعام",
      duas: [
        Dua(
          text:
              "إذا أكل أحدكم الطعام فليقل: بسم الله، فإن نسي في أوله فليقل: بسم الله في أوله وآخره",
          reference: "",
        ),
        Dua(
          text:
              "من أطعمه الله الطعام فليقل: اللهم بارك لنا فيه وأطعمنا خيراً منه. ومن سقاه الله لبناً فليقل: اللهم بارك لنا فيه وزدنا منه",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title:
          "الدعاء عند الفراغ من الطعام",
      duas: [
        Dua(
          text:
              "الحمد لله الذي أطعمني هذا، ورزقنيه من غير حول مني ولا قوة. الحمد لله حمداً كثيراً طيباً مباركاً فيه، غير [مكفي] ولا مودع ولا مستغنى عنه ربنا.",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "دعاء العطاس",
      duas: [
        Dua(
          text:
              "إذا عطس أحدكم فليقل: الحمد لله، وليقل له أخوه أو صاحبه: يرحمك الله، وإذا قال له: يرحمك الله، فليقل: يهديكم الله ويصلح بالكم.",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "دعاء المتراوح",
      duas: [
        Dua(
          text:
              "بارك الله لك، وبارك عليك، وجمع بينكما في خير.",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "دعاء الغضب",
      duas: [
        Dua(
          text:
              "أعوذ بالله من الشيطان الرجيم.",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "كفارة المجلس",
      duas: [
        Dua(
          text:
              "سبحانك اللهم وبحمدك، أشهد أن لا إله إلا أنت، أستغفرك وأتوب إليك.",
          reference: "",
        ),
        Dua(
          text:
              "عن عائشة رضي الله عنها قالت: ما جلس رسول الله صلى الله عليه وسلم مجلساً قط، ولا تلا قرآناً، ولا صلى صلاة إلا ختم ذلك بكلمات. قالت: فقلت: يا رسول الله أراك ما تجلس مجلساً ولا تتلو قرآناً، ولا تصلي صلاة إلا ختمت بهؤلاء الكلمات؟ قال: نعم (من قال خيراً ختم له طابع على ذلك الخير، ومن قال شراً كان له كفارة)، ((سبحانك وبحمدك لا إله إلا أنت أستغفرك وأتوب إليك)).",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "دعاء ركوب الدابة",
      duas: [
        Dua(
          text:
              "بسم الله، الحمد لله، {سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ * وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ} الحمد لله، الحمد لله، الحمد لله، الله أكبر، الله أكبر، الله أكبر، سبحانك اللهم إني ظلمت نفسي فاغفر لي، فإنه لا يغفر الذنوب إلا أنت.",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "دعاء دخول السوق",
      duas: [
        Dua(
          text:
              "لا إله إلا الله وحده لا شريك له، له الملك وله الحمد، يحيي ويميت، وهو حي لا يموت، بيده الخير وهو على كل شيء قدير",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "الدعاء يوم عرفة",
      duas: [
        Dua(
          text:
              "خير الدعاء دعاء يوم عرفة، وخير ما قلت أنا والأنبياء من قبلي: لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title:
          "ما يقول من أحس وجعاً في جسده",
      duas: [
        Dua(
          text:
              "ضع يدك على الذي تألم من جسدك وقل: بسم الله، ثلاثاً وقل سبع مرات: أعوذ بالله وقدرته من شر ما أجد وأحاذر",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title: "الاستغفار والتوبة",
      duas: [
        Dua(
          text:
              "قال رسول الله صلى الله عليه وسلم: \"والله إني لأستغفر الله وأتوب إليه في اليوم أكثر من سبعين مرة\".",
          reference: "",
        ),
        Dua(
          text:
              "وقال صلى الله عليه وسلم: \"يا أيها الناس توبوا إلى الله فإني أتوب في اليوم إليه مائة مرة\".",
          reference: "",
        ),
        Dua(
          text:
              "وقال صلى الله عليه وسلم: \"من قال أستغفر الله العظيم الذي لا إله إلا هو الحي القيوم وأتوب إليه، غفر الله له وإن كان فر من الزحف\".",
          reference: "",
        ),
        Dua(
          text:
              "وقال صلى الله عليه وسلم: \"أقرب ما يكون الرب من العبد في جوف الليل الآخر فإن استطعت أن تكون ممن يذكر الله في تلك الساعة فكن\".",
          reference: "",
        ),
        Dua(
          text:
              "وقال صلى الله عليه وسلم: \"أقرب ما يكون العبد من ربه وهو ساجد فأكثروا الدعاء\".",
          reference: "",
        ),
      ],
    ),
    DuaCategory(
      title:
          "فضل التسبيح والتحميد، والتكبير، والتهليل",
      duas: [
        Dua(
          text:
              "قال صلى الله عليه وسلم: \"من قال سبحان الله وبحمده في يوم مائة مرة حطت خطاياه ولو كانت مثل زبد البحر\".",
          reference: "",
        ),
        Dua(
          text:
              "وقال صلى الله عليه وسلم: \"من قال لا إله إلا الله وحده لا شريك له، له الملك، وله الحمد، وهو على كل شيء قدير عشر مرات، كان كمن أعتق أربعة أنفس من ولد إسماعيل\".",
          reference: "",
        ),
        Dua(
          text:
              "وقال صلى الله عليه وسلم: \"كلمتان خفيفتان على اللسان، ثقيلتان في الميزان حبيبتان إلى الرحمن: سبحان الله وبحمده سبحان الله العظيم\".",
          reference: "",
        ),
        Dua(
          text:
              "وقال صلى الله عليه وسلم: \"لأن أقول سبحان الله، والحمد لله ولا إله إلا الله، والله أكبر أحب إلي مما طلعت عليه الشمس\".",
          reference: "",
        ),
      ],
    ),
  ];

  const GeneralDuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('أدعية متنوعة'),
        backgroundColor:
            Colors.green[700],
      ),
      body: ListView.builder(
        padding:
            const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16),
        itemCount: duaCategories.length,
        itemBuilder:
            (context, categoryIndex) {
          final category =
              duaCategories[
                  categoryIndex];
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              // عنوان الفئة
              Padding(
                padding:
                    const EdgeInsets
                        .only(
                        top: 20,
                        bottom: 10),
                child: Text(
                  category.title,
                  textAlign:
                      TextAlign.right,
                  style:
                      const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // بطاقات الأدعية داخل الفئة
              ...category.duas
                  .map((dua) => DuaCard(
                        dua: dua,
                        number: category
                                .duas
                                .indexOf(
                                    dua) +
                            1,
                      ))
                  ,
            ],
          );
        },
      ),
    );
  }
}

class DuaCategory {
  final String title;
  final List<Dua> duas;

  const DuaCategory(
      {required this.title,
      required this.duas});
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
            // نص الدعاء
            Padding(
              padding:
                  const EdgeInsets.all(
                      20),
              child: Text(
                widget.dua.text,
                textAlign:
                    TextAlign.right,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.8,
                  color: Colors.black87,
                ),
              ),
            ),

            // المرجع (إن وجد)
            if (widget.dua.reference
                .isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets
                        .only(
                        bottom: 16,
                        right: 16,
                        left: 16),
                child: Text(
                  widget.dua.reference,
                  textAlign:
                      TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors
                        .grey[700],
                    fontStyle: FontStyle
                        .italic,
                  ),
                ),
              ),

            // الأزرار والعدادات
            Container(
              padding: const EdgeInsets
                  .symmetric(
                  horizontal: 16,
                  vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius:
                    const BorderRadius
                        .only(
                  bottomLeft:
                      Radius.circular(
                          16),
                  bottomRight:
                      Radius.circular(
                          16),
                ),
              ),
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
                          '$counter',
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
