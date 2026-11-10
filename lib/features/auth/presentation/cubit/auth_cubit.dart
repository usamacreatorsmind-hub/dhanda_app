import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  late final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _prefLoggedIn = 'is_logged_in';
  static const String _prefUserUid = 'user_uid';
  static const String _prefUserPhone = 'user_phone';

  AuthCubit() : super(AuthInitial());

  // Check current auth status from SharedPreferences & Firestore
  void checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_prefLoggedIn) ?? false;
      final uid = prefs.getString(_prefUserUid);

      if (isLoggedIn && uid != null) {
        // Fetch user from Firestore
        try {
          final doc = await _firestore.collection('users').doc(uid).get();
          if (doc.exists) {
            final userModel = UserModel.fromMap(doc.data()!, doc.id);
            emit(AuthenticatedState(userModel));
            return;
          }
        } catch (e) {
          debugPrint('Auth check Firestore error: $e');
        }

        // Fallback user model if offline
        final userModel = UserModel(
          uid: uid,
          phoneNumber: prefs.getString(_prefUserPhone),
          createdAt: DateTime.now(),
        );
        emit(AuthenticatedState(userModel));
        return;
      }
      emit(UnauthenticatedState());
    } catch (_) {
      emit(UnauthenticatedState());
    }
  }

  // Send OTP (Simulated instantly for default OTP 1234)
  Future<void> sendOTP(String phoneNumber) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    emit(OTPSentState(verificationId: 'mock_verification_id', phoneNumber: phoneNumber));
  }

  // Verify OTP Code (Accepts '1234')
  Future<void> verifyOTP({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));

    if (smsCode.trim() == '1234') {
      try {
        final uid = 'user_${phoneNumber.replaceAll(RegExp(r'\D'), '')}';

        final userModel = UserModel(
          uid: uid,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
        );

        // Save user to Firestore 'users' collection
        await _firestore.collection('users').doc(uid).set(
          userModel.toMap(),
          SetOptions(merge: true),
        );

        // Save local session in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefLoggedIn, true);
        await prefs.setString(_prefUserUid, uid);
        await prefs.setString(_prefUserPhone, phoneNumber);

        emit(AuthenticatedState(userModel));
      } catch (e) {
        debugPrint('Firestore save user error: $e');
        emit(AuthErrorState('Failed to save user data: $e'));
      }
    } else {
      emit(const AuthErrorState('Invalid OTP. Please enter default OTP: 1234'));
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefLoggedIn);
      await prefs.remove(_prefUserUid);
      await prefs.remove(_prefUserPhone);
    } catch (_) {}
    emit(UnauthenticatedState());
  }
}
