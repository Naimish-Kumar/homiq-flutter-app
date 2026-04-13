import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:homiq/data/cubits/design/design_generation_cubit.dart';
import 'package:homiq/data/cubits/design/fetch_styles_cubit.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:image_picker/image_picker.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => StudioScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => const StudioScreen());
  }
}

class StudioScreenState extends State<StudioScreen> {
  File? _selectedImage;
  String? _selectedStyleId;
  double _budgetRange = 5000;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _generate() {
    if (_selectedImage == null || _selectedStyleId == null) {
      HelperUtils.showSnackBarMessage(
        context,
        'Please select an image and a style',
        type: MessageType.error,
      );
      return;
    }

    context.read<DesignGenerationCubit>().generateDesign(
          image: _selectedImage!,
          styleId: _selectedStyleId!,
          budget: _budgetRange.toInt().toString(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: context.color.textColorDark),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: CustomText(
            'DESIGN STUDIO',
            fontWeight: FontWeight.w400,
            color: context.color.textColorDark,
            fontSize: 16,
            letterSpacing: 4,
            useSerif: true,
          ),
        ),
        body: Stack(
          children: [
            // Luxury Mesh Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: context.color.brightness == Brightness.light
                      ? [
                          const Color(0xFFFBFBF9),
                          const Color(0xFFF5F5F4),
                          context.color.tertiaryColor.withValues(alpha: 0.1),
                          const Color(0xFFFBFBF9),
                        ]
                      : [
                          const Color(0xFF0C0A09),
                          const Color(0xFF1C1917),
                          context.color.tertiaryColor.withValues(alpha: 0.15),
                          const Color(0xFF0C0A09),
                        ],
                  stops: const [0.0, 0.4, 0.8, 1.0],
                ),
              ),
            ),
            BlocConsumer<DesignGenerationCubit, DesignGenerationState>(
              listener: (context, state) {
                if (state is DesignGenerationSuccess) {
                  Navigator.pushNamed(
                    context,
                    Routes.designResult,
                    arguments: {
                      'result': state.result,
                      'original': _selectedImage
                    },
                  );
                }
                if (state is DesignGenerationFailure) {
                  HelperUtils.showSnackBarMessage(context, state.errorMessage,
                      type: MessageType.error);
                }
              },
              builder: (context, state) {
                if (state is DesignGenerationInProgress) {
                  return _buildLoadingState();
                }
                return _buildForm();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      color: context.color.primaryColor.withValues(alpha: 0.8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Glowing Pulse Ring
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            context.color.tertiaryColor.withValues(alpha: 0.2),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 140,
                  width: 140,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation(context.color.tertiaryColor),
                  ),
                ),
                Icon(Icons.auto_awesome_rounded,
                    size: 50, color: context.color.tertiaryColor),
              ],
            ),
             SizedBox(height: 60),
            const CustomText(
              'CONCEPTUALIZING',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              letterSpacing: 4,
              textAlign: TextAlign.center,
              useSerif: true,
            ),
             SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: CustomText(
                'Our AI is analyzing architecture, light patterns, and textures to craft your premium space.',
                color: context.color.textLightColor,
                textAlign: TextAlign.center,
                fontSize: 14,
            
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('INPUT CANVAS'),
             SizedBox(height: 16),
            _imagePickerArea(),
             SizedBox(height: 32),
            _buildSectionHeader('SELECT AESTHETIC'),
             SizedBox(height: 16),
            _styleSelectorGrid(),
             SizedBox(height: 32),
            _buildSectionHeader('FINANCIAL PARAMETERS'),
             SizedBox(height: 16),
            _buildBudgetSelector(),
             SizedBox(height: 60),
            _buildGenerateButton(),
             SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return CustomText(
      title,
      fontSize: context.font.xxs,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.5,
      color: context.color.tertiaryColor,
    );
  }

  Widget _imagePickerArea() {
    return GestureDetector(
      onTap: () => _showImageSourceOptions(),
      child: Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: context.color.brightness == Brightness.light
              ? Colors.black.withValues(alpha: 0.03)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: context.color.tertiaryColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: _selectedImage == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color:
                            context.color.tertiaryColor.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_photo_alternate_rounded,
                          size: 40, color: context.color.tertiaryColor),
                    ),
                    const SizedBox(height: 24),
                    const CustomText(
                      'CAPTURE SPACE',
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      'Upload your room photo to begin',
                      fontSize: 13,
                      color: context.color.textLightColor,
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_selectedImage!, fit: BoxFit.cover),
                    // Glass Overlay for control
                    Positioned(
                      top: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              color: Colors.black.withValues(alpha: 0.3),
                              child: const Icon(Icons.refresh_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _showImageSourceOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.color.primaryColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomText('Select Source',
                fontSize: 20, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            _buildSourceOpion(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
            _buildSourceOpion(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOpion(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.color.borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.color.tertiaryColor),
            const SizedBox(width: 16),
            CustomText(label, fontWeight: FontWeight.w600),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _styleSelectorGrid() {
    return BlocBuilder<FetchStylesCubit, FetchStylesState>(
      builder: (context, state) {
        if (state is FetchStylesSuccess) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: state.styles.length,
            itemBuilder: (context, index) {
              final style =
                  state.styles[index] as Map<String, dynamic>;
              final isSelected = _selectedStyleId == style['id'].toString();
              return _styleCard(style, isSelected);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _styleCard(Map<String, dynamic> style, bool isSelected) {
    // Mapping style names to our generated assets
    final styleMap = {
      'Modern': 'assets/studio/styles/modern.png',
      'Scandinavian': 'assets/studio/styles/scandinavian.png',
      'Industrial': 'assets/studio/styles/industrial.png',
      'Luxury': 'assets/studio/styles/luxury.png',
    };

    final assetPath =
        styleMap[style['name']] ?? 'assets/studio/styles/modern.png';

    return GestureDetector(
      onTap: () => setState(() => _selectedStyleId = style['id'].toString()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isSelected
                ? context.color.tertiaryColor
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.color.tertiaryColor.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: -5,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  )
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(assetPath, fit: BoxFit.cover),
              // Luxury Gradient Overlay
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        isSelected
                            ? Colors.black.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.5, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      (style['name'] as String).toUpperCase(),
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                    if (isSelected)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(top: 8),
                        height: 2,
                        width: 30,
                        decoration: BoxDecoration(
                          color: context.color.tertiaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: context.color.tertiaryColor,
                              blurRadius: 5,
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        color: context.color.tertiaryColor, size: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSelector() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.color.brightness == Brightness.light
            ? Colors.black.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: context.color.tertiaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    'ESTIMATED COST',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: context.color.textLightColor,
                    letterSpacing: 2,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    '\$${_budgetRange.toInt().toString()}',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: context.color.textColorDark,
                    letterSpacing: 1,
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: context.color.tertiaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.bolt,
                        color: Colors.amber, size: 12),
                    const SizedBox(width: 8),
                    CustomText(
                      '1 PASS',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: context.color.tertiaryColor,
                      letterSpacing: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: context.color.tertiaryColor,
              inactiveTrackColor:
                  context.color.tertiaryColor.withValues(alpha: 0.1),
              thumbColor: context.color.tertiaryColor,
              overlayColor: context.color.tertiaryColor.withValues(alpha: 0.1),
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: _budgetRange,
              min: 500,
              max: 50000,
              divisions: 99,
              onChanged: (value) => setState(() => _budgetRange = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.color.tertiaryColor.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _generate,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.color.tertiaryColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 20),
            SizedBox(width: 14),
            CustomText(
              'REIMAGINE SPACE',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ],
        ),
      ),
    );
  }
}
