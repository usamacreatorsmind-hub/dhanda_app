import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../cubit/business_setup_cubit.dart';
import '../cubit/business_setup_state.dart';

class BusinessSetupScreen extends StatelessWidget {
  const BusinessSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BusinessSetupCubit(),
      child: const _BusinessSetupView(),
    );
  }
}

class _BusinessSetupView extends StatefulWidget {
  const _BusinessSetupView();

  @override
  State<_BusinessSetupView> createState() => _BusinessSetupViewState();
}

class _BusinessSetupViewState extends State<_BusinessSetupView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();

  final List<String> _suggestedItems = [
    'Marbles',
    'Ceramic Vases',
    'Wall Decals',
    'Floor Mats',
    'Rugs',
    'Curtains',
    'Wall Clocks',
    'Picture Frames',
    'Wall Shelves',
    'Mosaic Art',
  ];

  final List<String> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final userUid = prefs.getString('user_uid');
    if (!isLoggedIn || userUid == null || userUid.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login with your mobile number first.'),
            backgroundColor: AppTheme.warning,
          ),
        );
        context.go(AppRouter.auth);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessSetupCubit, BusinessSetupState>(
      listener: (context, state) {
        if (state is BusinessSetupSuccess) {
          context.go(AppRouter.selectProfile);
        } else if (state is BusinessSetupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppTheme.danger),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<BusinessSetupCubit>();
        int currentStep = 1;
        bool isLoading = state is BusinessSetupLoading;

        if (state is BusinessSetupStepState) {
          currentStep = state.currentStep;
          isLoading = state.isLoading;
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.lightStatusBar,
          child: Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crisp Light Wizard Header (No heavy dark navy slab)
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (currentStep > 1)
                                InkWell(
                                  onTap: () => cubit.setStep(currentStep - 1),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceMuted,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppTheme.borderColor),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 16,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                )
                              else
                                const SoftIconBadge(
                                  icon: Icons.storefront_rounded,
                                  size: 18,
                                  padding: 8,
                                  borderRadius: 10,
                                ),
                              const Spacer(),
                              StatusPill(
                                label: 'Step $currentStep of 4',
                                textColor: AppTheme.primaryColor,
                                backgroundColor: AppTheme.primarySoft,
                                borderColor: AppTheme.primaryBorder,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _getHeaderTitle(currentStep),
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getHeaderSub(currentStep),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStepProgressBar(currentStep),
                        ],
                      ),
                    ),
                  ),
                ),

                // Step Content + Bottom CTA
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildStepContent(context, currentStep, state),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SafeArea(
                          top: false,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => _handleNext(context, currentStep, state),
                            child: isLoading
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
                                      Text(
                                        currentStep == 4 ? 'Confirm & Get Started' : 'Continue',
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getHeaderTitle(int step) {
    switch (step) {
      case 1:
        return 'Your Business Name';
      case 2:
        return 'Top Selling Items';
      case 3:
        return 'Business Location';
      case 4:
        return 'Confirm Your Listing';
      default:
        return 'Setup Business';
    }
  }

  String _getHeaderSub(int step) {
    switch (step) {
      case 1:
        return 'Tell us what to call your business';
      case 2:
        return 'Add your best-selling products or services';
      case 3:
        return 'Help customers discover you on Google Maps';
      case 4:
        return 'Verify and select your Google Business profile';
      default:
        return '';
    }
  }

  Widget _buildStepContent(BuildContext context, int step, BusinessSetupState state) {
    switch (step) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What is your Business Name?',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g., Sharma Tiles & Marbles',
                      prefixIcon: Icon(
                        Icons.storefront_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter it as it appears on Google Business Profile',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildAiMarketingBanner(),
          ],
        );

      case 2:
        final suggestedItems = state is BusinessSetupStepState
            ? state.suggestedItems
            : _suggestedItems;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Your Top Selling Items',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _itemController,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            hintText: 'e.g., Italian Marble, Tiles, Sanitary...',
                          ),
                          onFieldSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              setState(() {
                                if (!_selectedItems.contains(val.trim())) {
                                  _selectedItems.add(val.trim());
                                }
                                _itemController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          final val = _itemController.text.trim();
                          if (val.isNotEmpty) {
                            setState(() {
                              if (!_selectedItems.contains(val)) {
                                _selectedItems.add(val);
                              }
                              _itemController.clear();
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedItems.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedItems.map((item) {
                        return Chip(
                          label: Text(
                            item,
                            style: const TextStyle(
                              color: AppTheme.primaryDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                          backgroundColor: AppTheme.primarySoft,
                          side: const BorderSide(color: AppTheme.primaryBorder),
                          deleteIcon: const Icon(
                            Icons.close_rounded,
                            size: 15,
                            color: AppTheme.primaryColor,
                          ),
                          onDeleted: () {
                            setState(() => _selectedItems.remove(item));
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Popular Suggestions',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestedItems.map((sug) {
                final isSelected = _selectedItems.contains(sug);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedItems.remove(sug);
                      } else {
                        _selectedItems.add(sug);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primarySoft : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                        width: isSelected ? 1.3 : 1,
                      ),
                    ),
                    child: Text(
                      sug,
                      style: TextStyle(
                        color: isSelected ? AppTheme.primaryDark : AppTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );

      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Where is your business located?',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _cityController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter City Name (e.g., New Delhi)',
                      prefixIcon: Icon(
                        Icons.location_on_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Used for Local SEO keyword optimization & map discovery',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildAiMarketingBanner(),
          ],
        );

      case 4:
        GoogleBusinessMatch? selectedMatch;
        List<GoogleBusinessMatch> matchingBusinesses = [];
        if (state is BusinessSetupStepState) {
          selectedMatch = state.selectedGoogleBusiness;
          matchingBusinesses = state.matchingBusinesses;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your Google Business listing',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (matchingBusinesses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ...matchingBusinesses.map((match) {
                final isSelected = selectedMatch == match;
                return SurfaceCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  backgroundColor: isSelected ? AppTheme.primarySoft.withValues(alpha: 0.45) : Colors.white,
                  borderColor: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                  onTap: () {
                    context.read<BusinessSetupCubit>().selectGoogleBusiness(match);
                  },
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              match.name,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              match.address,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppTheme.gold, size: 17),
                                const SizedBox(width: 4),
                                Text(
                                  match.rating.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${match.reviewCount} reviews)',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SoftIconBadge(
                        icon: isSelected ? Icons.check_rounded : Icons.location_on_outlined,
                        iconColor: isSelected ? Colors.white : AppTheme.primaryColor,
                        backgroundColor: isSelected ? AppTheme.primaryColor : AppTheme.primarySoft,
                        size: 20,
                        padding: 10,
                        borderRadius: 12,
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: () {
                  context.read<BusinessSetupCubit>().completeSetup();
                },
                child: const Text('Skip matching & open Dashboard'),
              ),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildStepProgressBar(int currentStep) {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index < currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            height: 5,
            margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor : AppTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAiMarketingBanner() {
    return SurfaceCard(
      backgroundColor: const Color(0xFFFDFDFE),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Image.asset(
              'assets/images/google.png',
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) => const Text(
                'G',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'We fetch your Google listing insights to personalize AI marketing & SEO copy.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext(BuildContext context, int currentStep, BusinessSetupState state) {
    final cubit = context.read<BusinessSetupCubit>();
    if (currentStep == 1) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter business name')),
        );
        return;
      }
      cubit.updateBusinessName(name);
      cubit.setStep(2);
    } else if (currentStep == 2) {
      if (_selectedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one item')),
        );
        return;
      }
      cubit.updateTopSellingItems(_selectedItems);
      cubit.setStep(3);
    } else if (currentStep == 3) {
      final city = _cityController.text.trim();
      if (city.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter city name')),
        );
        return;
      }
      cubit.updateCity(city);
      cubit.searchGoogleBusinesses();
    } else if (currentStep == 4) {
      cubit.completeSetup();
    }
  }
}
