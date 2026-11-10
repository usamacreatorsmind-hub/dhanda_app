import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../data/models/business_profile_model.dart';
import '../../data/repositories/business_profile_repository.dart';

class SelectProfileScreen extends StatefulWidget {
  const SelectProfileScreen({super.key});

  @override
  State<SelectProfileScreen> createState() => _SelectProfileScreenState();
}

class _SelectProfileScreenState extends State<SelectProfileScreen> {
  final BusinessProfileRepository _repository = BusinessProfileRepository();
  late final Stream<BusinessProfileModel> _profileStream;
  String _phoneNumber = '9899152923';
  String _shortCode = 'e22f';
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _profileStream = _repository.watchCurrentUserProfile();
    _loadUserMeta();
  }

  Future<void> _loadUserMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final rawPhone = prefs.getString('user_phone') ?? '9899152923';
    final cleanPhone = rawPhone.replaceAll('+91', '').replaceAll(RegExp(r'\D'), '');
    final uid = prefs.getString('user_uid') ?? 'e22f';

    final hashHex = uid.codeUnits
        .fold<int>(0x1234, (prev, elem) => ((prev * 31) + elem) & 0xFFFF)
        .toRadixString(16)
        .padLeft(4, '0');

    if (!mounted) return;
    setState(() {
      _phoneNumber = cleanPhone.isNotEmpty ? cleanPhone : '9899152923';
      _shortCode = hashHex;
    });
  }

  Future<void> _handleConnectWithGoogle(BusinessProfileModel profile) async {
    setState(() => _isConnecting = true);
    try {
      final result = await _repository.connectUserGmailAndSync(profile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected Google account: ${result.email}'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not complete Google sign-in: $e'),
          backgroundColor: AppTheme.warning,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _selectBusinessAndOpenDashboard(
    BusinessProfileModel profile, {
    Map<String, dynamic>? businessDoc,
    String? businessId,
  }) async {
    if (businessDoc != null) {
      final updated = profile.copyWith(
        businessName: businessDoc['name'] as String? ?? profile.businessName,
        city: businessDoc['city'] as String? ?? profile.city,
        primaryCategory: businessDoc['category'] as String? ?? profile.primaryCategory,
        primaryPhone: businessDoc['phone'] as String? ?? profile.primaryPhone,
        address: (businessDoc['googleBusinessAddress'] as String?) ??
            (businessDoc['city'] as String? ?? profile.address),
        topSellingItems: List<String>.from(
          businessDoc['topSellingItems'] ?? profile.topSellingItems,
        ),
      );
      await _repository.saveProfile(updated);
    }

    if (!mounted) return;
    context.go(AppRouter.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightStatusBar,
      child: StreamBuilder<BusinessProfileModel>(
        stream: _profileStream,
        builder: (context, snapshot) {
          final profile = snapshot.data ?? const BusinessProfileModel(userId: 'guest_user');
          final emailLabel = profile.connectedGmail.isNotEmpty
              ? profile.connectedGmail
              : 'Connect your business Gmail';
          final isLinked = profile.isGmbConnected && profile.connectedGmail.isNotEmpty;

          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            appBar: buildPremiumAppBar(
              context,
              title: 'Select profile',
              subtitle: '$_phoneNumber • v2.96.1',
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: profile.userId != 'guest_user'
                        ? FirebaseFirestore.instance
                            .collection('businesses')
                            .where('ownerUid', isEqualTo: profile.userId)
                            .snapshots()
                        : const Stream.empty(),
                    builder: (context, bizSnap) {
                      final docs = bizSnap.data?.docs ?? const [];

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                        children: [
                          // Account Email + Subtle Status Pill Row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Row(
                              children: [
                                Icon(
                                  isLinked ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                                  size: 17,
                                  color: isLinked ? AppTheme.success : AppTheme.warning,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    emailLabel,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                StatusPill(
                                  label: isLinked ? 'Connected' : 'Needs Google',
                                  textColor: isLinked ? AppTheme.success : AppTheme.warning,
                                  backgroundColor:
                                      isLinked ? AppTheme.successSoft : AppTheme.warningSoft,
                                  borderColor:
                                      isLinked ? AppTheme.successBorder : AppTheme.warningBorder,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          if (docs.isNotEmpty)
                            ...docs.map((doc) {
                              final data = doc.data();
                              final rawName = (data['name'] as String? ?? 'My Business').trim();
                              final rawCity = (data['city'] as String? ?? '').trim();
                              final displayTitle = rawCity.isNotEmpty &&
                                      !rawName.toLowerCase().contains(rawCity.toLowerCase())
                                  ? '$rawName, $rawCity'
                                  : rawName;
                              final shortId = doc.id.length >= 4
                                  ? doc.id.substring(0, 4).toLowerCase()
                                  : _shortCode;

                              return _buildBusinessProfileCard(
                                title: displayTitle,
                                shortCode: shortId,
                                onTap: () => _selectBusinessAndOpenDashboard(
                                  profile,
                                  businessDoc: data,
                                  businessId: doc.id,
                                ),
                              );
                            })
                          else
                            _buildBusinessProfileCard(
                              title: _formatProfileTitle(profile),
                              shortCode: _shortCode,
                              onTap: () => _selectBusinessAndOpenDashboard(profile),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // Bottom Connect with Google + Trust Card
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed:
                              _isConnecting ? null : () => _handleConnectWithGoogle(profile),
                          child: _isConnecting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      padding: const EdgeInsets.all(4.5),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        'assets/images/google.png',
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Text(
                                            'G',
                                            style: TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                              height: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Connect with Google',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Link a Google Business account to sync locations & reviews',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        SurfaceCard(
                          borderRadius: 18,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildTrustColumn(
                                      icon: Icons.location_on_rounded,
                                      iconColor: AppTheme.primaryColor,
                                      bgColor: AppTheme.primarySoft,
                                      text: 'Connects to\nGoogle Business only',
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildTrustColumn(
                                      icon: Icons.mail_lock_outlined,
                                      iconColor: AppTheme.secondaryColor,
                                      bgColor: AppTheme.secondarySoft,
                                      text: "Cannot read\nyour personal emails",
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildTrustColumn(
                                      icon: Icons.verified_user_outlined,
                                      iconColor: AppTheme.success,
                                      bgColor: AppTheme.successSoft,
                                      text: '100% Private\n& Secure',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 14,
                                    color: AppTheme.textMuted,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'You can disconnect Google Business anytime',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatProfileTitle(BusinessProfileModel profile) {
    final name = profile.businessName.trim().isNotEmpty ? profile.businessName.trim() : 'Tiles';
    final city = profile.city.trim().isNotEmpty ? profile.city.trim() : 'Noida';
    if (name.toLowerCase().contains(city.toLowerCase())) {
      return name;
    }
    return '$name, $city';
  }

  Widget _buildBusinessProfileCard({
    required String title,
    required String shortCode,
    required VoidCallback onTap,
  }) {
    final initial = title.trim().isNotEmpty ? title.trim()[0].toUpperCase() : 'B';

    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primarySoft,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppTheme.primaryBorder),
            ),
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryColor,
              ),
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
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '#$shortCode • Workspace',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textMuted,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildTrustColumn({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String text,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SoftIconBadge(
          icon: icon,
          iconColor: iconColor,
          backgroundColor: bgColor,
          size: 19,
          padding: 9,
          borderRadius: 11,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
