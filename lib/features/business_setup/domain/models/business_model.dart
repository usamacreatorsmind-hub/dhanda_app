import 'package:equatable/equatable.dart';

class BusinessModel extends Equatable {
  final String id;
  final String ownerUid;
  final String name;
  final String category;
  final String city;
  final String phone;
  final String? website;
  final String? logoUrl;
  final List<String> topSellingItems;
  final String? googleBusinessAddress;
  final double? googleBusinessRating;
  final DateTime createdAt;

  const BusinessModel({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.category,
    required this.city,
    required this.phone,
    this.website,
    this.logoUrl,
    this.topSellingItems = const [],
    this.googleBusinessAddress,
    this.googleBusinessRating,
    required this.createdAt,
  });

  factory BusinessModel.fromMap(Map<String, dynamic> map, String docId) {
    return BusinessModel(
      id: docId,
      ownerUid: map['ownerUid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? '',
      city: map['city'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      website: map['website'] as String?,
      logoUrl: map['logoUrl'] as String?,
      topSellingItems: (map['topSellingItems'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      googleBusinessAddress: map['googleBusinessAddress'] as String?,
      googleBusinessRating: (map['googleBusinessRating'] as num?)?.toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerUid': ownerUid,
      'name': name,
      'category': category,
      'city': city,
      'phone': phone,
      'website': website,
      'logoUrl': logoUrl,
      'topSellingItems': topSellingItems,
      'googleBusinessAddress': googleBusinessAddress,
      'googleBusinessRating': googleBusinessRating,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  BusinessModel copyWith({
    String? id,
    String? ownerUid,
    String? name,
    String? category,
    String? city,
    String? phone,
    String? website,
    String? logoUrl,
    List<String>? topSellingItems,
    String? googleBusinessAddress,
    double? googleBusinessRating,
    DateTime? createdAt,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      name: name ?? this.name,
      category: category ?? this.category,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      topSellingItems: topSellingItems ?? this.topSellingItems,
      googleBusinessAddress: googleBusinessAddress ?? this.googleBusinessAddress,
      googleBusinessRating: googleBusinessRating ?? this.googleBusinessRating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerUid,
        name,
        category,
        city,
        phone,
        website,
        logoUrl,
        topSellingItems,
        googleBusinessAddress,
        googleBusinessRating,
        createdAt,
      ];
}
