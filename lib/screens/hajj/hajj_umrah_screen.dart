import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class HajjUmrahScreen extends StatelessWidget {
  const HajjUmrahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // عرض ملف PDF من الأصول بدل الصور
    // const pdfPath = 'assets/13624650881.pdf'; // unused - use literal path below

    return Scaffold(
      appBar: AppBar(title: const Text('صفة الحج والعمرة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('فتح ملف صفة الحج والعمرة (PDF)'),
              subtitle: const Text('من الأصول داخل التطبيق'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const _PdfViewer(assetPath: 'assets/13624650881.pdf'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('العمرة على هدي النبي ﷺ (بالترتيب)'),
          _hadithBullet(
              'الإحرام والتلبية: كان ﷺ يقول: «لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ» (متفق عليه).'),
          _hadithBullet(
              'الطواف: طاف ﷺ بالبيت سبعًا، وجعل البيت عن يساره، ورَمَلَ في الثلاثة الأولى ومشى في الأربعة (متفق عليه).'),
          _hadithBullet(
              'السعي بين الصفا والمروة: «ابدؤوا بما بدأ الله به» فبدأ بالصفا ثم المروة سعيًا سبعة أشواط (رواه مسلم).'),
          _hadithBullet(
              'الحلق أو التقصير: «اللَّهُمَّ ارْحَمِ الْمُحَلِّقِينَ» قالوا: والمقصرين يا رسول الله؟ قال: «وَالْمُقَصِّرِينَ» (متفق عليه).'),
          const SizedBox(height: 20),
          _sectionTitle('الحج على هدي النبي ﷺ (حجة الوداع – تسلسل المناسك)'),
          _hadithBullet(
              'النية والإهلال: «خُذُوا عَنِّي مَنَاسِكَكُمْ» (رواه مسلم). أهلَّ ﷺ بالحج وقال: «دخلت العمرة في الحج إلى يوم القيامة» (رواه مسلم).'),
          _hadithBullet(
              'اليوم الثامن (التروية): أحرم للحج من مكانه، وذهب إلى مِنًى فصلَّى بها الصلوات قصراً (رواه البخاري).'),
          _hadithBullet(
              'اليوم التاسع: الوقوف بعرفة: «الحج عرفة» (رواه الترمذي). وقف ﷺ عند الصخرات وقال: «وقفت هاهنا وعرفة كلها موقف» (رواه مسلم).'),
          _hadithBullet(
              'الدفع إلى مزدلفة بعد الغروب، وصلى بها المغرب والعشاء جمع تأخير، وبات فيها حتى الفجر (متفق عليه).'),
          _hadithBullet(
              'يوم النحر: رمى جمرة العقبة بسبع حصيات، ثم نحر، ثم حلق، ثم طاف طواف الإفاضة، وقال: «افعل ولا حرج» في التقديم والتأخير (متفق عليه).'),
          _hadithBullet(
              'أيام التشريق: رمي الجمرات الثلاث بعد الزوال كل يوم، والذكر: «أيام التشريق أيام أكل وشرب وذكر الله» (رواه مسلم).'),
          _hadithBullet(
              'طواف الوداع: «لا ينفرن أحد حتى يكون آخر عهده بالبيت» (متفق عليه).'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('تنبيهات مهمة',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      '• يُشترط للنسك الإخلاص والمتابعة، واجتناب الرفث والفسوق والجدال.\n• من عجز عن بعض الأعمال لمرض أو زحام فله الرخصة بنص قوله ﷺ: «افعل ولا حرج».\n• المحافظة على السكينة وحقوق الناس وتعظيم حرمات البيت.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(t,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );

  Widget _hadithBullet(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• '),
            Expanded(child: Text(t)),
          ],
        ),
      );
}

class _PdfViewer extends StatefulWidget {
  const _PdfViewer({required this.assetPath});
  final String assetPath;
  @override
  State<_PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<_PdfViewer> {
  late final PdfControllerPinch _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        PdfControllerPinch(document: PdfDocument.openAsset(widget.assetPath));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ملف PDF')),
      body: PdfViewPinch(controller: _controller),
    );
  }
}
