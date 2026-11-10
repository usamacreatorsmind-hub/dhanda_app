import 'package:cloud_firestore/cloud_firestore.dart';

class GmbReviewModel {
  final String id;
  final String reviewerName;
  final int starRating;
  final String comment;
  final String? replyText;
  final bool isAutoReplied;
  final DateTime createdAt;
  final DateTime? repliedAt;

  const GmbReviewModel({
    required this.id,
    required this.reviewerName,
    required this.starRating,
    required this.comment,
    this.replyText,
    this.isAutoReplied = false,
    required this.createdAt,
    this.repliedAt,
  });

  bool get hasReply => replyText != null && replyText!.trim().isNotEmpty;

  factory GmbReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    return GmbReviewModel(
      id: docId,
      reviewerName: map['reviewerName'] as String? ?? 'Google Customer',
      starRating: (map['starRating'] as num?)?.toInt() ?? 5,
      comment: map['comment'] as String? ?? '',
      replyText: map['replyText'] as String?,
      isAutoReplied: map['isAutoReplied'] as bool? ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
              : DateTime.now()),
      repliedAt: map['repliedAt'] is Timestamp
          ? (map['repliedAt'] as Timestamp).toDate()
          : (map['repliedAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['repliedAt'] as int)
              : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewerName': reviewerName,
      'starRating': starRating,
      'comment': comment,
      'replyText': replyText,
      'isAutoReplied': isAutoReplied,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'repliedAt': repliedAt?.millisecondsSinceEpoch,
    };
  }
}

class GmbPostModel {
  final String id;
  final String title;
  final String posterHeadline;
  final String posterSubtext;
  final String summary;
  final String postType; // 'UPDATE', 'OFFER', 'EVENT', 'FESTIVAL'
  final String ctaType; // 'CALL', 'LEARN_MORE', 'ORDER', 'BOOK'
  final List<String> hashtags;
  final List<String> seoKeywords;
  final int themeIndex;
  final String status; // 'Published on GMB', 'Scheduled'
  final DateTime createdAt;

  const GmbPostModel({
    required this.id,
    required this.title,
    required this.posterHeadline,
    required this.posterSubtext,
    required this.summary,
    this.postType = 'UPDATE',
    this.ctaType = 'CALL',
    this.hashtags = const [],
    this.seoKeywords = const [],
    this.themeIndex = 0,
    this.status = 'Published on GMB',
    required this.createdAt,
  });

  factory GmbPostModel.fromMap(Map<String, dynamic> map, String docId) {
    return GmbPostModel(
      id: docId,
      title: map['title'] as String? ?? 'Business Update',
      posterHeadline: map['posterHeadline'] as String? ?? 'Quality & Trust',
      posterSubtext: map['posterSubtext'] as String? ?? 'Visit our store today!',
      summary: map['summary'] as String? ?? '',
      postType: map['postType'] as String? ?? 'UPDATE',
      ctaType: map['ctaType'] as String? ?? 'CALL',
      hashtags: List<String>.from(map['hashtags'] ?? const []),
      seoKeywords: List<String>.from(map['seoKeywords'] ?? const []),
      themeIndex: (map['themeIndex'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'Published on GMB',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'posterHeadline': posterHeadline,
      'posterSubtext': posterSubtext,
      'summary': summary,
      'postType': postType,
      'ctaType': ctaType,
      'hashtags': hashtags,
      'seoKeywords': seoKeywords,
      'themeIndex': themeIndex,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}

class BusinessProfileModel {
  final String userId;
  final String businessName;
  final String primaryPhone;
  final String primaryCategory;
  final List<String> additionalCategories;
  final List<String> topSellingItems;
  final List<String> seoKeywords;
  final String businessDescription;
  final String city;
  final String openingDate;
  final String regularHours;
  final List<String> photos;
  final List<String> videos;
  final String website;
  final String address;
  final String additionalInfo;
  final String communicationPhone;
  final String founderName;
  final String founderGender;
  final String aiReplySalutation;
  final bool supportBranding;
  final bool autoSync;
  final bool aiWatermark;
  final bool notifications;
  final bool autoReplyEnabled;
  final bool autoPostEnabled;
  final String connectedGmail;
  final String gmbLocationName;
  final String gmbAccessToken;
  final bool isGmbConnected;
  final double? googleBusinessRating;
  final DateTime? updatedAt;

  const BusinessProfileModel({
    required this.userId,
    this.businessName = '',
    this.primaryPhone = '',
    this.primaryCategory = '',
    this.additionalCategories = const [],
    this.topSellingItems = const [],
    this.seoKeywords = const [],
    this.businessDescription = '',
    this.city = '',
    this.openingDate = '',
    this.regularHours = '',
    this.photos = const [],
    this.videos = const [],
    this.website = '',
    this.address = '',
    this.additionalInfo = '',
    this.communicationPhone = '',
    this.founderName = '',
    this.founderGender = 'Male',
    this.aiReplySalutation = '',
    this.supportBranding = false,
    this.autoSync = true,
    this.aiWatermark = true,
    this.notifications = true,
    this.autoReplyEnabled = true,
    this.autoPostEnabled = true,
    this.connectedGmail = '',
    this.gmbLocationName = '',
    this.gmbAccessToken = '',
    this.isGmbConnected = false,
    this.googleBusinessRating,
    this.updatedAt,
  });

  /// Calculates Google Business Profile Health / Audit Score (0 to 100)
  int get profileAuditScore {
    int score = 20;
    if (businessName.isNotEmpty) score += 10;
    if (primaryPhone.isNotEmpty) score += 10;
    if (primaryCategory.isNotEmpty) score += 10;
    if (address.isNotEmpty || city.isNotEmpty) score += 10;
    if (regularHours.isNotEmpty) score += 10;
    if (website.isNotEmpty) score += 5;
    if (businessDescription.isNotEmpty) score += 10;
    if (seoKeywords.isNotEmpty || topSellingItems.isNotEmpty) score += 10;
    if (isGmbConnected) score += 5;
    return score.clamp(0, 100);
  }

  factory BusinessProfileModel.fromMap(Map<String, dynamic> map, String id) {
    return BusinessProfileModel(
      userId: id,
      businessName: map['businessName'] as String? ?? '',
      primaryPhone: map['primaryPhone'] as String? ?? '',
      primaryCategory: map['primaryCategory'] as String? ?? '',
      additionalCategories: List<String>.from(map['additionalCategories'] ?? []),
      topSellingItems: List<String>.from(map['topSellingItems'] ?? []),
      seoKeywords: List<String>.from(map['seoKeywords'] ?? []),
      businessDescription: map['businessDescription'] as String? ?? '',
      city: map['city'] as String? ?? '',
      openingDate: map['openingDate'] as String? ?? '',
      regularHours: map['regularHours'] as String? ?? '',
      photos: List<String>.from(map['photos'] ?? []),
      videos: List<String>.from(map['videos'] ?? []),
      website: map['website'] as String? ?? '',
      address: map['address'] as String? ?? '',
      additionalInfo: map['additionalInfo'] as String? ?? '',
      communicationPhone: map['communicationPhone'] as String? ?? '',
      founderName: map['founderName'] as String? ?? '',
      founderGender: map['founderGender'] as String? ?? 'Male',
      aiReplySalutation: map['aiReplySalutation'] as String? ?? '',
      supportBranding: map['supportBranding'] as bool? ?? false,
      autoSync: map['autoSync'] as bool? ?? true,
      aiWatermark: map['aiWatermark'] as bool? ?? true,
      notifications: map['notifications'] as bool? ?? true,
      autoReplyEnabled: map['autoReplyEnabled'] as bool? ?? true,
      autoPostEnabled: map['autoPostEnabled'] as bool? ?? true,
      connectedGmail: map['connectedGmail'] as String? ?? '',
      gmbLocationName: map['gmbLocationName'] as String? ?? '',
      gmbAccessToken: map['gmbAccessToken'] as String? ?? '',
      isGmbConnected: map['isGmbConnected'] as bool? ?? false,
      googleBusinessRating: (map['googleBusinessRating'] as num?)?.toDouble(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['updatedAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'businessName': businessName,
      'primaryPhone': primaryPhone,
      'primaryCategory': primaryCategory,
      'additionalCategories': additionalCategories,
      'topSellingItems': topSellingItems,
      'seoKeywords': seoKeywords,
      'businessDescription': businessDescription,
      'city': city,
      'openingDate': openingDate,
      'regularHours': regularHours,
      'photos': photos,
      'videos': videos,
      'website': website,
      'address': address,
      'additionalInfo': additionalInfo,
      'communicationPhone': communicationPhone,
      'founderName': founderName,
      'founderGender': founderGender,
      'aiReplySalutation': aiReplySalutation,
      'supportBranding': supportBranding,
      'autoSync': autoSync,
      'aiWatermark': aiWatermark,
      'notifications': notifications,
      'autoReplyEnabled': autoReplyEnabled,
      'autoPostEnabled': autoPostEnabled,
      'connectedGmail': connectedGmail,
      'gmbLocationName': gmbLocationName,
      'gmbAccessToken': gmbAccessToken,
      'isGmbConnected': isGmbConnected,
      'googleBusinessRating': googleBusinessRating,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  BusinessProfileModel copyWith({
    String? userId,
    String? businessName,
    String? primaryPhone,
    String? primaryCategory,
    List<String>? additionalCategories,
    List<String>? topSellingItems,
    List<String>? seoKeywords,
    String? businessDescription,
    String? city,
    String? openingDate,
    String? regularHours,
    List<String>? photos,
    List<String>? videos,
    String? website,
    String? address,
    String? additionalInfo,
    String? communicationPhone,
    String? founderName,
    String? founderGender,
    String? aiReplySalutation,
    bool? supportBranding,
    bool? autoSync,
    bool? aiWatermark,
    bool? notifications,
    bool? autoReplyEnabled,
    bool? autoPostEnabled,
    String? connectedGmail,
    String? gmbLocationName,
    String? gmbAccessToken,
    bool? isGmbConnected,
    double? googleBusinessRating,
    DateTime? updatedAt,
  }) {
    return BusinessProfileModel(
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      primaryPhone: primaryPhone ?? this.primaryPhone,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      additionalCategories: additionalCategories ?? this.additionalCategories,
      topSellingItems: topSellingItems ?? this.topSellingItems,
      seoKeywords: seoKeywords ?? this.seoKeywords,
      businessDescription: businessDescription ?? this.businessDescription,
      city: city ?? this.city,
      openingDate: openingDate ?? this.openingDate,
      regularHours: regularHours ?? this.regularHours,
      photos: photos ?? this.photos,
      videos: videos ?? this.videos,
      website: website ?? this.website,
      address: address ?? this.address,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      communicationPhone: communicationPhone ?? this.communicationPhone,
      founderName: founderName ?? this.founderName,
      founderGender: founderGender ?? this.founderGender,
      aiReplySalutation: aiReplySalutation ?? this.aiReplySalutation,
      supportBranding: supportBranding ?? this.supportBranding,
      autoSync: autoSync ?? this.autoSync,
      aiWatermark: aiWatermark ?? this.aiWatermark,
      notifications: notifications ?? this.notifications,
      autoReplyEnabled: autoReplyEnabled ?? this.autoReplyEnabled,
      autoPostEnabled: autoPostEnabled ?? this.autoPostEnabled,
      connectedGmail: connectedGmail ?? this.connectedGmail,
      gmbLocationName: gmbLocationName ?? this.gmbLocationName,
      gmbAccessToken: gmbAccessToken ?? this.gmbAccessToken,
      isGmbConnected: isGmbConnected ?? this.isGmbConnected,
      googleBusinessRating: googleBusinessRating ?? this.googleBusinessRating,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
