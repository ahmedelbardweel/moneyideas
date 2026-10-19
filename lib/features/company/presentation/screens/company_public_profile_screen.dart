import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/company/data/repositories/company_repository.dart';
import 'package:moneyideas/features/company/domain/models/company.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';
import 'package:moneyideas/features/company/presentation/widgets/company_verification_badge.dart';
import 'package:moneyideas/features/company/presentation/widgets/offer_card.dart';

class CompanyPublicProfileScreen extends ConsumerStatefulWidget {
  const CompanyPublicProfileScreen({required this.companyId, super.key});

  final String companyId;

  @override
  ConsumerState<CompanyPublicProfileScreen> createState() =>
      _CompanyPublicProfileScreenState();
}

class _CompanyPublicProfileScreenState
    extends ConsumerState<CompanyPublicProfileScreen> {
  Company? _company;
  List<CompanyOffer> _offers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final repo = ref.read(companyRepositoryProvider);
    final res = await repo.getPublicCompanyProfile(widget.companyId);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (res.isSuccess) {
        final data = res.valueOrNull!;
        _company = data['company'] as Company?;
        _offers = data['offers'] as List<CompanyOffer>? ?? [];
      } else {
        _errorMessage = res.failureOrNull?.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _company == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ملف الشركة')),
        body: Center(child: Text(_errorMessage ?? 'تعذر العثور على الشركة')),
      );
    }

    final company = _company!;

    return Scaffold(
      appBar: AppBar(
        title: Text(company.tradeName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Company Header Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lgAll,
                side: BorderSide(
                  color: context.colors.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: context.colors.primary,
                      child: Text(
                        company.tradeName.isNotEmpty
                            ? company.tradeName.characters.first
                            : 'C',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: context.colors.onPrimary,
                        ),
                      ),
                    ),
                    const Gap.md(),
                    Text(
                      company.tradeName,
                      style: context.textStyles.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap.xxs(),
                    Text(
                      'الاسم القانوني: ${company.legalName}',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap.sm(),
                    CompanyVerificationBadge(
                      status: company.verificationStatus,
                    ),
                    const Gap.md(),
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.location_on_outlined, size: 16),
                          label: Text(company.city),
                        ),
                        Chip(
                          avatar: const Icon(Icons.category_outlined, size: 16),
                          label: Text(company.businessType),
                        ),
                        if (company.licenseIssuingAuthority != null)
                          Chip(
                            avatar: const Icon(Icons.verified_user_outlined, size: 16),
                            label: Text(company.licenseIssuingAuthority!),
                          ),
                      ],
                    ),
                    if (company.bio != null && company.bio!.isNotEmpty) ...[
                      const Gap.md(),
                      Text(
                        company.bio!,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Gap.xl(),

            // Offers Catalog Section
            Text(
              'العروض والخدمات المعتمدة (${_offers.length})',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.sm(),

            if (_offers.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerLowest,
                  borderRadius: AppRadius.lgAll,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: context.colors.outline,
                    ),
                    const Gap.sm(),
                    const Text('لا توجد عروض معتمدة منشورة حالياً لهذه الشركة'),
                  ],
                ),
              ),
            ] else ...[
              ..._offers.map((offer) {
                return OfferCard(
                  offer: offer,
                  isOwner: false,
                  onTap: () => unawaited(
                    context.push('/offer/${offer.id}'),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
