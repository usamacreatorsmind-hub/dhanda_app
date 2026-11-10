import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../data/models/business_profile_model.dart';
import '../../data/repositories/business_profile_repository.dart';

class ManageBusinessProfileScreen extends StatefulWidget {
  const ManageBusinessProfileScreen({super.key});

  @override
  State<ManageBusinessProfileScreen> createState() => _ManageBusinessProfileScreenState();
}

class _ManageBusinessProfileScreenState extends State<ManageBusinessProfileScreen> {
  late final BusinessProfileRepository _repository;
  late final Stream<BusinessProfileModel> _profileStream;
  String _userId = 'guest_user';

  @override
  void initState() {
    super.initState();
    _repository = BusinessProfileRepository();
    _profileStream = _repository.watchCurrentUserProfile();
    _repository.resolveUserId().then((id) {
      if (mounted) setState(() => _userId = id);
    });
  }

  Future<void> _showEditFieldDialog({
    required String title,
    required String initialValue,
    required Function(String newValue) onSave,
    String? hintText,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _EditFieldDialog(
        title: title,
        initialValue: initialValue,
        hintText: hintText,
      ),
    );
    if (!mounted || result == null) return;
    onSave(result);
  }

  Future<void> _updateProfile(BusinessProfileModel current, BusinessProfileModel updated) async {
    try {
      await _repository.saveProfile(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business profile updated successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: buildPremiumAppBar(
        context,
        title: 'Manage Google Profile',
        subtitle: '9899152923 • e22f • v2.96.1',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<BusinessProfileModel>(
        stream: _profileStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data ?? BusinessProfileModel(userId: _userId);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeaderCard(profile),
                const SizedBox(height: 12),

                if (profile.primaryPhone.isEmpty) ...[
                  _buildPhoneWarningBanner(),
                  const SizedBox(height: 16),
                ] else
                  const SizedBox(height: 8),

                // 1. Business Basics
                const SectionHeader(title: 'Business basics'),
                const SizedBox(height: 10),
                SurfaceCard(
                  child: Column(
                    children: [
                      _buildProfileItem(
                        icon: Icons.phone_outlined,
                        title: 'Primary phone',
                        subtitle: profile.primaryPhone.isEmpty ? 'Not added' : profile.primaryPhone,
                        actionLabel: profile.primaryPhone.isEmpty ? 'Add' : 'Edit',
                        isSubtitleNotAdded: profile.primaryPhone.isEmpty,
                        onTap: () {
                          _showEditFieldDialog(
                            title: 'Primary phone',
                            initialValue: profile.primaryPhone,
                            onSave: (val) => _updateProfile(profile, profile.copyWith(primaryPhone: val)),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildProfileItem(
                        icon: Icons.local_offer_outlined,
                        title: 'Primary category',
                        subtitle: profile.primaryCategory.isEmpty ? 'Not added' : profile.primaryCategory,
                        actionLabel: profile.primaryCategory.isEmpty ? 'Choose' : 'Edit',
                        isSubtitleNotAdded: profile.primaryCategory.isEmpty,
                        onTap: () {
                          _showEditFieldDialog(
                            title: 'Primary category',
                            initialValue: profile.primaryCategory,
                            onSave: (val) => _updateProfile(profile, profile.copyWith(primaryCategory: val)),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildProfileItem(
                        icon: Icons.label_outlined,
                        title: 'Additional categories',
                        subtitle: profile.additionalCategories.isEmpty
                            ? 'None added'
                            : profile.additionalCategories.join(', '),
                        actionLabel: 'Edit',
                        isSubtitleNotAdded: profile.additionalCategories.isEmpty,
                        onTap: () {
                          _showEditFieldDialog(
                            title: 'Additional categories',
                            initialValue: profile.additionalCategories.join(', '),
                            hintText: 'Comma separated e.g. Tiles, Sanitary, Hardware',
                            onSave: (val) {
                              final list = val
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();
                              _updateProfile(profile, profile.copyWith(additionalCategories: list));
                            },
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildProfileItem(
                        icon: Icons.calendar_today_outlined,
                        title: 'Opening date',
                        subtitle: profile.openingDate.isEmpty ? 'Not added' : profile.openingDate,
                        actionLabel: profile.openingDate.isEmpty ? 'Add' : 'Edit',
                        isSubtitleNotAdded: profile.openingDate.isEmpty,
                        onTap: () {
                          _showEditFieldDialog(
                            title: 'Opening date',
                            initialValue: profile.openingDate,
                            hintText: 'e.g. 15 Aug 2020',
                            onSave: (val) => _updateProfile(profile, profile.copyWith(openingDate: val)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Regular Hours
                const SectionHeader(title: 'Regular hours'),
                const SizedBox(height: 10),
                SurfaceCard(
                  child: _buildProfileItem(
                    icon: Icons.access_time_rounded,
                    title: 'Regular hours',
                    subtitle: profile.regularHours.isEmpty ? 'Not added' : profile.regularHours,
                    actionLabel: profile.regularHours.isEmpty ? 'Add' : 'Edit',
                    isSubtitleNotAdded: profile.regularHours.isEmpty,
                    onTap: () {
                      _showEditFieldDialog(
                        title: 'Regular hours',
                        initialValue: profile.regularHours,
                        hintText: 'e.g. Mon-Sat: 9:00 AM - 8:00 PM',
                        onSave: (val) => _updateProfile(profile, profile.copyWith(regularHours: val)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Photos & Videos
                const SectionHeader(title: 'Photos & videos'),
                const SizedBox(height: 10),
                SurfaceCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Text(
                        profile.photos.isEmpty && profile.videos.isEmpty
                            ? 'No photos or videos on your listing yet'
                            : '${profile.photos.length} photos, ${profile.videos.length} videos uploaded',
                        style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 44),
                                side: const BorderSide(color: AppTheme.borderColor),
                                foregroundColor: AppTheme.primaryColor,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Photo upload coming soon!')),
                                );
                              },
                              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                              label: const Text('Add photo'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 44),
                                side: const BorderSide(color: AppTheme.borderColor),
                                foregroundColor: AppTheme.primaryColor,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Video upload coming soon!')),
                                );
                              },
                              icon: const Icon(Icons.videocam_outlined, size: 18),
                              label: const Text('Add video'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Posts on Google
                const SectionHeader(title: 'Posts on Google'),
                const SizedBox(height: 10),
                SurfaceCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Text(
                        'Nothing posted yet — regular updates help keep your listing active in Google Search.',
                        style: TextStyle(fontSize: 13.5, color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          side: const BorderSide(color: AppTheme.borderColor),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google posting coming soon!')),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 19),
                        label: const Text('Add post'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Contact & Address
                const SectionHeader(title: 'Contact & address'),
                const SizedBox(height: 10),
                SurfaceCard(
                  child: Column(
                    children: [
                      _buildProfileItem(
                        icon: Icons.language_rounded,
                        title: 'Website',
                        subtitle: profile.website.isEmpty ? 'Not added' : profile.website,
                        actionLabel: profile.website.isEmpty ? 'Add' : 'Edit',
                        isSubtitleNotAdded: profile.website.isEmpty,
                        onTap: () {
                          _showEditFieldDialog(
                            title: 'Website',
                            initialValue: profile.website,
                            hintText: 'e.g. https://mybusiness.com',
                            onSave: (val) => _updateProfile(profile, profile.copyWith(website: val)),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildProfileItem(
                        icon: Icons.location_on_outlined,
                        title: 'Address',
                        subtitle: profile.address.isEmpty ? 'Not added' : profile.address,
                        actionLabel: profile.address.isEmpty ? 'Add' : 'Edit',
                        isSubtitleNotAdded: profile.address.isEmpty,
                        onTap: () {
                          _showEditFieldDialog(
                            title: 'Address',
                            initialValue: profile.address,
                            hintText: 'Full business address',
                            onSave: (val) => _updateProfile(profile, profile.copyWith(address: val)),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildProfileItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Communication Phone',
                        description:
                            'WhatsApp notifications for new reviews, reports, and posts are sent here',
                        subtitle: profile.communicationPhone.isEmpty
                            ? 'Not added'
                            : profile.communicationPhone,
                        actionLabel: profile.communicationPhone.isEmpty ? 'Add' : 'Edit',
                        isSubtitleNotAdded: profile.communicationPhone.isEmpty,
                        onTap: () {
                          _showEditFieldDialog(
                            title: 'Communication Phone',
                            initialValue: profile.communicationPhone,
                            hintText: '+91 WhatsApp Number',
                            onSave: (val) =>
                                _updateProfile(profile, profile.copyWith(communicationPhone: val)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 6. AI & Automation
                const SectionHeader(title: 'AI & automation'),
                const SizedBox(height: 10),
                SurfaceCard(
                  child: Column(
                    children: [
                      _buildProfileItem(
                        icon: Icons.auto_awesome_outlined,
                        title: 'AI Reply Salutation',
                        description: 'Used automatically when replying to customer reviews',
                        subtitle: profile.aiReplySalutation.isEmpty
                            ? 'Not added'
                            : profile.aiReplySalutation,
                        actionLabel: profile.aiReplySalutation.isEmpty ? 'Add' : 'Edit',
                        isSubtitleNotAdded: profile.aiReplySalutation.isEmpty,
                        onTap: () {
                          _showEditFieldDialog(
                            title: 'AI Reply Salutation',
                            initialValue: profile.aiReplySalutation,
                            hintText: 'e.g., Thank you for visiting us!',
                            onSave: (val) =>
                                _updateProfile(profile, profile.copyWith(aiReplySalutation: val)),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 60),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        title: const Text(
                          'Support Dhanda App Branding',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.5,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: const Text(
                          'Subtle credit badge on generated posters',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        trailing: Switch(
                          value: profile.supportBranding,
                          onChanged: (val) {
                            _updateProfile(profile, profile.copyWith(supportBranding: val));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopHeaderCard(BusinessProfileModel profile) {
    final hasName = profile.businessName.isNotEmpty;
    return SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primarySoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.primaryBorder),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              Positioned(
                bottom: -3,
                right: -3,
                child: InkWell(
                  onTap: () {
                    _showEditFieldDialog(
                      title: 'Business Name',
                      initialValue: profile.businessName,
                      onSave: (val) => _updateProfile(profile, profile.copyWith(businessName: val)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit_rounded, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasName ? profile.businessName : 'Your business',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                StatusPill(
                  label: hasName ? 'Active Listing' : 'Setup Incomplete',
                  icon: hasName ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  textColor: hasName ? AppTheme.success : AppTheme.warning,
                  backgroundColor: hasName ? AppTheme.successSoft : AppTheme.warningSoft,
                  borderColor: hasName ? AppTheme.successBorder : AppTheme.warningBorder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warningSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warningBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "No phone yet — customers can't call directly from your Google listing",
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    String? description,
    required String subtitle,
    required String actionLabel,
    required bool isSubtitleNotAdded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SoftIconBadge(
              icon: icon,
              iconColor: isSubtitleNotAdded ? AppTheme.warning : AppTheme.primaryColor,
              backgroundColor: isSubtitleNotAdded ? AppTheme.warningSoft : AppTheme.surfaceMuted,
              size: 18,
              padding: 8,
              borderRadius: 10,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSubtitleNotAdded ? FontWeight.w500 : FontWeight.w500,
                      color: isSubtitleNotAdded ? AppTheme.warning : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditFieldDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final String? hintText;

  const _EditFieldDialog({
    required this.title,
    required this.initialValue,
    this.hintText,
  });

  @override
  State<_EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<_EditFieldDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Enter ${widget.title}',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(84, 42),
          ),
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
