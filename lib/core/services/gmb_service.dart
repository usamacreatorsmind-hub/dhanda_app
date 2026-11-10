import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class GmbLocationSummary {
  final String name; // e.g., accounts/123/locations/456
  final String title;
  final String primaryCategory;
  final String address;
  final String phone;
  final String website;

  const GmbLocationSummary({
    required this.name,
    required this.title,
    this.primaryCategory = '',
    this.address = '',
    this.phone = '',
    this.website = '',
  });
}

class GmbConnectionResult {
  final String email;
  final String displayName;
  final String accessToken;
  final List<GmbLocationSummary> locations;
  final bool hasLiveApiQuota;

  const GmbConnectionResult({
    required this.email,
    required this.displayName,
    required this.accessToken,
    this.locations = const [],
    this.hasLiveApiQuota = false,
  });
}

class GmbService {
  final http.Client _client;
  final GoogleSignIn _googleSignIn;

  GmbService({http.Client? client, GoogleSignIn? googleSignIn})
      : _client = client ?? http.Client(),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: <String>[
                'email',
                'profile',
                ApiConfig.gmbManageScope,
              ],
            );

  /// SaaS Multi-Tenant Flow:
  /// Lets the logged-in merchant sign in with their own Gmail ID and grant
  /// `https://www.googleapis.com/auth/business.manage` permission.
  Future<GmbConnectionResult> connectUserGmailForGmb() async {
    try {
      // Sign out first so the SaaS user can explicitly pick their business Gmail account
      await _googleSignIn.signOut();
    } catch (_) {}

    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google Sign-In cancelled by user');
    }

    final GoogleSignInAuthentication auth = await account.authentication;
    final String accessToken = auth.accessToken ?? '';

    List<GmbLocationSummary> locations = [];
    bool hasLiveQuota = false;

    if (accessToken.isNotEmpty) {
      try {
        locations = await fetchUserGmbLocations(accessToken);
        hasLiveQuota = locations.isNotEmpty;
      } catch (e) {
        debugPrint('GMB API quota/fetch note (using hybrid Firestore sync): $e');
      }
    }

    return GmbConnectionResult(
      email: account.email,
      displayName: account.displayName ?? account.email.split('@').first,
      accessToken: accessToken,
      locations: locations,
      hasLiveApiQuota: hasLiveQuota,
    );
  }

  /// Fetches the user's GMB accounts and locations using their OAuth access token.
  Future<List<GmbLocationSummary>> fetchUserGmbLocations(String accessToken) async {
    final accountsRes = await _client.get(
      Uri.parse('${ApiConfig.gmbAccountManagementBaseUrl}/accounts'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    if (accountsRes.statusCode != 200) {
      throw Exception('GMB Accounts API returned ${accountsRes.statusCode}');
    }

    final accountsJson = jsonDecode(accountsRes.body) as Map<String, dynamic>;
    final accounts = accountsJson['accounts'] as List<dynamic>? ?? const [];
    final List<GmbLocationSummary> result = [];

    for (final acc in accounts) {
      final accountName = (acc as Map<String, dynamic>)['name'] as String?;
      if (accountName == null) continue;

      final locRes = await _client.get(
        Uri.parse(
          '${ApiConfig.gmbBusinessInfoBaseUrl}/$accountName/locations?readMask=name,title,categories,phoneNumbers,storefrontAddress,websiteUri',
        ),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      if (locRes.statusCode == 200) {
        final locJson = jsonDecode(locRes.body) as Map<String, dynamic>;
        final locs = locJson['locations'] as List<dynamic>? ?? const [];
        for (final rawLoc in locs) {
          final map = rawLoc as Map<String, dynamic>;
          final categories = map['categories'] as Map<String, dynamic>?;
          final primaryCat =
              (categories?['primaryCategory'] as Map<String, dynamic>?)?['displayName'] as String? ?? '';
          final phones = map['phoneNumbers'] as Map<String, dynamic>?;
          final primaryPhone = phones?['primaryPhone'] as String? ?? '';
          final addrMap = map['storefrontAddress'] as Map<String, dynamic>?;
          final addressLines = (addrMap?['addressLines'] as List<dynamic>?)?.join(', ') ?? '';
          final locality = addrMap?['locality'] as String? ?? '';

          result.add(
            GmbLocationSummary(
              name: map['name'] as String? ?? '',
              title: map['title'] as String? ?? 'My Google Business',
              primaryCategory: primaryCat,
              address: [addressLines, locality].where((s) => s.isNotEmpty).join(', '),
              phone: primaryPhone,
              website: map['websiteUri'] as String? ?? '',
            ),
          );
        }
      }
    }

    return result;
  }

  /// Publishes a review reply directly to Google Business Profile if live OAuth token & location exist.
  Future<bool> postReviewReplyToGmb({
    required String accessToken,
    required String gmbLocationName,
    required String reviewId,
    required String replyText,
  }) async {
    if (accessToken.isEmpty || gmbLocationName.isEmpty) return false;
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.gmbV4BaseUrl}/$gmbLocationName/reviews/$reviewId/reply'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'comment': replyText}),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('postReviewReplyToGmb fallback to Firestore: $e');
      return false;
    }
  }

  /// Publishes a Local Post (Update / Offer / Event) directly to Google Business Profile.
  Future<bool> publishLocalPostToGmb({
    required String accessToken,
    required String gmbLocationName,
    required String summary,
    required String topicType, // 'STANDARD', 'OFFER', 'EVENT'
    String ctaType = 'CALL',
    String? ctaUrl,
    String? mediaUrl,
  }) async {
    if (accessToken.isEmpty || gmbLocationName.isEmpty) return false;
    try {
      final Map<String, dynamic> payload = {
        'languageCode': 'en-IN',
        'summary': summary,
        'topicType': topicType,
        'callToAction': {
          'actionType': ctaType,
          if (ctaUrl != null && ctaUrl.isNotEmpty && ctaType != 'CALL') 'url': ctaUrl,
        },
        if (mediaUrl != null && mediaUrl.isNotEmpty)
          'media': [
            {
              'mediaFormat': 'PHOTO',
              'sourceUrl': mediaUrl,
            }
          ],
      };

      final response = await _client.post(
        Uri.parse('${ApiConfig.gmbV4BaseUrl}/$gmbLocationName/localPosts'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
        body: jsonEncode(payload),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('publishLocalPostToGmb fallback to Firestore: $e');
      return false;
    }
  }

  /// Updates Business Description (SEO Keywords) & Categories on Google Business Profile.
  Future<bool> updateGmbDescriptionAndKeywords({
    required String accessToken,
    required String gmbLocationName,
    required String seoDescription,
  }) async {
    if (accessToken.isEmpty || gmbLocationName.isEmpty) return false;
    try {
      final response = await _client.patch(
        Uri.parse('${ApiConfig.gmbBusinessInfoBaseUrl}/$gmbLocationName?updateMask=profile.description'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'profile': {'description': seoDescription},
        }),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('updateGmbDescriptionAndKeywords fallback to Firestore: $e');
      return false;
    }
  }
}

