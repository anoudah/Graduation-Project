import 'package:flutter/material.dart';
// تم التعديل هنا ليقرأ من ملفك
import '../../core/constants.dart'; 
import '../screens/faq.dart';
import '../screens/contactus.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primaryPurple),
            child: Center(child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24))),
          ),
          _item(context, Icons.question_answer, 'FAQ', const FAQPage()),
          _item(context, Icons.mail, 'Contact Us', const ContactUsScreen()),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryPurple),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
    );
  }
}