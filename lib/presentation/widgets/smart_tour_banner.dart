import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../screens/route_suggestion_screen.dart';
import '../../core/localization/localization_extension.dart';
import '../../application/providers/language_provider.dart';

class SmartTourBanner extends StatelessWidget {
  // 1. إضافة متغير لاستقبال الـ ID الخاص بالقسم
  final String? categoryId;

  const SmartTourBanner({super.key, this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              const Divider(color: AppColors.divider, thickness: 1, height: 32),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(
                  24,
                ), // تقليل البادينق قليلاً للتوافق
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // الـ Badge الجميل حقك
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // تحسين: مسحنا الـ Builder الزايد واستخدمنا الـ context مباشرة
                    Text(
                      context.loc.smartTour,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.loc.viewTour,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        // 2. التعديل الأهم: تمرير البيانات لشاشة الاقتراحات
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RouteSuggestionScreen(
                              filterCategoryId: categoryId, // نمرر الـ ID هنا
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        label: Text(
                          context.loc.letsGo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
