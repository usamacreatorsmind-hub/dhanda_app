import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class GeneratedGmbPostContent {
  final String title;
  final String posterHeadline;
  final String posterSubtext;
  final String caption;
  final List<String> hashtags;
  final List<String> seoKeywordsUsed;
  final String ctaType;

  const GeneratedGmbPostContent({
    required this.title,
    required this.posterHeadline,
    required this.posterSubtext,
    required this.caption,
    required this.hashtags,
    required this.seoKeywordsUsed,
    required this.ctaType,
  });

  factory GeneratedGmbPostContent.fromJson(Map<String, dynamic> json) {
    return GeneratedGmbPostContent(
      title: json['title'] as String? ?? 'Special Update',
      posterHeadline: json['posterHeadline'] as String? ?? 'Best Quality & Trusted Service',
      posterSubtext: json['posterSubtext'] as String? ?? 'Visit our store today for exclusive offers!',
      caption: json['caption'] as String? ?? '',
      hashtags: (json['hashtags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      seoKeywordsUsed: (json['seoKeywordsUsed'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      ctaType: json['ctaType'] as String? ?? 'CALL',
    );
  }
}

class SeoKeywordItem {
  final String keyword;
  final String intent;
  final String monthlyVolume;

  const SeoKeywordItem({
    required this.keyword,
    required this.intent,
    required this.monthlyVolume,
  });

  factory SeoKeywordItem.fromJson(Map<String, dynamic> json) {
    return SeoKeywordItem(
      keyword: json['keyword'] as String? ?? '',
      intent: json['intent'] as String? ?? 'High Local Intent',
      monthlyVolume: json['monthlyVolume'] as String? ?? '450+ searches/mo',
    );
  }
}

class GeneratedSeoPackage {
  final List<SeoKeywordItem> keywords;
  final String seoDescription;
  final List<String> suggestedCategories;

  const GeneratedSeoPackage({
    required this.keywords,
    required this.seoDescription,
    required this.suggestedCategories,
  });

  factory GeneratedSeoPackage.fromJson(Map<String, dynamic> json) {
    final rawKeywords = json['keywords'] as List<dynamic>? ?? const [];
    return GeneratedSeoPackage(
      keywords: rawKeywords
          .map((e) => SeoKeywordItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      seoDescription: json['seoDescription'] as String? ?? '',
      suggestedCategories:
          (json['suggestedCategories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

class OpenAiService {
  final http.Client _client;

  OpenAiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _postChatJson({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.7,
  }) async {
    if (ApiConfig.openAiApiKey.isEmpty) {
      throw StateError('OPENAI_API_KEY is not configured');
    }
    final response = await _client
        .post(
          Uri.parse(ApiConfig.openAiChatEndpoint),
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer ${ApiConfig.openAiApiKey}',
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'model': ApiConfig.openAiModel,
            'response_format': {'type': 'json_object'},
            'temperature': temperature,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userPrompt},
            ],
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        final message = choices.first['message'] as Map<String, dynamic>?;
        final content = message?['content'] as String?;
        if (content != null && content.isNotEmpty) {
          return jsonDecode(content) as Map<String, dynamic>;
        }
      }
      throw Exception('Empty response from OpenAI');
    } else {
      throw Exception('OpenAI API error (${response.statusCode}): ${response.body}');
    }
  }

  /// 1. GMB Auto Review Reply Generator (SEO-Optimized)
  Future<String> generateReviewReply({
    required String reviewerName,
    required int starRating,
    required String reviewComment,
    required String businessName,
    required String city,
    required String category,
    required List<String> topSellingItems,
    String salutation = '',
    String replyLanguage = 'English', // 'English', 'Hinglish', 'Hindi'
  }) async {
    final itemsStr = topSellingItems.isNotEmpty ? topSellingItems.join(', ') : category;
    final systemPrompt = '''
You are Dhanda AI, an expert Google Business Profile (GMB) Local SEO assistant for Indian businesses.
Write a warm, human-like, local-SEO-optimized reply to a customer's Google review.
Naturally weave in 1-2 relevant business keywords ($itemsStr in $city) to improve Google Maps ranking without sounding robotic.
Return strictly a JSON object: {"reply": "your generated reply string"}
''';

    final userPrompt = '''
Business Name: ${businessName.isEmpty ? 'Our Store' : businessName}
Category: ${category.isEmpty ? 'Local Business' : category}
City: ${city.isEmpty ? 'India' : city}
Top Selling Products/Keywords: $itemsStr
Preferred Salutation/Closing: ${salutation.isEmpty ? 'Warm regards' : salutation}
Customer Name: $reviewerName
Star Rating: $starRating / 5 stars
Customer Review: "${reviewComment.isEmpty ? 'Rated $starRating stars without text' : reviewComment}"
Reply Language: $replyLanguage (Keep it concise: 2 to 3 sentences).
''';

    try {
      final json = await _postChatJson(systemPrompt: systemPrompt, userPrompt: userPrompt);
      final reply = (json['reply'] as String?)?.trim();
      if (reply != null && reply.isNotEmpty) {
        return reply;
      }
    } catch (e) {
      debugPrint('OpenAI generateReviewReply error: $e');
    }

    // Fallback if offline
    final biz = businessName.isNotEmpty ? businessName : 'our store';
    final loc = city.isNotEmpty ? ' in $city' : '';
    final keyword = topSellingItems.isNotEmpty ? topSellingItems.first : (category.isNotEmpty ? category : 'products');
    if (starRating >= 4) {
      return 'Thank you so much $reviewerName for your $starRating-star rating! We are delighted you loved our $keyword at $biz$loc. ${salutation.isNotEmpty ? salutation : "Visit us again soon!"}';
    } else {
      return 'Dear $reviewerName, thank you for sharing your feedback with $biz$loc. We strive to provide the best $keyword experience and would love to resolve your concern immediately. ${salutation.isNotEmpty ? salutation : "Please contact our store team."}';
    }
  }

  /// 2. GMB Auto-Post & AI Poster Content Generator
  Future<GeneratedGmbPostContent> generateGmbPost({
    required String businessName,
    required String category,
    required String city,
    required List<String> topSellingItems,
    required String postType, // 'UPDATE', 'OFFER', 'EVENT', 'FESTIVAL'
    String customTopic = '',
    String language = 'English', // 'English', 'Hinglish', 'Hindi'
  }) async {
    final itemsStr = topSellingItems.isNotEmpty ? topSellingItems.join(', ') : category;
    final systemPrompt = '''
You are Dhanda AI, a Google Business Profile (GMB) & Social Media Marketing specialist.
Create a high-converting Google Business Local Post and Poster copy optimized for Google Maps Local SEO.
Return strictly a JSON object with these keys:
{
  "title": "Short post title (max 58 chars)",
  "posterHeadline": "Catchy 4-7 word headline for the visual poster",
  "posterSubtext": "Short 8-14 word subtext/offer line for the poster",
  "caption": "Engaging 70-110 word GMB post description naturally containing local SEO keywords",
  "hashtags": ["#tag1", "#tag2", "#tag3", "#tag4", "#tag5"],
  "seoKeywordsUsed": ["keyword 1", "keyword 2", "keyword 3"],
  "ctaType": "CALL"
}
''';

    final userPrompt = '''
Business Name: ${businessName.isEmpty ? 'My Business Store' : businessName}
Category: ${category.isEmpty ? 'Retail & Services' : category}
City: ${city.isEmpty ? 'Noida' : city}
Top Selling Items / Keywords: $itemsStr
Post Type: $postType
Topic / Offer Idea: ${customTopic.isEmpty ? 'Highlight our best selling $itemsStr in $city with special customer value' : customTopic}
Language: $language
''';

    try {
      final json = await _postChatJson(systemPrompt: systemPrompt, userPrompt: userPrompt);
      return GeneratedGmbPostContent.fromJson(json);
    } catch (e) {
      debugPrint('OpenAI generateGmbPost error: $e');
      final biz = businessName.isNotEmpty ? businessName : 'Our Store';
      final loc = city.isNotEmpty ? city : 'Your City';
      final item = topSellingItems.isNotEmpty ? topSellingItems.first : 'Quality Products';
      return GeneratedGmbPostContent(
        title: 'Best $item at $biz, $loc',
        posterHeadline: 'Upgrade With Premium $item!',
        posterSubtext: 'Trusted quality & best wholesale prices at $biz, $loc.',
        caption:
            'Looking for the best $item in $loc? Visit $biz today! We offer a wide range of ${topSellingItems.isNotEmpty ? topSellingItems.join(", ") : item} with assured quality and expert guidance. Call us or visit our showroom in $loc for special deals!',
        hashtags: [
          '#${biz.replaceAll(' ', '')}',
          '#${item.replaceAll(' ', '')}',
          '#$loc',
          '#LocalBusiness',
          '#BestDeals',
        ],
        seoKeywordsUsed: ['Best $item in $loc', '$biz $loc', '$item showroom near me'],
        ctaType: 'CALL',
      );
    }
  }

  /// 3. GMB SEO Keywords & Business Description Optimizer
  Future<GeneratedSeoPackage> generateSeoKeywordsAndDescription({
    required String businessName,
    required String category,
    required String city,
    required List<String> topSellingItems,
    List<String> additionalCategories = const [],
  }) async {
    final itemsStr = topSellingItems.isNotEmpty ? topSellingItems.join(', ') : category;
    final systemPrompt = '''
You are Dhanda AI, a Google Maps & GMB Local SEO Ranking Expert.
Analyze the business details and generate:
1. Top 10 high-search-volume local keywords customers search on Google Maps.
2. An SEO-optimized 600-720 character Google Business Profile description naturally incorporating those keywords.
3. 4 recommended additional GMB categories.
Return strictly JSON:
{
  "keywords": [
    {"keyword": "best marble shop in Noida", "intent": "High Buyer Intent", "monthlyVolume": "1.2K/mo"}
  ],
  "seoDescription": "Full SEO business description...",
  "suggestedCategories": ["Category 1", "Category 2", "Category 3", "Category 4"]
}
''';

    final userPrompt = '''
Business Name: ${businessName.isEmpty ? 'My Business' : businessName}
Primary Category: ${category.isEmpty ? 'Retail Store' : category}
Additional Categories: ${additionalCategories.join(', ')}
City / Area: ${city.isEmpty ? 'Delhi NCR' : city}
Top Selling Items / Services: $itemsStr
''';

    try {
      final json = await _postChatJson(systemPrompt: systemPrompt, userPrompt: userPrompt);
      return GeneratedSeoPackage.fromJson(json);
    } catch (e) {
      debugPrint('OpenAI generateSeoKeywordsAndDescription error: $e');
      final biz = businessName.isNotEmpty ? businessName : 'Our Store';
      final loc = city.isNotEmpty ? city : 'Noida';
      final item = topSellingItems.isNotEmpty ? topSellingItems.first : (category.isNotEmpty ? category : 'Store');
      return GeneratedSeoPackage(
        keywords: [
          SeoKeywordItem(keyword: 'Best $item in $loc', intent: 'High Buyer Intent', monthlyVolume: '1.4K/mo'),
          SeoKeywordItem(keyword: '$item showroom near me', intent: 'Google Maps Near Me', monthlyVolume: '980/mo'),
          SeoKeywordItem(keyword: 'Wholesale $item dealer in $loc', intent: 'Commercial Intent', monthlyVolume: '640/mo'),
          SeoKeywordItem(keyword: '$biz $loc contact number', intent: 'Brand Search', monthlyVolume: '420/mo'),
        ],
        seoDescription:
            '$biz is a trusted destination for premium $itemsStr in $loc. We specialize in top-quality products, competitive pricing, and reliable customer service. Visit our store in $loc today!',
        suggestedCategories: ['Wholesaler', 'Home Improvement Store', 'Supplier', 'Showroom'],
      );
    }
  }
}

