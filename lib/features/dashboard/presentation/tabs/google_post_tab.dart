import 'package:flutter/material.dart';
import '../../../../core/services/gmb_service.dart';
import '../../../../core/services/openai_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../../business_profile/data/models/business_profile_model.dart';
import '../../../business_profile/data/repositories/business_profile_repository.dart';
import '../widgets/app_drawer.dart';

class GooglePostTab extends StatefulWidget {
  const GooglePostTab({super.key});

  @override
  State<GooglePostTab> createState() => _GooglePostTabState();
}

class _GooglePostTabState extends State<GooglePostTab> {
  final BusinessProfileRepository _repository = BusinessProfileRepository();
  final OpenAiService _openAiService = OpenAiService();
  final GmbService _gmbService = GmbService();

  bool _isAutoPosting = false;
  bool _isGeneratingKeywords = false;
  List<SeoKeywordItem> _discoveredKeywords = const [];

  Future<void> _triggerInstantAutoPost(BusinessProfileModel profile) async {
    setState(() => _isAutoPosting = true);
    try {
      final generated = await _openAiService.generateGmbPost(
        businessName: profile.businessName,
        category: profile.primaryCategory,
        city: profile.city,
        topSellingItems: profile.topSellingItems.isNotEmpty
            ? profile.topSellingItems
            : profile.seoKeywords,
        postType: 'UPDATE',
        customTopic: 'Weekly GMB Local SEO Update highlighting our top products and customer trust',
      );

      final post = GmbPostModel(
        id: '',
        title: generated.title,
        posterHeadline: generated.posterHeadline,
        posterSubtext: generated.posterSubtext,
        summary: generated.caption,
        postType: 'UPDATE',
        ctaType: generated.ctaType,
        hashtags: generated.hashtags,
        seoKeywords: generated.seoKeywordsUsed,
        status: 'Published on GMB',
        createdAt: DateTime.now(),
      );

      await _repository.publishGmbPost(post);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New SEO Google Post generated & published to GMB!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAutoPosting = false);
      }
    }
  }

  Future<void> _generateAndApplySeoKeywords(BusinessProfileModel profile) async {
    setState(() => _isGeneratingKeywords = true);
    try {
      final seoPkg = await _openAiService.generateSeoKeywordsAndDescription(
        businessName: profile.businessName,
        category: profile.primaryCategory,
        city: profile.city,
        topSellingItems: profile.topSellingItems,
        additionalCategories: profile.additionalCategories,
      );

      final keywordStrings = seoPkg.keywords
          .map((e) => e.keyword)
          .where((k) => k.isNotEmpty)
          .toList();
      final mergedCategories = {
        ...profile.additionalCategories,
        ...seoPkg.suggestedCategories,
      }.toList();

      if (profile.isGmbConnected && profile.gmbAccessToken.isNotEmpty) {
        await _gmbService.updateGmbDescriptionAndKeywords(
          accessToken: profile.gmbAccessToken,
          gmbLocationName: profile.gmbLocationName,
          seoDescription: seoPkg.seoDescription,
        );
      }

      await _repository.saveProfile(
        profile.copyWith(
          seoKeywords: keywordStrings,
          businessDescription: seoPkg.seoDescription,
          additionalCategories: mergedCategories,
        ),
      );

      if (!mounted) return;
      setState(() {
        _discoveredKeywords = seoPkg.keywords;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Updated ${keywordStrings.length} SEO Keywords & Business Description on GMB!',
          ),
          backgroundColor: AppTheme.success,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGeneratingKeywords = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BusinessProfileModel>(
      stream: _repository.watchCurrentUserProfile(),
      builder: (context, profileSnap) {
        final profile = profileSnap.data ?? const BusinessProfileModel(userId: 'guest_user');

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          drawer: const AppDrawer(),
          appBar: buildPremiumAppBar(
            context,
            title: 'GMB Auto-Post & SEO',
            subtitle: profile.businessName.isNotEmpty
                ? '${profile.businessName} • ${profile.city.isNotEmpty ? profile.city : "Local SEO"}'
                : 'Google Business Profile Automation',
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAutoPostCard(profile),
              const SizedBox(height: 16),

              _buildSeoKeywordsCard(profile),
              const SizedBox(height: 22),

              const SectionHeader(title: 'Published Posts on Google Business'),
              const SizedBox(height: 10),
              StreamBuilder<List<GmbPostModel>>(
                stream: _repository.watchGmbPosts(),
                builder: (context, postsSnap) {
                  final posts = postsSnap.data ?? const [];
                  if (posts.isEmpty) {
                    return SurfaceCard(
                      padding: const EdgeInsets.all(28),
                      child: const Column(
                        children: [
                          SoftIconBadge(
                            icon: Icons.article_outlined,
                            iconColor: AppTheme.textMuted,
                            backgroundColor: AppTheme.surfaceMuted,
                            size: 26,
                            padding: 14,
                            borderRadius: 16,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No GMB posts published yet',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap "1-Click Auto-Post to GMB Now" above to publish your first SEO update.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: posts.map((post) => _buildGmbPostItem(post, profile)).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAutoPostCard(BusinessProfileModel profile) {
    return TonalHeroCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SoftIconBadge(
                icon: Icons.campaign_rounded,
                iconColor: AppTheme.primaryColor,
                backgroundColor: Colors.white,
                size: 21,
                padding: 10,
                borderRadius: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly GMB Auto-Post',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.autoPostEnabled
                          ? 'Active • Keeps your Google Maps listing ranking high'
                          : 'Paused • Enable to auto-publish weekly updates',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: profile.autoPostEnabled,
                onChanged: (val) {
                  _repository.saveProfile(profile.copyWith(autoPostEnabled: val));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isAutoPosting ? null : () => _triggerInstantAutoPost(profile),
            icon: _isAutoPosting
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded, size: 18),
            label: Text(
              _isAutoPosting
                  ? 'Generating & publishing GMB Post...'
                  : '1-Click Auto-Post to GMB Now',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeoKeywordsCard(BusinessProfileModel profile) {
    final activeKeywords = profile.seoKeywords;

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SoftIconBadge(
                icon: Icons.trending_up_rounded,
                size: 20,
                padding: 9,
                borderRadius: 11,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Local SEO Keywords & Description',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Injects high-ranking search keywords into your GMB listing',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_discoveredKeywords.isNotEmpty) ...[
            const Text(
              'Search Volume & Buyer Intent Analysis',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ..._discoveredKeywords.take(5).map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceMuted,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.keyword,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        StatusPill(
                          label: item.monthlyVolume,
                          textColor: AppTheme.success,
                          backgroundColor: AppTheme.successSoft,
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 8),
          ] else if (activeKeywords.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: activeKeywords
                  .map(
                    (k) => StatusPill(
                      label: k,
                      textColor: AppTheme.primaryDark,
                      backgroundColor: AppTheme.primarySoft,
                      borderColor: AppTheme.primaryBorder,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
          ],

          if (profile.businessDescription.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active GMB SEO Description',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.businessDescription,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isGeneratingKeywords ? null : () => _generateAndApplySeoKeywords(profile),
            icon: _isGeneratingKeywords
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_fix_high_rounded, size: 17),
            label: Text(
              _isGeneratingKeywords
                  ? 'Analyzing Local Keywords...'
                  : 'Generate & Update GMB Keywords',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGmbPostItem(GmbPostModel post, BusinessProfileModel profile) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(
                label: post.status,
                icon: Icons.check_circle_rounded,
                textColor: AppTheme.success,
                backgroundColor: AppTheme.successSoft,
                borderColor: AppTheme.successBorder,
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: post.postType,
                textColor: AppTheme.primaryColor,
                backgroundColor: AppTheme.primarySoft,
              ),
              const Spacer(),
              StatusPill(
                label: 'CTA: ${post.ctaType}',
                textColor: AppTheme.secondaryColor,
                backgroundColor: AppTheme.secondarySoft,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15.5,
              color: AppTheme.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            post.summary,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textSecondary,
              height: 1.45,
            ),
          ),
          if (post.seoKeywords.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: post.seoKeywords
                  .map(
                    (k) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Text(
                        '# $k',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
