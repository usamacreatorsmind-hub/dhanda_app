import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/business_setup_cubit.dart';
import '../cubit/business_setup_state.dart';

class BusinessSetupScreen extends StatelessWidget {
  const BusinessSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => BusinessSetupCubit(), child: const _BusinessSetupView());
  }
}

class _BusinessSetupView extends StatefulWidget {
  const _BusinessSetupView();

  @override
  State<_BusinessSetupView> createState() => _BusinessSetupViewState();
}

class _BusinessSetupViewState extends State<_BusinessSetupView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: 'Noida');
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
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
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
          context.go(AppRouter.dashboard);
        } else if (state is BusinessSetupError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
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
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F9FC),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dark Header Gradient Box (Extends behind status bar)
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0A1128), Color(0xFF1C2541), Color(0xFF3A506B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (currentStep > 1)
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                              onPressed: () => cubit.setStep(currentStep - 1),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                          else
                            const SizedBox(height: 10),
                          const SizedBox(height: 16),
                          Text(
                            _getHeaderTitle(currentStep),
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(_getHeaderSub(currentStep), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),

                // Step Content and Bottom Button Directly Below Gradient Box
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: SingleChildScrollView(child: _buildStepContent(context, currentStep, state))),
                        const SizedBox(height: 16),
                        // Bottom Next / Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A1B9A), Color(0xFFFF6D00)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFFFF6D00).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: isLoading ? null : () => _handleNext(context, currentStep, state),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          currentStep == 4 ? 'Confirm & Get Started' : 'Next',
                                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                      ],
                                    ),
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
        return 'Your Business Location';
      case 4:
        return 'Confirm Your Business';
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
        return 'Help customers find you on the map';
      case 4:
        return 'Review and verify your business details';
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
            _buildStepProgressBar(1),
            const Text(
              'What is your Business Name?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1D1E)),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E7EE)),
              ),
              child: TextFormField(
                controller: _nameController,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1E)),
                decoration: const InputDecoration(
                  hintText: 'Business Name',
                  hintStyle: TextStyle(color: Color(0xFFA5B0C0)),
                  prefixIcon: Icon(Icons.storefront_rounded, color: Color(0xFF6A1B9A)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('As it appears on Google Business', style: TextStyle(fontSize: 12, color: Color(0xFF75818F))),
            const SizedBox(height: 40),
            _buildAiMarketingBanner(),
          ],
        );

      case 2:
        List<String> suggestedItems = [];
        if (state is BusinessSetupStepState) {
          suggestedItems = state.suggestedItems;
        } else {
          suggestedItems = _suggestedItems;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepProgressBar(2),
            const Text(
              'Add Your Top Selling Item',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1D1E)),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E7EE)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _itemController,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'eg: Pao Bhaji, Kurties, Shoes...',
                        hintStyle: TextStyle(color: Color(0xFFA5B0C0), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  IconButton(
                    icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF6A1B9A), size: 28),
                    onPressed: () {
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Selected Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedItems.map((item) {
                return Chip(
                  label: Text(
                    item,
                    style: const TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color(0xFF6A1B9A).withOpacity(0.1),
                  deleteIcon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF6A1B9A)),
                  onDeleted: () {
                    setState(() {
                      _selectedItems.remove(item);
                    });
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Suggestions',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF75818F)),
            ),
            const SizedBox(height: 12),
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6A1B9A) : const Color(0xFFF3F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? const Color(0xFF6A1B9A) : const Color(0xFFE2E7EE)),
                    ),
                    child: Text(
                      sug,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF1A1D1E),
                        fontWeight: FontWeight.w600,
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
            _buildStepProgressBar(3),
            const Text(
              'Where is your business located?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1D1E)),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E7EE)),
              ),
              child: TextFormField(
                controller: _cityController,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1E)),
                decoration: const InputDecoration(
                  hintText: 'Enter City Name',
                  hintStyle: TextStyle(color: Color(0xFFA5B0C0)),
                  prefixIcon: Icon(Icons.location_on_rounded, color: Color(0xFFFF6D00)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Enter your city name', style: TextStyle(fontSize: 12, color: Color(0xFF75818F))),
            const SizedBox(height: 40),
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
            _buildStepProgressBar(4),
            const Text(
              'Which one is your business?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1D1E)),
            ),
            const SizedBox(height: 16),
            if (matchingBusinesses.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              ...matchingBusinesses.map((match) {
                final isSelected = selectedMatch == match;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6A1B9A).withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? const Color(0xFF6A1B9A) : const Color(0xFFE2E7EE), width: isSelected ? 2 : 1),
                  ),
                  child: InkWell(
                    onTap: () {
                      context.read<BusinessSetupCubit>().selectGoogleBusiness(match);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
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
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1D1E)),
                                ),
                                const SizedBox(height: 6),
                                Text(match.address, style: const TextStyle(fontSize: 13, color: Color(0xFF75818F), height: 1.3)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                    Text(match.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(width: 4),
                                    Text('(${match.reviewCount})', style: const TextStyle(color: Color(0xFF75818F), fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F5F9),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE2E7EE)),
                            ),
                            child: const Icon(Icons.location_pin, color: Color(0xFFFF6D00), size: 22),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  context.read<BusinessSetupCubit>().completeSetup();
                },
                child: const Text(
                  'None of the above / Skip to Dashboard',
                  style: TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildStepProgressBar(int currentStep) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(4, (index) {
                final isActive = index < currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFF6D00) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$currentStep/4',
            style: const TextStyle(color: Color(0xFF75818F), fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMarketingBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E7EE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Image.asset(
              'assets/images/google.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) => const Text(
                'G',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'We will fetch information from google to start AI Marketing',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A5568), height: 1.3),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter business name')));
        return;
      }
      cubit.updateBusinessName(name);
      cubit.setStep(2);
    } else if (currentStep == 2) {
      if (_selectedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one item')));
        return;
      }
      cubit.updateTopSellingItems(_selectedItems);
      cubit.setStep(3);
    } else if (currentStep == 3) {
      final city = _cityController.text.trim();
      if (city.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter city name')));
        return;
      }
      cubit.updateCity(city);
      // Trigger Google Places search and move to step 4
      cubit.searchGoogleBusinesses();
    } else if (currentStep == 4) {
      cubit.completeSetup();
    }
  }
}
