import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moneyideas/core/config/env.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/inputs/app_text_field.dart';
import 'package:moneyideas/core/widgets/states/empty_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _ActionTask {
  _ActionTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isDone,
  });

  final String id;
  final String title;
  final String subtitle;
  bool isDone;
}

/// Screen 28: Personal Action Plan and Next Steps Execution connected directly to Supabase.
class NextStepsScreen extends StatefulWidget {
  const NextStepsScreen({super.key});

  @override
  State<NextStepsScreen> createState() => _NextStepsScreenState();
}

class _NextStepsScreenState extends State<NextStepsScreen> {
  final List<_ActionTask> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadTasks());
  }

  Future<void> _loadTasks() async {
    if (!Env.isConfigured) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await Supabase.instance.client
          .from('next_step_tasks')
          .select()
          .eq('user_id', user.id)
          .order('created_at');

      final items = (res as List<dynamic>).map((row) {
        final map = row as Map<String, dynamic>;
        return _ActionTask(
          id: map['id'] as String,
          title: map['title'] as String? ?? '',
          subtitle: map['description'] as String? ?? '',
          isDone: map['status'] == 'completed',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _tasks
            ..clear()
            ..addAll(items);
          _isLoading = false;
        });
      }
    } on Exception {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addTask(String title, String subtitle) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _tasks.add(
        _ActionTask(
          id: tempId,
          title: title,
          subtitle: subtitle,
          isDone: false,
        ),
      );
    });

    if (Env.isConfigured) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        try {
          await Supabase.instance.client.from('next_step_tasks').insert({
            'user_id': user.id,
            'title': title,
            'description': subtitle,
            'status': 'not_started',
          });
        } on Exception {
          // Handled
        }
      }
    }
  }

  Future<void> _toggleTask(_ActionTask task, {required bool isDone}) async {
    setState(() {
      task.isDone = isDone;
    });

    if (Env.isConfigured) {
      try {
        await Supabase.instance.client.from('next_step_tasks').update({
          'status': isDone ? 'completed' : 'not_started',
          'completed_at': isDone ? DateTime.now().toIso8601String() : null,
        }).eq('id', task.id);
      } on Exception {
        // Handled
      }
    }
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('إضافة خطوة تنفيذية جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: titleController,
                label: 'عنوان المهمة',
                hint: 'مثال: حجز اسم تجاري في الدائرة الاقتصادية',
              ),
              const Gap.sm(),
              AppTextField(
                controller: descController,
                label: 'ملاحظات وتفاصيل',
                hint: 'الجهة المسؤولة أو الرسوم المطلوبة',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  unawaited(
                    _addTask(
                      titleController.text.trim(),
                      descController.text.trim(),
                    ),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final completedCount = _tasks.where((t) => t.isDone).length;
    final progress = _tasks.isEmpty ? 0.0 : completedCount / _tasks.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'خطة العمل والخطوات القادمة',
          style: context.textStyles.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'إضافة خطوة',
        onPressed: _showAddTaskDialog,
        child: const Icon(AppIcons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: AppRadius.largeAll,
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'نسبة إنجاز خطة الإطلاق',
                          style: context.textStyles.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$completedCount من ${_tasks.length} مهام',
                          style: context.textStyles.labelLarge?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Gap.sm(),
                    ClipRRect(
                      borderRadius: AppRadius.fullAll,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: context.colors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(context.colors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tasks List
            Expanded(
              child: _tasks.isEmpty
                  ? EmptyState(
                      title: 'لا توجد مهام في خطة عملك حالياً',
                      message:
                          'يمكنك إضافة مهام تنفيذية مخصصة أو إضافة خطوات خريطة الطريق من تفاصيل أي فرصة استثمارية.',
                      actionLabel: 'إضافة مهمة جديدة',
                      onAction: _showAddTaskDialog,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mediumAll,
                            side: BorderSide(
                              color: task.isDone
                                  ? context.colors.primary.withValues(alpha: 0.4)
                                  : context.colors.outlineVariant,
                            ),
                          ),
                          color: task.isDone
                              ? context.colors.primaryContainer
                                  .withValues(alpha: 0.15)
                              : context.colors.surface,
                          child: CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: task.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isDone
                                    ? context.colors.onSurfaceVariant
                                    : null,
                              ),
                            ),
                            subtitle: task.subtitle.isNotEmpty
                                ? Text(
                                    task.subtitle,
                                    style: TextStyle(
                                      decoration: task.isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  )
                                : null,
                            value: task.isDone,
                            onChanged: (val) {
                              unawaited(
                                _toggleTask(task, isDone: val ?? false),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
