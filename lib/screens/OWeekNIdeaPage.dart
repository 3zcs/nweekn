import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Required for opening social media links

class OWeekNIdeaPage extends StatelessWidget {
  // ✅ Social Media Links
  final String twitterUrl = 'https://x.com/3zcs';
  final String instagramUrl = 'https://instagram.com/3zcs';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // ✅ Remove shadow for a clean look
        backgroundColor: Colors.transparent, // ✅ Transparent background
        centerTitle: true, // ✅ Centered title
        flexibleSpace: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)), // ✅ Rounded bottom corners
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amber, // ✅ Consistent amber color
            ),
          ),
        ),
        title: Text(
          'The OWeekN Idea',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black, // ✅ High contrast title
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // ✅ Consistent back button
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24), // ✅ Balanced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Lamp Icon with Glow Effect
            // ✅ Lamp Icon Without Glow Effect
            Center(
              child: Icon(
                Icons.lightbulb_outline,
                size: 100,
                color: Colors.amber,
              ),
            ),


            SizedBox(height: 20),

            // ✅ English Version Title
            Text(
              'The OWeekN Idea',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),

            // ✅ English Version Description
            Text(
              'You might be a busy employee, a business owner with commitments, or a parent who finds it difficult to leave home for long periods. '
                  'This project is based on the idea of sharing activities that can be done over the weekend or, to make it simpler, '
                  'ideas that can be accomplished within just 72 hours. '
                  'It could be a travel adventure, an exciting experience within the city, or even a creative idea that can be done at home. '
                  'All within the weekend!',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20),

            Divider(color: Colors.grey.shade400, thickness: 1.2, indent: 30, endIndent: 30),

            SizedBox(height: 20),

            // ✅ Arabic Version
            Text(
              'قد تكون موظف مشغول, أو مالك مشروع مرتبط أو رب أسرة يصعب عليه ترك المنزل لفترات طويلة. '
                  'هذا المشروع تقوم فكرته على مشاركة الأفكار التي يمكن القيام بها خلال عطلة نهاية الأسبوع '
                  'أو لجعل الموضوع أبسط، أفكار يمكن القيام بها خلال 72 ساعة فقط. '
                  'قد تكون رحلة سفر وقد تكون تجربة ممتعة داخل المدينة وربما فكرة إبداعية يمكن تطبيقها داخل المنزل. '
                  'فقط في عطلة نهاية الأسبوع!',
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[800]),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),

            SizedBox(height: 30),

// ✅ Updated Social Media Section
            Text(
              'Follow Us',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),

// ✅ Social Media Icons Row with Official Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(FontAwesomeIcons.snapchat, 'https://www.snapchat.com/add/iazcs', Colors.yellow[700]!), // ✅ Snapchat
                SizedBox(width: 16),
                _buildSocialButton(FontAwesomeIcons.xTwitter, 'https://x.com/3zcs', Colors.black), // ✅ X (Twitter)
                SizedBox(width: 16),
                _buildSocialButton(FontAwesomeIcons.instagram, 'https://instagram.com/3zcs', Colors.pink[400]!), // ✅ Instagram
              ],
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication); // ✅ Opens in browser
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildSocialButton(IconData icon, String url, Color color) {
    return GestureDetector(
      onTap: () => _launchUrl(url), // ✅ Opens the social media link
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: FaIcon(icon, size: 28, color: Colors.white), // ✅ Uses FontAwesome Icons
      ),
    );
  }

}


