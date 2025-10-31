import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class PropheticDuasScreen
    extends StatelessWidget {
  final List<Dua> ad3yah = const [
    Dua(
      text:
          "اللَّهُمَّ آتِنا في الدنيا حسنة، وفي الآخرة حسنة، وقِنا عذاب النار",
      reference: "رواه البخاري ومسلم",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من جَهْدِ البلاء، ودَرَكِ الشقاء، وسوء القضاء، وشماتة الأعداء",
      reference: "رواه البخاري ومسلم",
    ),
    Dua(
      text:
          "اللَّهُمَّ أصلح لي ديني الذي هو عصمة أمري، وأصلح لي دنياي التي فيها معاشي، وأصلح لي آخرتي التي فيها معادي، واجعل الحياة زيادةً لي في كل خير، واجعل الموت راحةً لي من كل شر",
      reference: "رواه مسلم",
    ),
    Dua(
      text:
          "رَبِّ أعني ولا تُعِن عليَّ، وانصرني ولا تنصر عليَّ، وامكر لي ولا تمكر عليَّ، واهدني ويسر الهدى إليَّ، وانصرني على من بغى عليَّ، رَبِّ اجعلني لك شكَّارًا، لك ذكَّارًا، لك رهَّابًا، لك مطواعًا، إليك مخبتًا، إليك أواهًا منيبًا، رَبِّ تقبل توبتي، واغسل حوبتي، وأجب دعوتي، وثبّت حجتي، واهدِ قلبي، وسدد لساني، واسلُل سخيمة قلبي",
      reference:
          "رواه أبو داود والترمذي",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أسألك من خير ما سألك منه نبيك محمد ﷺ، وأعوذ بك من شر ما استعاذك منه نبيك محمد ﷺ، وأنت المستعان، وعليك البلاغ، ولا حول ولا قوة إلا بالله",
      reference:
          "رواه الترمذي وابن ماجه",
    ),
    Dua(
      text:
          "اللَّهُمَّ اهدني وسدّدني، اللَّهُمَّ إني أسألك الهدى والسداد",
      reference: "رواه مسلم",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من زوال نعمتك، وتحوّل عافيتك، وفجاءة نقمتك، وجميع سخطك",
      reference: "رواه مسلم",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من فتنة النار، وعذاب النار، وفتنة القبر، وعذاب القبر، وشر فتنة الغنى، وشر فتنة الفقر، وأعوذ بك من شر فتنة المسيح الدجال، اللَّهُمَّ اغسل قلبي بماء الثلج والبرد، ونقِّ قلبي من الخطايا كما نقيت الثوب الأبيض من الدنس، وباعد بيني وبين خطاياي كما باعدت بين المشرق والمغرب، اللَّهُمَّ إني أعوذ بك من الكسل والمأثم والمغرم",
      reference: "رواه البخاري ومسلم",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من شر ما عملت، ومن شر ما لم أعمل",
      reference: "رواه مسلم",
    ),
    Dua(
      text:
          "لا إله إلا الله العظيم الحليم، لا إله إلا الله رب العرش العظيم، لا إله إلا الله رب السماوات ورب الأرض ورب العرش الكريم",
      reference: "رواه البخاري ومسلم",
    ),
    Dua(
      text:
          "اللَّهُمَّ رحمتك أرجو، فلا تكلني إلى نفسي طرفة عين، وأصلح لي شأني كله، لا إله إلا أنت",
      reference: "رواه أبو داود",
    ),
    Dua(
      text:
          "اللَّهُمَّ مصرّف القلوب، صرّف قلوبنا على طاعتك",
      reference: "رواه مسلم",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني عبدك، ابن عبدك، ابن أمتك، ناصيتي بيدك، ماضٍ فيّ حكمك، عدل فيّ قضاؤك، أسألك بكل اسم هو لك، سميت به نفسك، أو أنزلته في كتابك، أو علّمته أحدًا من خلقك، أو استأثرت به في علم الغيب عندك، أن تجعل القرآن ربيع قلبي، ونور صدري، وجلاء حزني، وذهاب همي",
      reference: "رواه أحمد",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من العجز، والكسل، والجبن، والبخل، والهرم، وعذاب القبر، اللَّهُمَّ آتِ نفسي تقواها، وزكِّها أنت خير من زكّاها، أنت وليها ومولاها، اللَّهُمَّ إني أعوذ بك من علم لا ينفع، ومن قلب لا يخشع، ومن نفس لا تشبع، ومن دعوة لا يُستجاب لها",
      reference: "رواه مسلم",
    ),
    Dua(
      text:
          "اللَّهُمَّ أحسن عاقبتنا في الأمور كلها، وأجرنا من خزي الدنيا وعذاب الآخرة",
      reference: "رواه أحمد",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من شر سمعي، ومن شر بصري، ومن شر لساني، ومن شر قلبي، ومن شر منيي",
      reference: "رواه أبو داود",
    ),
    Dua(
      text:
          "اللَّهُمَّ رب جبرائيل، وميكائيل، وإسرافيل، أعوذ بك من حر النار ومن عذاب القبر",
      reference: "رواه مسلم",
    ),
    Dua(
      text:
          "اللَّهُمَّ ألهمني رشدي، وأعذني من شر نفسي",
      reference: "رواه الترمذي",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أسألك علمًا نافعًا، وأعوذ بك من علم لا ينفع",
      reference: "رواه ابن ماجه",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من البرص، والجنون، والجذام، ومن سيئ الأسقام",
      reference:
          "رواه أبو داود والنسائي",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أسألك فعل الخيرات، وترك المنكرات، وحب المساكين، وأن تغفر لي وترحمني، وإذا أردت فتنة قوم فتوفني غير مفتون، وأسألك حبك، وحب من يحبك، وحب عمل يقربني إلى حبك",
      reference: "رواه الترمذي",
    ),
    Dua(
      text:
          "اللَّهُمَّ بعلمك الغيب وقدرتك على الخلق، أحيِني ما علمت الحياة خيرًا لي، وتوفني إذا علمت الوفاة خيرًا لي، اللَّهُمَّ إني أسألك خشيتك في الغيب والشهادة، وأسألك كلمة الحق في الغضب والرضا، وأسألك القصد في الفقر والغنى، وأسألك نعيمًا لا ينفد، وأسألك قرة عين لا تنقطع، وأسألك الرضا بعد القضاء، وأسألك برد العيش بعد الموت، وأسألك لذة النظر إلى وجهك، والشوق إلى لقائك، في غير ضراء مضرة ولا فتنة مضلة، اللَّهُمَّ زينا بزينة الإيمان، واجعلنا هداة مهتدين",
      reference: "رواه النسائي",
    ),
    Dua(
      text:
          "اللَّهُمَّ احفظني بالإسلام قائمًا، واحفظني بالإسلام قاعدًا، واحفظني بالإسلام راقدًا، ولا تشمت بي عدوًا ولا حاسدًا، اللَّهُمَّ إني أسألك من كل خير خزائنه بيدك، وأعوذ بك من كل شر خزائنه بيدك",
      reference: "رواه أحمد",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من العجز والكسل، والجبن والهرم والبخل، وأعوذ بك من عذاب القبر، ومن فتنة المحيا والممات",
      reference: "رواه البخاري ومسلم",
    ),
    Dua(
      text:
          "اللَّهُمَّ اقسم لنا من خشيتك ما تحول به بيننا وبين معاصيك، ومن طاعتك ما تبلغنا به جنتك، ومن اليقين ما تهوّن به علينا مصائب الدنيا، ومتعنا بأسماعنا وأبصارنا وقواتنا ما أحييتنا، واجعلها الوارث منا، واجعل ثأرنا على من ظلمنا، وانصرنا على من عادانا، ولا تجعل مصيبتنا في ديننا، ولا تجعل الدنيا أكبر همنا ولا مبلغ علمنا، ولا تسلط علينا من لا يرحمنا",
      reference: "رواه الترمذي",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من الجبن، وأعوذ بك من البخل، وأعوذ بك من أن أُرَدَّ إلى أرذل العمر، وأعوذ بك من فتنة الدنيا، وأعوذ بك من عذاب القبر",
      reference: "رواه البخاري ومسلم",
    ),
    Dua(
      text:
          "اللَّهُمَّ لك أسلمت، وبك آمنت، وعليك توكلت، وإليك أنبت، وبك خاصمت، اللَّهُمَّ إني أعوذ بعزتك، لا إله إلا أنت، أن تضلني، أنت الحي الذي لا يموت، والجن والإنس يموتون",
      reference: "رواه البخاري ومسلم",
    ),
    Dua(
      text:
          "اللَّهُمَّ إنا نسألك موجبات رحمتك، وعزائم مغفرتك، والسلامة من كل إثم، والغنيمة من كل بر، والفوز بالجنة، والنجاة من النار",
      reference:
          "رواه الحاكم وصححه الألباني",
    ),
    Dua(
      text:
          "اللَّهُمَّ أعني على ذكرك، وشكرك، وحسن عبادتك",
      reference:
          "رواه أبو داود والنسائي",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أسألك إيمانًا لا يرتد، ونعيمًا لا ينفد، ومرافقة نبيك محمد ﷺ في أعلى جنة الخلد",
      reference: "رواه أحمد",
    ),
    Dua(
      text:
          "اللَّهُمَّ فاطر السموات والأرض، عالم الغيب والشهادة، رب كل شيء ومليكه، أشهد أن لا إله إلا أنت، أعوذ بك من شر نفسي، ومن شر الشيطان وشركه، وأن أقترف على نفسي سوءًا أو أجره إلى مسلم",
      reference:
          "رواه الترمذي وأبو داود",
    ),
    Dua(
      text:
          "اللَّهُمَّ لك الحمد كله، ولك الملك كله، وبيدك الخير كله، وإليك يرجع الأمر كله، علانيته وسره، فأهل أنت أن تُحمد، وأهل أنت أن تُعبد، وأنت على كل شيء قدير، اللَّهُمَّ اغفر لي ما مضى من ذنبي، واعصمني فيما بقي من عمري، وارزقني عملًا صالحًا ترضى به عني",
      reference: "",
    ),
    Dua(
      text:
          "اللَّهُمَّ اجعل أوسع رزقك علي عند كبر سني، وانقطاع عمري",
      reference: "",
    ),
    Dua(
      text:
          "اللَّهُمَّ اغفر لي ذنبي، ووسع لي في داري، وبارك لي في رزقي",
      reference: "رواه أحمد",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أسألك من فضلك ورحمتك، فإنه لا يملكها إلا أنت",
      reference: "رواه البخاري",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من جار السوء في دار المقامة، فإن جار البادية يتحول",
      reference: "رواه النسائي",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من قلب لا يخشع، ومن دعاء لا يُسمع، ومن نفس لا تشبع، ومن علم لا ينفع، أعوذ بك من هؤلاء الأربع",
      reference: "رواه الترمذي",
    ),
    Dua(
      text:
          "اللَّهُمَّ اغفر لي ما قدمت وما أخرت، وما أسررت وما أعلنت، وما أسرفت، وما أنت أعلم به مني، أنت المقدم وأنت المؤخر، لا إله إلا أنت",
      reference: "رواه مسلم",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من غلبة الدين، وغلبة العدو، وشماتة الأعداء",
      reference: "رواه النسائي",
    ),
    Dua(
      text:
          "اللَّهُمَّ اغفر لي، واهدني، وارزقني، وعافني، وأعوذ بك من ضيق المقام يوم القيامة",
      reference: "",
    ),
    Dua(
      text:
          "اللَّهُمَّ متعني بسمعي وبصري، واجعلهما الوارث مني، وانصرني على من ظلمني، وخذ منه بثأري",
      reference: "رواه الترمذي",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أسألك عيشة نقية، وميتة سوية، ومردًا غير مخزٍ ولا فاضح",
      reference: "رواه أحمد",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من العجز، والكسل، والجبن، والبخل، والهرم، والقسوة، والغفلة، والعيلة، والذلة، والمسكنة، وأعوذ بك من الفقر، والكفر، والفسوق، والشقاق، والنفاق، والسمعة، والرياء، وأعوذ بك من الصمم، والبكم، والجنون، والجذام، والبرص، وسيئ الأسقام",
      reference:
          "رواه النسائي وأبو داود",
    ),
    Dua(
      text:
          "اللَّهُمَّ إني أعوذ بك من الفقر، والفاقة، والذلة، وأعوذ بك من أن أظلم أو أُظلم",
      reference: "رواه النسائي",
    ),
  ];

  const PropheticDuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('أدعية نبوية'),
        backgroundColor:
            Colors.blue[300],
      ),
      body: ListView.builder(
        padding:
            const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16),
        itemCount: ad3yah.length,
        itemBuilder: (context, index) {
          return DuaCard(
            dua: ad3yah[index],
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
                  if (widget
                      .dua
                      .reference
                      .isNotEmpty)
                    Text(
                      "(${widget.dua.reference})",
                      textAlign:
                          TextAlign
                              .right,
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
                            Icons.block,
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
