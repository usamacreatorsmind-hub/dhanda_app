import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/business_model.dart';
import 'business_setup_state.dart';

class BusinessSetupCubit extends Cubit<BusinessSetupState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _suggestedItemsSubscription;

  BusinessSetupCubit() : super(const BusinessSetupStepState()) {
    listenToSuggestedItems();
  }

  void listenToSuggestedItems() {
    _suggestedItemsSubscription?.cancel();
    final docRef = _firestore.collection('masters').doc('top_selling_items');

    _suggestedItemsSubscription = docRef.snapshots().listen((doc) async {
      if (doc.exists && doc.data() != null && doc.data()!['items'] != null) {
        final List<dynamic> rawItems = doc.data()!['items'];
        final List<String> items = rawItems.map((e) => e.toString()).toList();
        final currentState = state;
        if (currentState is BusinessSetupStepState) {
          emit(currentState.copyWith(suggestedItems: items));
        }
      } else {
        // Master document doesn't exist yet in Firestore: seed initial default items
        const defaultItems = [
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
        ];
        try {
          await docRef.set({
            'items': defaultItems,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('Error seeding master suggested items: $e');
        }
      }
    }, onError: (e) {
      debugPrint('Error in real-time master suggested items listener: $e');
    });
  }

  @override
  Future<void> close() {
    _suggestedItemsSubscription?.cancel();
    return super.close();
  }

  void setStep(int step) {
    final currentState = state;
    if (currentState is BusinessSetupStepState) {
      emit(currentState.copyWith(currentStep: step, errorMessage: null));
    } else {
      emit(BusinessSetupStepState(currentStep: step));
    }
  }

  void updateBusinessName(String name) {
    final currentState = state;
    if (currentState is BusinessSetupStepState) {
      emit(currentState.copyWith(businessName: name, errorMessage: null));
    } else {
      emit(BusinessSetupStepState(businessName: name));
    }
  }

  void updateTopSellingItems(List<String> items) {
    final currentState = state;
    if (currentState is BusinessSetupStepState) {
      emit(currentState.copyWith(topSellingItems: items, errorMessage: null));
    } else {
      emit(BusinessSetupStepState(topSellingItems: items));
    }
  }

  void updateCity(String city) {
    final currentState = state;
    if (currentState is BusinessSetupStepState) {
      emit(currentState.copyWith(city: city, errorMessage: null));
    } else {
      emit(BusinessSetupStepState(city: city));
    }
  }

  Future<void> searchGoogleBusinesses() async {
    final currentState = state;
    if (currentState is! BusinessSetupStepState) return;

    emit(currentState.copyWith(isLoading: true, errorMessage: null));
    try {
      // Simulate Google Places API search delay
      await Future.delayed(const Duration(milliseconds: 800));

      final query = currentState.businessName.trim().isNotEmpty
          ? currentState.businessName.trim()
          : 'Store';
      final city = currentState.city.trim().isNotEmpty
          ? currentState.city.trim()
          : 'Noida';

      // Mock results matching screenshots
      final mockResults = [
        GoogleBusinessMatch(
          name: '$query - Designer ${currentState.topSellingItems.isNotEmpty ? currentState.topSellingItems.first : "Items"}',
          address: 'near Police Station, A Block, Sector 9, $city, Uttar Pradesh 201301, India',
          rating: 4.3,
          reviewCount: 303,
        ),
        GoogleBusinessMatch(
          name: '${currentState.businessName.isNotEmpty ? currentState.businessName : "Local"} And Sanitary',
          address: 'Main, Dadri Main Rd, opp. Radha Swami Satsang, Rajput Colony, Natthu Colony, $city',
          rating: 4.9,
          reviewCount: 560,
        ),
        GoogleBusinessMatch(
          name: 'Kajaria Authorised Showroom - $query',
          address: 'Keshav, 39, Shaheed Arjun Sardana Marg, B Block, Sector 9, $city, Uttar Pradesh',
          rating: 4.3,
          reviewCount: 602,
        ),
        GoogleBusinessMatch(
          name: 'Jaquar Authorized Dealer Hindustan Sanitary & $query Emporium',
          address: 'E-57, E Block, Sector 9, $city, Uttar Pradesh',
          rating: 4.6,
          reviewCount: 189,
        ),
      ];

      emit(currentState.copyWith(
        isLoading: false,
        matchingBusinesses: mockResults,
        currentStep: 4,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoading: false, errorMessage: 'Failed to search Google Business: $e'));
    }
  }

  void selectGoogleBusiness(GoogleBusinessMatch? match) {
    final currentState = state;
    if (currentState is BusinessSetupStepState) {
      emit(currentState.copyWith(selectedGoogleBusiness: match));
    }
  }

  Future<void> completeSetup({File? logoFile, String? website}) async {
    final currentState = state;
    if (currentState is! BusinessSetupStepState) return;

    emit(BusinessSetupLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final uid = prefs.getString('user_uid');

      if (!isLoggedIn || uid == null || uid.isEmpty) {
        emit(const BusinessSetupError('Please login with your mobile number first.'));
        return;
      }

      final docRef = _firestore.collection('businesses').doc();
      final selectedGoogle = currentState.selectedGoogleBusiness;

      final business = BusinessModel(
        id: docRef.id,
        ownerUid: uid,
        name: selectedGoogle != null ? selectedGoogle.name : (currentState.businessName.isNotEmpty ? currentState.businessName : 'My Business'),
        category: currentState.topSellingItems.isNotEmpty ? currentState.topSellingItems.first : 'Retail Store',
        city: currentState.city.isNotEmpty ? currentState.city : 'Noida',
        phone: prefs.getString('user_phone') ?? '+919876543210',
        website: website,
        logoUrl: logoFile != null ? 'https://via.placeholder.com/150' : null,
        topSellingItems: currentState.topSellingItems,
        googleBusinessAddress: selectedGoogle?.address,
        googleBusinessRating: selectedGoogle?.rating,
        createdAt: DateTime.now(),
      );

      // 1. Save business document to Firestore 'businesses' collection
      await docRef.set(business.toMap());

      // 2. Sync to 'business_profiles/{uid}' so Dashboard, Preferences & Manage GMB Profile are immediately populated
      try {
        await _firestore.collection('business_profiles').doc(uid).set({
          'userId': uid,
          'businessName': business.name,
          'primaryPhone': business.phone,
          'communicationPhone': business.phone,
          'primaryCategory': business.category,
          'city': business.city,
          'address': business.googleBusinessAddress ?? business.city,
          'website': business.website ?? '',
          'topSellingItems': business.topSellingItems,
          'googleBusinessRating': business.googleBusinessRating ?? 4.5,
          'regularHours': 'Mon - Sun: 9:30 AM - 8:30 PM',
          'aiReplySalutation': 'Thank you for visiting ${business.name}!',
          'autoReplyEnabled': true,
          'autoPostEnabled': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error syncing business_profiles doc: $e');
      }

      // 3. Update user document in Firestore 'users' collection with selectedBusinessId
      try {
        await _firestore.collection('users').doc(uid).set({
          'selectedBusinessId': docRef.id,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error merging selectedBusinessId to user doc: $e');
      }

      emit(BusinessSetupSuccess(business));
    } catch (e) {
      debugPrint('Firestore save business profile error: $e');
      emit(BusinessSetupError('Failed to save business profile: $e'));
    }
  }

  // Legacy fallback method for direct calls
  Future<void> saveBusinessProfile({
    required String name,
    required String category,
    required String city,
    required String phone,
    String? website,
    File? logoFile,
  }) async {
    updateBusinessName(name);
    updateCity(city);
    await completeSetup(logoFile: logoFile, website: website);
  }
}
