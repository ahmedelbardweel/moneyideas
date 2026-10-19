import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/errors/failure.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';
import 'package:moneyideas/features/company/presentation/controllers/company_controller.dart';

@immutable
class OfferCreateDraft {
  const OfferCreateDraft({
    this.currentStep = 0,
    this.title = '',
    this.categoryId = '',
    this.serviceType = 'خدمة تجارية',
    this.description = '',
    this.isPriceOnDemand = false,
    this.price = 1000,
    this.priceCurrency = 'AED',
    this.additionalFeesDescription = '',
    this.targetCities = const ['Dubai'],
    this.validUntil,
    this.termsAndConditions = '',
    this.mediaUrls = const [],
    this.declarationAccepted = false,
  });

  final int currentStep;
  final String title;
  final String categoryId;
  final String serviceType;
  final String description;
  final bool isPriceOnDemand;
  final double price;
  final String priceCurrency;
  final String additionalFeesDescription;
  final List<String> targetCities;
  final DateTime? validUntil;
  final String termsAndConditions;
  final List<String> mediaUrls;
  final bool declarationAccepted;

  OfferCreateDraft copyWith({
    int? currentStep,
    String? title,
    String? categoryId,
    String? serviceType,
    String? description,
    bool? isPriceOnDemand,
    double? price,
    String? priceCurrency,
    String? additionalFeesDescription,
    List<String>? targetCities,
    DateTime? validUntil,
    String? termsAndConditions,
    List<String>? mediaUrls,
    bool? declarationAccepted,
  }) {
    return OfferCreateDraft(
      currentStep: currentStep ?? this.currentStep,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      isPriceOnDemand: isPriceOnDemand ?? this.isPriceOnDemand,
      price: price ?? this.price,
      priceCurrency: priceCurrency ?? this.priceCurrency,
      additionalFeesDescription:
          additionalFeesDescription ?? this.additionalFeesDescription,
      targetCities: targetCities ?? this.targetCities,
      validUntil: validUntil ?? this.validUntil,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      declarationAccepted: declarationAccepted ?? this.declarationAccepted,
    );
  }
}

final offerCreateControllerProvider =
    NotifierProvider<OfferCreateController, OfferCreateDraft>(
  OfferCreateController.new,
);

class OfferCreateController extends Notifier<OfferCreateDraft> {
  @override
  OfferCreateDraft build() {
    return OfferCreateDraft(
      validUntil: DateTime.now().add(const Duration(days: 60)),
    );
  }

  void setStep(int step) {
    if (step >= 0 && step <= 3) {
      state = state.copyWith(currentStep: step);
    }
  }

  void updateBasicInfo({
    required String title,
    required String categoryId,
    required String serviceType,
    required String description,
  }) {
    state = state.copyWith(
      title: title,
      categoryId: categoryId,
      serviceType: serviceType,
      description: description,
    );
  }

  void updatePricingAndTarget({
    required bool isPriceOnDemand,
    required double price,
    required String priceCurrency,
    required String additionalFees,
    required List<String> targetCities,
    required DateTime validUntil,
  }) {
    state = state.copyWith(
      isPriceOnDemand: isPriceOnDemand,
      price: price,
      priceCurrency: priceCurrency,
      additionalFeesDescription: additionalFees,
      targetCities: targetCities,
      validUntil: validUntil,
    );
  }

  void updateMediaAndTerms({
    required String terms,
    required List<String> mediaUrls,
  }) {
    state = state.copyWith(
      termsAndConditions: terms,
      mediaUrls: mediaUrls,
    );
  }

  void toggleDeclaration(bool value) {
    state = state.copyWith(declarationAccepted: value);
  }

  Future<Result<CompanyOffer>> submitOffer({required bool asDraft}) async {
    final company = await ref.read(myCompanyProvider.future);
    if (company == null) {
      return Result.failure(
        const NotFoundFailure(debugMessage: 'يجب تسجيل شركة أولاً قبل إنشاء العرض'),
      );
    }

    final newOffer = CompanyOffer(
      id: '',
      companyId: company.id,
      categoryId: state.categoryId,
      title: state.title,
      description: state.description,
      serviceType: state.serviceType,
      termsAndConditions: state.termsAndConditions,
      validUntil: state.validUntil ?? DateTime.now().add(const Duration(days: 30)),
      price: state.isPriceOnDemand ? null : state.price,
      priceCurrency: state.priceCurrency,
      additionalFeesDescription: state.additionalFeesDescription.isNotEmpty
          ? state.additionalFeesDescription
          : null,
      targetCities: state.targetCities,
      status: asDraft ? OfferStatus.draft : OfferStatus.inReview,
      mediaUrls: state.mediaUrls,
    );

    return ref.read(companyOffersProvider.notifier).createOffer(newOffer);
  }
}
