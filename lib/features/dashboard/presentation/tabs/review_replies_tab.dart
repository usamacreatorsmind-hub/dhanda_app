import 'package:flutter/material.dart';
import '../../../../core/services/openai_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../../business_profile/data/models/business_profile_model.dart';
import '../../../business_profile/data/repositories/business_profile_repository.dart';
import '../widgets/app_drawer.dart';

class ReviewRepliesTab extends StatefulWidget {
  const ReviewRepliesTab({super.key});

  @override
  State<ReviewRepliesTab> createState() => _ReviewRepliesTabState();
}

class _ReviewRepliesTabState extends State<ReviewRepliesTab> {
  final BusinessProfileRepository _repository = BusinessProfileRepository();
  final OpenAiService _openAiService = OpenAiService();

  String _selectedFilter = 'All'; // 'All', 'Pending', 'Replied'
  String _replyLanguage = 'English'; // 'English', 'Hinglish', 'Hindi'
  bool _isBatchReplying = false;

  final Map<String, TextEditingController> _replyControllers = {};
  final Set<String> _generatingIds = {};
  final Set<String> _editingIds = {};

  @override
  void dispose() {
    for (final c in _replyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(GmbReviewModel review) {
    return _replyControllers.putIfAbsent(
      review.id,
      () => TextEditingController(text: review.replyText ?? ''),
    );
  }

  Future<void> _generateSingleReply(
    GmbReviewModel review,
    BusinessProfileModel profile,
  ) async {
    setState(() {
      _generatingIds.add(review.id);
      _editingIds.add(review.id);
    });

    try {
      final reply = await _openAiService.generateReviewReply(
        reviewerName: review.reviewerName,
        starRating: review.starRating,
        reviewComment: review.comment,
        businessName: profile.businessName,
        city: profile.city,
        category: profile.primaryCategory,
        topSellingItems: profile.topSellingItems.isNotEmpty
            ? profile.topSellingItems
            : profile.seoKeywords,
        salutation: profile.aiReplySalutation,
        replyLanguage: _replyLanguage,
      );

      if (!mounted) return;
      _controllerFor(review).text = reply;
    } finally {
      if (mounted) {
        setState(() => _generatingIds.remove(review.id));
      }
    }
  }

  Future<void> _postReply(GmbReviewModel review, {bool isAuto = false}) async {
    final text = _controllerFor(review).text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please generate or enter a reply first')),
      );
      return;
    }

    await _repository.saveReviewReply(
      reviewId: review.id,
      replyText: text,
      isAutoReplied: isAuto,
    );

    if (!mounted) return;
    setState(() => _editingIds.remove(review.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reply published to Google Business Profile!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  Future<void> _autoReplyAllPending(
    List<GmbReviewModel> pendingReviews,
    BusinessProfileModel profile,
  ) async {
    if (pendingReviews.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All customer reviews are already replied!')),
      );
      return;
    }

    setState(() => _isBatchReplying = true);
    int count = 0;

    try {
      for (final review in pendingReviews) {
        final reply = await _openAiService.generateReviewReply(
          reviewerName: review.reviewerName,
          starRating: review.starRating,
          reviewComment: review.comment,
          businessName: profile.businessName,
          city: profile.city,
          category: profile.primaryCategory,
          topSellingItems: profile.topSellingItems.isNotEmpty
              ? profile.topSellingItems
              : profile.seoKeywords,
          salutation: profile.aiReplySalutation,
          replyLanguage: _replyLanguage,
        );

        await _repository.saveReviewReply(
          reviewId: review.id,
          replyText: reply,
          isAutoReplied: true,
        );
        _controllerFor(review).text = reply;
        count++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auto-Replied to $count reviews with Local SEO keywords!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBatchReplying = false);
      }
    }
  }

  Future<void> _showSimulateReviewDialog(BusinessProfileModel profile) async {
    final result = await showDialog<_SimulatedReviewInput>(
      context: context,
      builder: (_) => _SimulateReviewDialog(
        businessName: profile.businessName,
      ),
    );
    if (!mounted || result == null) return;
    await _repository.addSimulatedReview(
      reviewerName: result.name,
      starRating: result.stars,
      comment: result.comment,
    );
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
            title: 'GMB AI Review Replies',
            subtitle: profile.businessName.isNotEmpty
                ? '${profile.businessName} • AI Auto-Pilot'
                : 'Smart Local SEO Review Replies',
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  tooltip: 'Add Test Review',
                  onPressed: () => _showSimulateReviewDialog(profile),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  icon: const Icon(
                    Icons.rate_review_outlined,
                    color: AppTheme.primaryColor,
                    size: 19,
                  ),
                ),
              ),
            ],
          ),
          body: StreamBuilder<List<GmbReviewModel>>(
            stream: _repository.watchReviews(),
            builder: (context, reviewsSnap) {
              if (reviewsSnap.connectionState == ConnectionState.waiting && !reviewsSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allReviews = reviewsSnap.data ?? const [];
              final pendingReviews = allReviews.where((r) => !r.hasReply).toList();
              final repliedReviews = allReviews.where((r) => r.hasReply).toList();

              final filteredReviews = allReviews.where((r) {
                if (_selectedFilter == 'Pending') return !r.hasReply;
                if (_selectedFilter == 'Replied') return r.hasReply;
                return true;
              }).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildAutoReplyHeroCard(profile, pendingReviews, repliedReviews.length),
                  const SizedBox(height: 16),

                  // Filter Chips + Language Pill (Horizontal scroll prevents overflow)
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('All (${allReviews.length})', 'All'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Pending (${pendingReviews.length})', 'Pending'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Replied (${repliedReviews.length})', 'Replied'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _replyLanguage,
                            isDense: true,
                            icon: const Icon(
                              Icons.translate_rounded,
                              size: 15,
                              color: AppTheme.primaryColor,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'English', child: Text('English ')),
                              DropdownMenuItem(value: 'Hinglish', child: Text('Hinglish ')),
                              DropdownMenuItem(value: 'Hindi', child: Text('हिंदी ')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _replyLanguage = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (filteredReviews.isEmpty)
                    SurfaceCard(
                      padding: const EdgeInsets.all(32),
                      child: const Column(
                        children: [
                          SoftIconBadge(
                            icon: Icons.reviews_outlined,
                            iconColor: AppTheme.textMuted,
                            backgroundColor: AppTheme.surfaceMuted,
                            size: 26,
                            padding: 14,
                            borderRadius: 16,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No reviews in this filter',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filteredReviews.map((review) => _buildReviewCard(review, profile)),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAutoReplyHeroCard(
    BusinessProfileModel profile,
    List<GmbReviewModel> pendingReviews,
    int repliedCount,
  ) {
    return TonalHeroCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SoftIconBadge(
                icon: Icons.auto_awesome_rounded,
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
                      'AI Auto-Reply Bot',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Injects top keywords (${profile.topSellingItems.isNotEmpty ? profile.topSellingItems.take(2).join(", ") : "Local SEO"}) into replies',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: profile.autoReplyEnabled,
                onChanged: (val) {
                  _repository.saveProfile(profile.copyWith(autoReplyEnabled: val));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isBatchReplying
                ? null
                : () => _autoReplyAllPending(pendingReviews, profile),
            icon: _isBatchReplying
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.bolt_rounded, size: 19),
            label: Text(
              _isBatchReplying
                  ? 'Generating SEO Replies...'
                  : '1-Click Auto-Reply All Pending (${pendingReviews.length})',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.primaryDark : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(GmbReviewModel review, BusinessProfileModel profile) {
    final isGenerating = _generatingIds.contains(review.id);
    final isEditing = !review.hasReply || _editingIds.contains(review.id);
    final controller = _controllerFor(review);

    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primarySoft,
                child: Text(
                  review.reviewerName.isNotEmpty ? review.reviewerName[0].toUpperCase() : 'G',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < review.starRating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: AppTheme.gold,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusPill(
                          label: review.hasReply ? 'Replied' : 'Pending',
                          textColor: review.hasReply ? AppTheme.success : AppTheme.warning,
                          backgroundColor:
                              review.hasReply ? AppTheme.successSoft : AppTheme.warningSoft,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (review.isAutoReplied)
                const StatusPill(
                  label: 'AI SEO',
                  icon: Icons.auto_awesome_rounded,
                  textColor: AppTheme.primaryColor,
                  backgroundColor: AppTheme.primarySoft,
                  borderColor: AppTheme.primaryBorder,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),

          if (review.hasReply && !isEditing) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: AppTheme.primaryColor, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your GMB Reply',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          controller.text = review.replyText ?? '';
                          setState(() => _editingIds.add(review.id));
                        },
                        child: const Text(
                          'Edit / Regenerate',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.replyText ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            TextField(
              controller: controller,
              maxLines: 3,
              style: const TextStyle(fontSize: 13.5, color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Click "AI Reply" to draft an SEO-optimized response...',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    ),
                    onPressed: isGenerating ? null : () => _generateSingleReply(review, profile),
                    icon: isGenerating
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: Text(
                      isGenerating ? 'Writing...' : 'AI Reply ($_replyLanguage)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    ),
                    onPressed: () => _postReply(review, isAuto: true),
                    icon: const Icon(Icons.send_rounded, size: 15),
                    label: const Text(
                      'Post to GMB',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SimulatedReviewInput {
  final String name;
  final int stars;
  final String comment;

  const _SimulatedReviewInput({
    required this.name,
    required this.stars,
    required this.comment,
  });
}

class _SimulateReviewDialog extends StatefulWidget {
  final String businessName;

  const _SimulateReviewDialog({required this.businessName});

  @override
  State<_SimulateReviewDialog> createState() => _SimulateReviewDialogState();
}

class _SimulateReviewDialogState extends State<_SimulateReviewDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _commentCtrl;
  int _stars = 5;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: 'Vikram Singh');
    final displayBiz =
        widget.businessName.isNotEmpty ? widget.businessName : 'the store';
    _commentCtrl = TextEditingController(
      text: 'Visited $displayBiz today. Great collection and helpful staff!',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Simulate New GMB Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            const SizedBox(height: 14),
            const Text(
              'Star Rating',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (index) {
                final starVal = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _stars = starVal),
                  icon: Icon(
                    starVal <= _stars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppTheme.gold,
                    size: 28,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Review Comment'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(110, 42)),
          onPressed: () {
            final name = _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'Customer';
            final comment = _commentCtrl.text.trim();
            Navigator.pop(
              context,
              _SimulatedReviewInput(name: name, stars: _stars, comment: comment),
            );
          },
          child: const Text('Add Review'),
        ),
      ],
    );
  }
}
