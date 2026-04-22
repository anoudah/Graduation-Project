import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../screens/search.dart';
import '../screens/profile.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Standardized padding to align with the rest of the Riyadh Wasel UI
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // BUILDER: Required to get the correct context to open the Scaffold drawer
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textMain, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 16),
          // SEARCH BAR: This is a "Hero" style fake search bar. 
          // It looks like a TextField but actually acts as a button to open the SearchScreen.
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: const IgnorePointer(
                  child: TextField(
                    readOnly: true, // Prevents keyboard from popping up here
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      suffixIcon: Icon(Icons.search, color: AppColors.iconGrey, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // PROFILE AVATAR: Quick access to the user's personal profile
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
            child: const CircleAvatar(
              backgroundColor: AppColors.avatarBg,
              child: Icon(Icons.person, color: AppColors.iconGrey, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}