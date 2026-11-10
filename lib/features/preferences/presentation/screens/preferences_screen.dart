import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../../business_profile/data/models/business_profile_model.dart';
import '../../../business_profile/data/repositories/business_profile_repository.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final BusinessProfileRepository _repository = BusinessProfileRepository();
  StreamSubscription<BusinessProfileModel>? _profileSub;

  BusinessProfileModel _profile = const BusinessProfileModel(
    userId: 'guest_user',
    businessName: 'Tiles & Marbles Store',
    primaryPhone: '+91 9899152923',
    address: 'Main Market, Delhi',
    additionalInfo: 'Best quality & wholesale rates',
    city: 'New Delhi',
    communicationPhone: '+91 9899152923',
    founderName: 'Rahul Sharma',
    founderGender: 'Male',
  );

  bool _isSellingExpanded = true;
  bool _isBrandingExpanded = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _profileSub = _repository.watchCurrentUserProfile().listen((remoteProfile) {
      if (!mounted) return;
      setState(() {
        _profile = remoteProfile;
      });
    });
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateAndPersist(BusinessProfileModel updated) async {
    setState(() {
      _profile = updated;
    });
    await _repository.saveProfile(updated);
  }

  int get _filledBrandingCount {
    int count = 0;
    if (_profile.businessName.isNotEmpty) count++;
    if (_profile.primaryPhone.isNotEmpty) count++;
    if (_profile.address.isNotEmpty) count++;
    if (_profile.additionalInfo.isNotEmpty) count++;
    if (_profile.city.isNotEmpty) count++;
    if (_profile.communicationPhone.isNotEmpty) count++;
    if (_profile.founderName.isNotEmpty) count++;
    if (_profile.founderGender.isNotEmpty) count++;
    return count;
  }

  // ---------- Dialogs ----------

  Future<String?> _showTextDialog({
    required String title,
    required String label,
    String initialText = '',
    String? hint,
    String confirmLabel = 'Save',
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => _TextInputDialog(
        title: title,
        label: label,
        initialText: initialText,
        hint: hint,
        confirmLabel: confirmLabel,
      ),
    );
  }

  Future<void> _addProduct() async {
    final name = await _showTextDialog(
      title: 'Add Selling Item',
      label: 'Product / Service Name',
      hint: 'e.g., Granite, Sanitary, etc.',
      confirmLabel: 'Add',
    );
    if (!mounted || name == null || name.isEmpty) return;
    final updated = [..._profile.topSellingItems, name];
    await _updateAndPersist(_profile.copyWith(topSellingItems: updated));
  }

  Future<void> _editProduct(int index) async {
    final currentItem = _profile.topSellingItems[index];
    final name = await _showTextDialog(
      title: 'Edit Product Name',
      label: 'Product Name',
      initialText: currentItem,
    );
    if (!mounted || name == null || name.isEmpty) return;
    final updated = List<String>.from(_profile.topSellingItems);
    updated[index] = name;
    await _updateAndPersist(_profile.copyWith(topSellingItems: updated));
  }

  Future<void> _deleteProduct(int index) async {
    final updated = List<String>.from(_profile.topSellingItems)
      ..removeAt(index);
    await _updateAndPersist(_profile.copyWith(topSellingItems: updated));
  }

  Future<void> _editBrandField({
    required String label,
    required String currentValue,
    required ValueChanged<String> onSave,
  }) async {
    final value = await _showTextDialog(
      title: 'Edit $label',
      label: label,
      initialText: currentValue,
    );
    if (!mounted || value == null) return;
    onSave(value);
  }

  // ---------- Reusable widgets ----------

  Widget _buildBrandFieldCard({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          SoftIconBadge(
            icon: icon,
            iconColor: AppTheme.textSecondary,
            backgroundColor: Colors.white,
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
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not set' : value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: value.isEmpty
                        ? AppTheme.textMuted
                        : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppTheme.primaryColor,
              size: 19,
            ),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  Widget _buildSellingItemCard(int index) {
    final item = _profile.topSellingItems[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                SizedBox(height: 3),
                Text(
                  'Add Image',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppTheme.primaryColor,
              size: 19,
            ),
            onPressed: () => _editProduct(index),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.danger,
              size: 19,
            ),
            onPressed: () => _deleteProduct(index),
          ),
        ],
      ),
    );
  }

  // ---------- Tabs ----------

  Widget _buildSellingTab() {
    final items = _profile.topSellingItems;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Selling Items'),
          const SizedBox(height: 12),
          SurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                InkWell(
                  onTap: () =>
                      setState(() => _isSellingExpanded = !_isSellingExpanded),
                  child: Row(
                    children: [
                      const SoftIconBadge(
                        icon: Icons.shopping_bag_outlined,
                        size: 20,
                        padding: 10,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Selling Items',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Products or services our AI creates for',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      StatusPill(
                        label: '${items.length}',
                        textColor: AppTheme.primaryColor,
                        backgroundColor: AppTheme.primarySoft,
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _isSellingExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textMuted,
                      ),
                    ],
                  ),
                ),
                if (_isSellingExpanded) ...[
                  const SizedBox(height: 16),
                  for (int i = 0; i < items.length; i++)
                    _buildSellingItemCard(i),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 46),
                    ),
                    onPressed: _addProduct,
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      size: 18,
                    ),
                    label: const Text('Add Product'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingTab() {
    final safeGender =
        ['Male', 'Female', 'Other'].contains(_profile.founderGender)
        ? _profile.founderGender
        : 'Male';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Branding'),
          const SizedBox(height: 12),
          SurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(
                    () => _isBrandingExpanded = !_isBrandingExpanded,
                  ),
                  child: Row(
                    children: [
                      const SoftIconBadge(
                        icon: Icons.local_offer_outlined,
                        size: 20,
                        padding: 10,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Brand Details',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Shown on your AI generated posters',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusPill(
                        label: '$_filledBrandingCount/8 filled',
                        textColor: AppTheme.textSecondary,
                        backgroundColor: AppTheme.surfaceMuted,
                        borderColor: AppTheme.borderColor,
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _isBrandingExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textMuted,
                      ),
                    ],
                  ),
                ),
                if (_isBrandingExpanded) ...[
                  const SizedBox(height: 16),
                  _buildBrandFieldCard(
                    label: 'Brand Name',
                    value: _profile.businessName,
                    icon: Icons.storefront_outlined,
                    onEdit: () => _editBrandField(
                      label: 'Brand Name',
                      currentValue: _profile.businessName,
                      onSave: (val) => _updateAndPersist(
                        _profile.copyWith(businessName: val),
                      ),
                    ),
                  ),
                  _buildBrandFieldCard(
                    label: 'Phone Number',
                    value: _profile.primaryPhone,
                    icon: Icons.phone_outlined,
                    onEdit: () => _editBrandField(
                      label: 'Phone Number',
                      currentValue: _profile.primaryPhone,
                      onSave: (val) => _updateAndPersist(
                        _profile.copyWith(primaryPhone: val),
                      ),
                    ),
                  ),
                  _buildBrandFieldCard(
                    label: 'Address',
                    value: _profile.address,
                    icon: Icons.location_on_outlined,
                    onEdit: () => _editBrandField(
                      label: 'Address',
                      currentValue: _profile.address,
                      onSave: (val) =>
                          _updateAndPersist(_profile.copyWith(address: val)),
                    ),
                  ),
                  _buildBrandFieldCard(
                    label: 'Additional Info',
                    value: _profile.additionalInfo,
                    icon: Icons.info_outline_rounded,
                    onEdit: () => _editBrandField(
                      label: 'Additional Info',
                      currentValue: _profile.additionalInfo,
                      onSave: (val) => _updateAndPersist(
                        _profile.copyWith(additionalInfo: val),
                      ),
                    ),
                  ),
                  _buildBrandFieldCard(
                    label: 'City Name',
                    value: _profile.city,
                    icon: Icons.location_city_outlined,
                    onEdit: () => _editBrandField(
                      label: 'City Name',
                      currentValue: _profile.city,
                      onSave: (val) =>
                          _updateAndPersist(_profile.copyWith(city: val)),
                    ),
                  ),
                  _buildBrandFieldCard(
                    label: 'Communication Phone',
                    value: _profile.communicationPhone,
                    icon: Icons.phone_android_outlined,
                    onEdit: () => _editBrandField(
                      label: 'Communication Phone',
                      currentValue: _profile.communicationPhone,
                      onSave: (val) => _updateAndPersist(
                        _profile.copyWith(communicationPhone: val),
                      ),
                    ),
                  ),
                  _buildBrandFieldCard(
                    label: 'Founder Name',
                    value: _profile.founderName,
                    icon: Icons.person_outline_rounded,
                    onEdit: () => _editBrandField(
                      label: 'Founder Name',
                      currentValue: _profile.founderName,
                      onSave: (val) => _updateAndPersist(
                        _profile.copyWith(founderName: val),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      children: [
                        const SoftIconBadge(
                          icon: Icons.wc_rounded,
                          iconColor: AppTheme.textSecondary,
                          backgroundColor: Colors.white,
                          size: 18,
                          padding: 8,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Founder Gender',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: safeGender,
                                  isDense: true,
                                  isExpanded: true,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Male',
                                      child: Text('Male'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Female',
                                      child: Text('Female'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Other',
                                      child: Text('Other'),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      _updateAndPersist(
                                        _profile.copyWith(founderGender: val),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      children: [
                        const SoftIconBadge(
                          icon: Icons.image_outlined,
                          iconColor: AppTheme.textSecondary,
                          backgroundColor: Colors.white,
                          size: 18,
                          padding: 8,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Brand Logo & Storefront',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(86, 38),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Logo upload ready!'),
                              ),
                            );
                          },
                          child: const Text(
                            'Upload',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Advance Settings'),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Auto-sync AI Content',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: const Text(
                    'Automatically sync banners & posts',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  value: _profile.autoSync,
                  onChanged: (val) =>
                      _updateAndPersist(_profile.copyWith(autoSync: val)),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text(
                    'AI Watermark',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: const Text(
                    'Null check prevention on poster watermark',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  value: _profile.aiWatermark,
                  onChanged: (val) =>
                      _updateAndPersist(_profile.copyWith(aiWatermark: val)),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text(
                    'Push Notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: const Text(
                    'Receive marketing and order alerts',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  value: _profile.notifications,
                  onChanged: (val) =>
                      _updateAndPersist(_profile.copyWith(notifications: val)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    final phoneSub = _profile.primaryPhone.isNotEmpty
        ? '${_profile.primaryPhone.replaceAll("+91", "").trim()} • e22f • v2.96.1'
        : '9899152923 • e22f • v2.96.1';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: buildPremiumAppBar(
        context,
        title: 'Preferences',
        subtitle: phoneSub,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(47),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryColor,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textSecondary,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                ),
                tabs: const [
                  Tab(text: 'Selling Items'),
                  Tab(text: 'Branding'),
                  Tab(text: 'Advance'),
                ],
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppTheme.borderColor,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _KeepAlive(child: _buildSellingTab()),
          _KeepAlive(child: _buildBrandingTab()),
          _KeepAlive(child: _buildAdvanceTab()),
        ],
      ),
    );
  }
}

/// Keeps each tab's state and scroll position alive while swiping.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});
  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Dialog that owns and disposes its own TextEditingController.
class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.label,
    required this.initialText,
    required this.confirmLabel,
    this.hint,
  });

  final String title;
  final String label;
  final String initialText;
  final String confirmLabel;
  final String? hint;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
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
          labelText: widget.label,
          hintText: widget.hint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(84, 42)),
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
