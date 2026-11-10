import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../../business_profile/data/models/business_profile_model.dart';
import '../../../business_profile/data/repositories/business_profile_repository.dart';
import '../widgets/app_drawer.dart';

class HomeDashboardTab extends StatefulWidget {
  final ValueChanged<int>? onSwitchTab;

  const HomeDashboardTab({super.key, this.onSwitchTab});

  @override
  State<HomeDashboardTab> createState() => _HomeDashboardTabState();
}

class _HomeDashboardTabState extends State<HomeDashboardTab> {
  final BusinessProfileRepository _repository = BusinessProfileRepository();
  bool _isConnectingGmail = false;

  Future<void> _connectGmail(BusinessProfileModel profile) async {
    setState(() => _isConnectingGmail = true);
    try {
      final res = await _repository.connectUserGmailAndSync(profile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected Gmail: ${res.email} for Google Business Profile!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gmail connection note: $e'),
          backgroundColor: AppTheme.warning,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isConnectingGmail = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final strings = AppStrings.of(langState);

        return StreamBuilder<BusinessProfileModel>(
          stream: _repository.watchCurrentUserProfile(),
          builder: (context, profileSnap) {
            final profile = profileSnap.data ?? const BusinessProfileModel(userId: 'guest_user');
            final bizName =
                profile.businessName.isNotEmpty ? profile.businessName : 'My Business Store';

            return Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              drawer: AppDrawer(onTabSelected: widget.onSwitchTab),
              appBar: AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                systemOverlayStyle: AppTheme.lightStatusBar,
                titleSpacing: 4,
                title: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primarySoft,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: AppTheme.primaryBorder),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: AppTheme.primaryColor,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.dashboardGreeting,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            bizName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: InkWell(
                      onTap: () => context.push(AppRouter.manageBusinessProfile),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceMuted,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 15,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(1),
                  child: Divider(height: 1, thickness: 1, color: AppTheme.borderColor),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. GMB Audit Score & Gmail Connect Card
                    _buildGmbAuditAndConnectCard(profile, langState.isHindi),
                    const SizedBox(height: 16),

                    // 2. Dhanda AI Studio Hero Card (Airy Tonal Surface)
                    TonalHeroCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const StatusPill(
                                label: 'AI Studio',
                                icon: Icons.auto_awesome_rounded,
                                textColor: AppTheme.primaryColor,
                                backgroundColor: Colors.white,
                                borderColor: AppTheme.primaryBorder,
                              ),
                              const Spacer(),
                              Text(
                                'Local SEO Ready',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Dhanda AI — GMB Marketing Studio',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            langState.isHindi
                                ? 'AI से ऑटोमैटिक GMB पोस्ट, रिव्यू रिप्लाई और SEO कीवर्ड्स अपडेट करें'
                                : 'Auto-generate GMB posts, smart review replies, and local SEO keywords.',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => widget.onSwitchTab?.call(2),
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: Text(
                                    strings.createPost,
                                    style: const TextStyle(fontSize: 13.5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppTheme.textPrimary,
                                    side: const BorderSide(color: AppTheme.primaryBorder),
                                    minimumSize: const Size(0, 44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => widget.onSwitchTab?.call(1),
                                  icon: const Icon(
                                    Icons.reply_all_rounded,
                                    size: 17,
                                    color: AppTheme.primaryColor,
                                  ),
                                  label: const Text(
                                    'Auto Reply',
                                    style: TextStyle(fontSize: 13.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Quick Actions 2x2 Grid (Cohesive low-saturation palette)
                    SectionHeader(title: strings.quickActions),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.38,
                      children: [
                        _QuickActionCard(
                          title: langState.isHindi
                              ? 'GMB ऑटो रिव्यू रिप्लाई'
                              : 'GMB Review Auto-Reply',
                          icon: Icons.reviews_outlined,
                          onTap: () => widget.onSwitchTab?.call(1),
                        ),
                        _QuickActionCard(
                          title: strings.aiPosterGenerator,
                          icon: Icons.auto_awesome_outlined,
                          onTap: () => widget.onSwitchTab?.call(2),
                        ),
                        _QuickActionCard(
                          title: langState.isHindi
                              ? 'GMB ऑटो पोस्ट & कीवर्ड्स'
                              : 'GMB Auto-Post & SEO',
                          icon: Icons.trending_up_rounded,
                          onTap: () => widget.onSwitchTab?.call(3),
                        ),
                        _QuickActionCard(
                          title: langState.isHindi ? 'GMB प्रोफ़ाइल और SEO' : 'Manage GMB Profile',
                          icon: Icons.storefront_outlined,
                          onTap: () => context.push(AppRouter.manageBusinessProfile),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 4. Recent Designs / Published GMB Posts
                    SectionHeader(
                      title: strings.recentDesigns,
                      trailing: TextButton(
                        onPressed: () => widget.onSwitchTab?.call(3),
                        child: const Text('View All'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<List<GmbPostModel>>(
                      stream: _repository.watchGmbPosts(),
                      builder: (context, postSnap) {
                        final posts = postSnap.data ?? const [];
                        if (posts.isEmpty) {
                          return SurfaceCard(
                            padding: const EdgeInsets.all(28),
                            child: Center(
                              child: Column(
                                children: [
                                  const SoftIconBadge(
                                    icon: Icons.insert_photo_outlined,
                                    iconColor: AppTheme.textMuted,
                                    backgroundColor: AppTheme.surfaceMuted,
                                    size: 26,
                                    padding: 14,
                                    borderRadius: 16,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    strings.noRecentDesigns,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: posts.take(3).map((post) {
                            return SurfaceCard(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  const SoftIconBadge(
                                    icon: Icons.auto_awesome_rounded,
                                    size: 19,
                                    padding: 10,
                                    borderRadius: 12,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          post.summary,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  StatusPill(
                                    label: post.postType,
                                    textColor: AppTheme.success,
                                    backgroundColor: AppTheme.successSoft,
                                    borderColor: AppTheme.successBorder,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // 5. Social Media Connect Section
                    Text(
                      langState.isHindi
                          ? 'सोशल मीडिया पर एक्टिव रहें'
                          : 'Stay active on Social Media',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      langState.isHindi
                          ? 'मार्केटिंग ऑटोमेट करने के लिए प्रोफाइल कनेक्ट करें'
                          : 'Connect profiles to automate publishing across channels',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SocialConnectTile(
                      iconAsset: 'assets/images/fb.png',
                      title: 'Facebook',
                      subtitle: langState.isHindi ? 'कनेक्टेड नहीं है' : 'Not connected',
                      onConnect: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Facebook Page OAuth will link here')),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _SocialConnectTile(
                      iconAsset: 'assets/images/instagram.png',
                      title: 'Instagram',
                      subtitle: langState.isHindi ? 'कनेक्टेड नहीं है' : 'Not connected',
                      onConnect: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Instagram Business OAuth will link here')),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGmbAuditAndConnectCard(BusinessProfileModel profile, bool isHindi) {
    final score = profile.profileAuditScore;
    final isHealthy = score >= 75;
    final progressColor = isHealthy ? AppTheme.success : AppTheme.primaryColor;

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppTheme.surfaceMuted,
                      color: progressColor,
                    ),
                  ),
                  Text(
                    '$score%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isHindi ? 'GMB प्रोफ़ाइल ऑडिट स्कोर' : 'Google Business Audit Score',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.isGmbConnected && profile.connectedGmail.isNotEmpty
                          ? 'Connected: ${profile.connectedGmail}'
                          : (isHindi
                              ? 'ऑटो-पोस्ट और रिप्लाई के लिए अपनी Gmail कनेक्ट करें'
                              : 'Connect your business Gmail for GMB Auto-Post & Reply'),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: profile.isGmbConnected
                            ? AppTheme.success
                            : AppTheme.textSecondary,
                        fontWeight: profile.isGmbConnected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 42),
                backgroundColor: profile.isGmbConnected
                    ? AppTheme.successSoft
                    : AppTheme.surfaceMuted,
                foregroundColor:
                    profile.isGmbConnected ? AppTheme.success : AppTheme.primaryColor,
                side: BorderSide(
                  color: profile.isGmbConnected
                      ? AppTheme.successBorder
                      : AppTheme.borderColor,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isConnectingGmail ? null : () => _connectGmail(profile),
              icon: _isConnectingGmail
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      profile.isGmbConnected
                          ? Icons.check_circle_rounded
                          : Icons.account_circle_outlined,
                      size: 18,
                    ),
              label: Text(
                profile.isGmbConnected
                    ? 'Gmail Connected (${profile.connectedGmail}) • Change'
                    : 'Connect Your Google Business Gmail',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      borderRadius: 16,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SoftIconBadge(
                icon: icon,
                iconColor: AppTheme.primaryColor,
                backgroundColor: AppTheme.primarySoft,
                size: 20,
                padding: 9,
                borderRadius: 11,
              ),
              const Icon(
                Icons.arrow_outward_rounded,
                size: 16,
                color: AppTheme.textMuted,
              ),
            ],
          ),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: AppTheme.textPrimary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialConnectTile extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onConnect;

  const _SocialConnectTile({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      borderRadius: 16,
      onTap: onConnect,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              iconAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.share_rounded, color: AppTheme.primaryColor, size: 20);
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.primarySoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryBorder),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Connect',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
