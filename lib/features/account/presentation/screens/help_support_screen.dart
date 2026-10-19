import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';

/// Screen 77: Help, FAQ, and Support Screen.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعدة والدعم'),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.page,
          children: [
            Text(
              'الأسئلة الشائعة',
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.sm(),
            const ExpansionTile(
              title: Text('كيف تضمن المنصة صحة التكاليف والأرقام؟'),
              children: [
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'نعتمد على الربط المباشر بمصادر رسمية مثل اقتصادية دبي وهيئة تنظيم الاتصالات، مع تمييز دقيق بين التكاليف الموثقة بسند والتكاليف التقديرية.',
                  ),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text('هل يمكنني تغيير أهدافي وميزانيتي لاحقاً؟'),
              children: [
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'نعم، يمكنك في أي وقت تعديل تفضيلات الاستثمار من تبويب حسابي، وسيتم تحديث نتائج المستشار الذكي فوراً.',
                  ),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text('كيف يعمل محرك المطابقة الذكي؟'),
              children: [
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'يعتمد محرك المطابقة على خوارزميات واضحة ومفسرة داخل قاعدة البيانات، تقارن بين ميزانيتك، خبرتك، وقتك، ونطاق السوق دون نسب وهمية.',
                  ),
                ),
              ],
            ),
            const Gap.xl(),
            Text(
              'بحاجة لمساعدة إضافية؟',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.xs(),
            Text(
              'فريق الدعم الفني متاح لمساعدتك في أي استفسار يتعلق بالفرص أو الحساب.',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const Gap.lg(),
            AppButton(
              text: 'مراسلة الدعم الفني',
              icon: Icons.support_agent_rounded,
              isFullWidth: true,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تسجيل طلب المساعدة وسيتواصل معك الفريق.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
