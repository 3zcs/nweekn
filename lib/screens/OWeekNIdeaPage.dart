import 'package:flutter/material.dart';

class OWeekNIdeaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('The OWeekN Idea'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Lamp Icon
            Center(
              child: Icon(
                Icons.lightbulb_outline,
                size: 100,
                color: Colors.amber,
              ),
            ),
            SizedBox(height: 20),


            // ✅ English Version
            Center(
              child: Text(
                'The OWeekN Idea',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // ✅ Ensures text is centered if it wraps
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You might be a busy employee, a business owner with commitments, or a parent who finds it difficult to leave home for long periods. '
                  'This project is based on the idea of sharing activities that can be done over the weekend or, to make it simpler, '
                  'ideas that can be accomplished within just 72 hours. '
                  'It could be a travel adventure, an exciting experience within the city, or even a creative idea that can be done at home. '
                  'All within the weekend!',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            Divider(
              color: Colors.grey.shade400,
              thickness: 1.2,
              height: 20,
              indent: 20,
              endIndent: 20,
            ),
            Text(
              'قد تكون موظف مشغول, أو مالك مشروع مرتبط أو رب أسرة يصعب عليه ترك المنزل لفترات طويلة. '
                  'هذا المشروع تقوم فكرته على مشاركة الأفكار التي يمكن القيام بها خلال عطلة نهاية الأسبوع '
                  'أو لجعل الموضوع أبسط، أفكار يمكن القيام بها خلال 72 ساعة فقط. '
                  'قد تكون رحلة سفر وقد تكون تجربة ممتعة داخل المدينة وربما فكرة إبداعية يمكن تطبيقها داخل المنزل. '
                  'فقط في عطلة نهاية الأسبوع!',
              style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
              textDirection: TextDirection.rtl, // ✅ Right to Left for Arabic
            ),
          ],
        ),
      ),
    );
  }
}
