import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/gmb_service.dart';
import '../models/business_profile_model.dart';

class BusinessProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GmbService _gmbService;

  BusinessProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    GmbService? gmbService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _gmbService = gmbService ?? GmbService();

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('business_profiles');

  Future<String> resolveUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('user_uid');
      if (uid != null && uid.isNotEmpty) {
        return uid;
      }
    } catch (_) {}
    return _auth.currentUser?.uid ?? 'guest_user';
  }

  Stream<BusinessProfileModel> watchCurrentUserProfile() {
    return Stream.fromFuture(resolveUserId())
        .asyncExpand((userId) => getProfileStream(userId))
        .handleError((Object e) {
          debugPrint('watchCurrentUserProfile error: $e');
        })
        .asBroadcastStream();
  }

  Stream<BusinessProfileModel> getProfileStream(String userId) {
    return _collection
        .doc(userId)
        .snapshots()
        .asyncMap((doc) async {
          if (doc.exists && doc.data() != null) {
            return BusinessProfileModel.fromMap(doc.data()!, doc.id);
          } else {
            try {
              final query = await _firestore
                  .collection('businesses')
                  .where('ownerUid', isEqualTo: userId)
                  .limit(1)
                  .get();
              if (query.docs.isNotEmpty) {
                final bData = query.docs.first.data();
                final migrated = BusinessProfileModel(
                  userId: userId,
                  businessName: bData['name'] as String? ?? '',
                  primaryPhone: bData['phone'] as String? ?? '',
                  communicationPhone: bData['phone'] as String? ?? '',
                  primaryCategory: bData['category'] as String? ?? '',
                  city: bData['city'] as String? ?? '',
                  address: (bData['googleBusinessAddress'] as String?) ??
                      (bData['city'] as String? ?? ''),
                  website: bData['website'] as String? ?? '',
                  topSellingItems: List<String>.from(bData['topSellingItems'] ?? const []),
                  googleBusinessRating: (bData['googleBusinessRating'] as num?)?.toDouble(),
                  regularHours: 'Mon - Sun: 9:30 AM - 8:30 PM',
                  aiReplySalutation: 'Thank you for visiting us!',
                );
                await saveProfile(migrated);
                await seedDefaultReviewsIfNeeded(userId, migrated.businessName, migrated.city);
                return migrated;
              }
            } catch (e) {
              debugPrint('Error migrating business to business_profiles: $e');
            }
            return BusinessProfileModel(userId: userId);
          }
        })
        .handleError((Object e) {
          debugPrint('getProfileStream error: $e');
        })
        .asBroadcastStream();
  }

  Future<BusinessProfileModel> getProfile(String userId) async {
    try {
      final doc = await _collection.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return BusinessProfileModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('getProfile error: $e');
    }
    return BusinessProfileModel(userId: userId);
  }

  Future<void> saveProfile(BusinessProfileModel profile) async {
    try {
      final uid = profile.userId.isEmpty || profile.userId == 'guest_user'
          ? await resolveUserId()
          : profile.userId;
      await _collection.doc(uid).set(
            profile.copyWith(userId: uid).toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      debugPrint('saveProfile error: $e');
    }
  }

  Future<GmbConnectionResult> connectUserGmailAndSync(BusinessProfileModel current) async {
    final result = await _gmbService.connectUserGmailForGmb();
    final firstLoc = result.locations.isNotEmpty ? result.locations.first : null;
    final uid = current.userId.isEmpty || current.userId == 'guest_user'
        ? await resolveUserId()
        : current.userId;

    final updated = current.copyWith(
      userId: uid,
      isGmbConnected: true,
      connectedGmail: result.email,
      gmbAccessToken: result.accessToken,
      gmbLocationName: firstLoc?.name ?? 'accounts/self/locations/$uid',
      businessName: current.businessName.isNotEmpty
          ? current.businessName
          : (firstLoc?.title ?? current.businessName),
      primaryCategory: current.primaryCategory.isNotEmpty
          ? current.primaryCategory
          : (firstLoc?.primaryCategory ?? current.primaryCategory),
      address: current.address.isNotEmpty ? current.address : (firstLoc?.address ?? current.address),
      primaryPhone:
          current.primaryPhone.isNotEmpty ? current.primaryPhone : (firstLoc?.phone ?? current.primaryPhone),
      website: current.website.isNotEmpty ? current.website : (firstLoc?.website ?? current.website),
    );

    await saveProfile(updated);
    return result;
  }

  // ---------------- GMB Reviews Subcollection ----------------

  CollectionReference<Map<String, dynamic>> _reviewsRef(String userId) =>
      _collection.doc(userId).collection('reviews');

  Stream<List<GmbReviewModel>> watchReviews() {
    return Stream.fromFuture(resolveUserId())
        .asyncExpand((userId) async* {
          final profile = await getProfile(userId);
          await seedDefaultReviewsIfNeeded(userId, profile.businessName, profile.city);
          yield* _reviewsRef(userId)
              .orderBy('createdAt', descending: true)
              .snapshots()
              .map((snap) => snap.docs.map((d) => GmbReviewModel.fromMap(d.data(), d.id)).toList());
        })
        .handleError((Object e) {
          debugPrint('watchReviews error: $e');
        })
        .asBroadcastStream();
  }

  Future<void> seedDefaultReviewsIfNeeded(String userId, String businessName, String city) async {
    try {
      final existing = await _reviewsRef(userId).limit(1).get();
      if (existing.docs.isNotEmpty) return;

      final biz = businessName.isNotEmpty ? businessName : 'your showroom';
      final loc = city.isNotEmpty ? city : 'the city';
      final now = DateTime.now();

      final sampleReviews = [
        GmbReviewModel(
          id: 'rev_1',
          reviewerName: 'Amit Verma',
          starRating: 5,
          comment:
              'Best collection and genuine wholesale rates at $biz in $loc! Staff behaviour is very polite and helpful.',
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
        GmbReviewModel(
          id: 'rev_2',
          reviewerName: 'Priya Gupta',
          starRating: 4,
          comment:
              'Good quality products and timely delivery. Would love to see more new designs next time.',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        GmbReviewModel(
          id: 'rev_3',
          reviewerName: 'Rajesh Sharma',
          starRating: 5,
          comment: 'Highly recommended store in $loc! Great variety and reasonable pricing.',
          replyText:
              'Thank you so much Rajesh ji for your 5-star review! We are glad you liked our collection and pricing. Visit us again!',
          isAutoReplied: true,
          createdAt: now.subtract(const Duration(days: 2)),
          repliedAt: now.subtract(const Duration(days: 2)),
        ),
        GmbReviewModel(
          id: 'rev_4',
          reviewerName: 'Sandeep Yadav',
          starRating: 3,
          comment: 'Product quality is nice, but parking near the shop was a bit crowded in the evening.',
          createdAt: now.subtract(const Duration(days: 4)),
        ),
      ];

      for (final r in sampleReviews) {
        await _reviewsRef(userId).doc(r.id).set(r.toMap());
      }
    } catch (e) {
      debugPrint('Error seeding default reviews: $e');
    }
  }

  Future<void> addSimulatedReview({
    required String reviewerName,
    required int starRating,
    required String comment,
  }) async {
    try {
      final userId = await resolveUserId();
      final docRef = _reviewsRef(userId).doc();
      final review = GmbReviewModel(
        id: docRef.id,
        reviewerName: reviewerName,
        starRating: starRating,
        comment: comment,
        createdAt: DateTime.now(),
      );
      await docRef.set(review.toMap());
    } catch (e) {
      debugPrint('addSimulatedReview error: $e');
    }
  }

  Future<void> saveReviewReply({
    required String reviewId,
    required String replyText,
    bool isAutoReplied = false,
  }) async {
    try {
      final userId = await resolveUserId();
      final profile = await getProfile(userId);

      if (profile.isGmbConnected && profile.gmbAccessToken.isNotEmpty) {
        await _gmbService.postReviewReplyToGmb(
          accessToken: profile.gmbAccessToken,
          gmbLocationName: profile.gmbLocationName,
          reviewId: reviewId,
          replyText: replyText,
        );
      }

      await _reviewsRef(userId).doc(reviewId).set({
        'replyText': replyText,
        'isAutoReplied': isAutoReplied,
        'repliedAt': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('saveReviewReply error: $e');
    }
  }

  // ---------------- GMB Local Posts Subcollection ----------------

  CollectionReference<Map<String, dynamic>> _postsRef(String userId) =>
      _collection.doc(userId).collection('gmb_posts');

  Stream<List<GmbPostModel>> watchGmbPosts() {
    return Stream.fromFuture(resolveUserId())
        .asyncExpand((userId) => _postsRef(userId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snap) => snap.docs.map((d) => GmbPostModel.fromMap(d.data(), d.id)).toList()))
        .handleError((Object e) {
          debugPrint('watchGmbPosts error: $e');
        })
        .asBroadcastStream();
  }

  Future<void> publishGmbPost(GmbPostModel post) async {
    try {
      final userId = await resolveUserId();
      final profile = await getProfile(userId);

      if (profile.isGmbConnected && profile.gmbAccessToken.isNotEmpty) {
        await _gmbService.publishLocalPostToGmb(
          accessToken: profile.gmbAccessToken,
          gmbLocationName: profile.gmbLocationName,
          summary: '${post.title}\n\n${post.summary}\n\n${post.hashtags.join(" ")}',
          topicType: post.postType == 'OFFER'
              ? 'OFFER'
              : (post.postType == 'EVENT' ? 'EVENT' : 'STANDARD'),
          ctaType: post.ctaType,
          ctaUrl: profile.website,
        );
      }

      final docRef = post.id.isNotEmpty ? _postsRef(userId).doc(post.id) : _postsRef(userId).doc();
      await docRef.set(post.toMap());
    } catch (e) {
      debugPrint('publishGmbPost error: $e');
    }
  }
}
