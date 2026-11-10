import 'package:flutter/material.dart';
import '../../../../core/services/openai_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../../business_profile/data/models/business_profile_model.dart';
import '../../../business_profile/data/repositories/business_profile_repository.dart';
import '../widgets/app_drawer.dart';

class AiPostTab extends StatefulWidget {
  const AiPostTab({super.key});

  @override
  State<AiPostTab> createState() => _AiPostTabState();
}

class _AiPostTabState extends State<AiPostTab> {
  final BusinessProfileRepository _repository = BusinessProfileRepository();
  final OpenAiService _openAiService = OpenAiService();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();

  String _selectedPostType = 'OFFER'; // 'UPDATE', 'OFFER', 'FESTIVAL', 'EVENT'
  String _selectedLanguage = 'English';
  int _selectedThemeIndex = 0;
  bool _isGenerating = false;
  bool _isPublishing = false;

  String _posterHeadline = 'Best Quality & Wholesale Prices!';
  String _posterSubtext = 'Visit our showroom today for exclusive deals & trusted service.';
  String _postTitle = 'Special Offer Update';
  List<String> _hashtags = const ['#LocalBusiness', '#BestQuality', '#SpecialOffer'];
  List<String> _seoKeywordsUsed = const [];

  // Curated, low-saturation editorial poster themes instead of punchy neon gradients
  static const List<List<Color>> _posterGradients = [
    [Color(0xFF3E4B7A), Color(0xFF56669E)], // Muted Slate Indigo
    [Color(0xFF8C5B44), Color(0xFFA97258)], // Warm Terracotta Sand
    [Color(0xFF345B4E), Color(0xFF477767)], // Botanical Sage
    [Color(0xFF333B4A), Color(0xFF4B5568)], // Soft Graphite Slate
  ];

  @override
  void dispose() {
    _topicController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _generateWithOpenAi(BusinessProfileModel profile) async {
    setState(() => _isGenerating = true);
    try {
      final generated = await _openAiService.generateGmbPost(
        businessName: profile.businessName,
        category: profile.primaryCategory,
        city: profile.city,
        topSellingItems: profile.topSellingItems.isNotEmpty
            ? profile.topSellingItems
            : profile.seoKeywords,
        postType: _selectedPostType,
        customTopic: _topicController.text.trim(),
        language: _selectedLanguage,
      );

      if (!mounted) return;
      setState(() {
        _postTitle = generated.title;
        _posterHeadline = generated.posterHeadline;
        _posterSubtext = generated.posterSubtext;
        _hashtags = generated.hashtags;
        _seoKeywordsUsed = generated.seoKeywordsUsed;
        _captionController.text =
            '${generated.caption}\n\n${generated.hashtags.join(' ')}';
      });
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _publishPost(BusinessProfileModel profile) async {
    setState(() => _isPublishing = true);
    try {
      final post = GmbPostModel(
        id: '',
        title: _postTitle,
        posterHeadline: _posterHeadline,
        posterSubtext: _posterSubtext,
        summary: _captionController.text.trim().isNotEmpty
            ? _captionController.text.trim()
            : _posterSubtext,
        postType: _selectedPostType,
        ctaType: 'CALL',
        hashtags: _hashtags,
        seoKeywords: _seoKeywordsUsed.isNotEmpty
            ? _seoKeywordsUsed
            : profile.topSellingItems,
        themeIndex: _selectedThemeIndex,
        status: 'Published on GMB',
        createdAt: DateTime.now(),
      );

      await _repository.publishGmbPost(post);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI Poster & Local Post published to GMB and saved to Recent Designs!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BusinessProfileModel>(
      stream: _repository.watchCurrentUserProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data ?? const BusinessProfileModel(userId: 'guest_user');

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          drawer: const AppDrawer(),
          appBar: buildPremiumAppBar(
            context,
            title: 'AI Poster & Post Studio',
            subtitle: profile.businessName.isNotEmpty
                ? '${profile.businessName} • AI Creative Studio'
                : 'Generate Branded GMB & Social Posts',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPosterPreview(profile),
                const SizedBox(height: 14),

                // Theme Swatch Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Poster Palette',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ...List.generate(_posterGradients.length, (index) {
                      final isSelected = _selectedThemeIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedThemeIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              width: 1.8,
                            ),
                          ),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: _posterGradients[index]),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 18),

                // Prompt Controls Card
                SurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '1. Post Type & Language',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceMuted,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedLanguage,
                                isDense: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                  fontSize: 12.5,
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'English', child: Text('English')),
                                  DropdownMenuItem(value: 'Hinglish', child: Text('Hinglish')),
                                  DropdownMenuItem(value: 'Hindi', child: Text('हिंदी')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedLanguage = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTypeChip('Special Offer', 'OFFER', Icons.local_offer_outlined),
                          _buildTypeChip('Product Update', 'UPDATE', Icons.inventory_2_outlined),
                          _buildTypeChip('Festival Post', 'FESTIVAL', Icons.celebration_outlined),
                          _buildTypeChip('Store Event', 'EVENT', Icons.event_available_outlined),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _topicController,
                        decoration: const InputDecoration(
                          labelText: 'Offer / Topic / Festival Name (Optional)',
                          hintText: 'e.g., Flat 15% Off on Festive Collection',
                          prefixIcon: Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          minimumSize: const Size(double.infinity, 46),
                        ),
                        onPressed: _isGenerating ? null : () => _generateWithOpenAi(profile),
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome_rounded, size: 19),
                        label: Text(
                          _isGenerating
                              ? 'Designing Poster & SEO Copy...'
                              : 'Generate AI Poster & SEO Caption',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Caption & Publish Card
                SurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '2. AI Generated GMB & Social Caption',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_seoKeywordsUsed.isNotEmpty) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _seoKeywordsUsed
                              .map(
                                (k) => StatusPill(
                                  label: 'SEO: $k',
                                  textColor: AppTheme.primaryColor,
                                  backgroundColor: AppTheme.primarySoft,
                                  borderColor: AppTheme.primaryBorder,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 10),
                      ],
                      TextField(
                        controller: _captionController,
                        maxLines: 5,
                        style: const TextStyle(fontSize: 13.5, color: AppTheme.textPrimary, height: 1.45),
                        decoration: const InputDecoration(
                          hintText: 'Generated SEO caption and hashtags will appear here...',
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          minimumSize: const Size(double.infinity, 46),
                        ),
                        onPressed: _isPublishing ? null : () => _publishPost(profile),
                        icon: _isPublishing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.rocket_launch_rounded, size: 18),
                        label: const Text('Publish to Google Business Profile (GMB)'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPosterPreview(BusinessProfileModel profile) {
    final gradient = _posterGradients[_selectedThemeIndex % _posterGradients.length];
    final bizName = profile.businessName.isNotEmpty ? profile.businessName : 'My Business Store';
    final category = profile.primaryCategory.isNotEmpty ? profile.primaryCategory : 'Trusted Local Store';
    final phone = profile.primaryPhone.isNotEmpty ? profile.primaryPhone : '+91 98765 43210';
    final address = profile.address.isNotEmpty
        ? profile.address
        : (profile.city.isNotEmpty ? profile.city : 'Visit Our Store');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.storefront_rounded, color: gradient[0], size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bizName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.9,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _selectedPostType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            _posterHeadline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.22,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _posterSubtext,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),

          if (profile.topSellingItems.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: profile.topSellingItems.take(4).map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                  ),
                  child: Text(
                    '✓ $item',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Row(
              children: [
                Icon(Icons.call_rounded, color: Colors.white.withValues(alpha: 0.85), size: 15),
                const SizedBox(width: 6),
                Text(
                  phone,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.location_on_rounded, color: Colors.white.withValues(alpha: 0.85), size: 15),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String value, IconData icon) {
    final isSelected = _selectedPostType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPostType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryDark : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
