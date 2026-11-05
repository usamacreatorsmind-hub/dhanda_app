import 'package:equatable/equatable.dart';
import '../../domain/models/business_model.dart';

abstract class BusinessSetupState extends Equatable {
  const BusinessSetupState();

  @override
  List<Object?> get props => [];
}

class BusinessSetupInitial extends BusinessSetupState {}

class BusinessSetupLoading extends BusinessSetupState {}

class GoogleBusinessMatch extends Equatable {
  final String name;
  final String address;
  final double rating;
  final int reviewCount;

  const GoogleBusinessMatch({
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewCount,
  });

  @override
  List<Object?> get props => [name, address, rating, reviewCount];
}

class BusinessSetupStepState extends BusinessSetupState {
  final int currentStep; // 1 to 4
  final String businessName;
  final List<String> topSellingItems;
  final List<String> suggestedItems;
  final String city;
  final List<GoogleBusinessMatch> matchingBusinesses;
  final GoogleBusinessMatch? selectedGoogleBusiness;
  final bool isLoading;
  final String? errorMessage;

  const BusinessSetupStepState({
    this.currentStep = 1,
    this.businessName = '',
    this.topSellingItems = const [],
    this.suggestedItems = const [
      'Marbles',
      'Ceramic Vases',
      'Wall Decals',
      'Floor Mats',
      'Rugs',
      'Curtains',
      'Wall Clocks',
      'Picture Frames',
      'Wall Shelves',
      'Mosaic Art',
    ],
    this.city = '',
    this.matchingBusinesses = const [],
    this.selectedGoogleBusiness,
    this.isLoading = false,
    this.errorMessage,
  });

  BusinessSetupStepState copyWith({
    int? currentStep,
    String? businessName,
    List<String>? topSellingItems,
    List<String>? suggestedItems,
    String? city,
    List<GoogleBusinessMatch>? matchingBusinesses,
    GoogleBusinessMatch? selectedGoogleBusiness,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BusinessSetupStepState(
      currentStep: currentStep ?? this.currentStep,
      businessName: businessName ?? this.businessName,
      topSellingItems: topSellingItems ?? this.topSellingItems,
      suggestedItems: suggestedItems ?? this.suggestedItems,
      city: city ?? this.city,
      matchingBusinesses: matchingBusinesses ?? this.matchingBusinesses,
      selectedGoogleBusiness: selectedGoogleBusiness ?? this.selectedGoogleBusiness,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        businessName,
        topSellingItems,
        suggestedItems,
        city,
        matchingBusinesses,
        selectedGoogleBusiness,
        isLoading,
        errorMessage,
      ];
}

class BusinessSetupSuccess extends BusinessSetupState {
  final BusinessModel business;

  const BusinessSetupSuccess(this.business);

  @override
  List<Object?> get props => [business];
}

class BusinessSetupError extends BusinessSetupState {
  final String message;

  const BusinessSetupError(this.message);

  @override
  List<Object?> get props => [message];
}
