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
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        backgroundColor: context.color.primaryColor,
        title: CustomText(
          'AI Studio',
          fontWeight: FontWeight.bold,
          color: context.color.textColorDark,
          fontSize: context.font.lg,
        ),
        showBackButton: true,
      ),
      body: BlocConsumer<DesignGenerationCubit, DesignGenerationState>(
        listener: (context, state) {
          if (state is DesignGenerationSuccess) {
            Navigator.pushNamed(
              context,
              Routes.designResult,
              arguments: {'result': state.result, 'original': _selectedImage},
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
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 240,
                width: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      context.color.tertiaryColor.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 120,
                width: 120,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF49A9B4)),
                ),
              ),
              const Icon(Icons.auto_awesome_rounded,
                  size: 40, color: Color(0xFF49A9B4)),
            ],
          ),
          const SizedBox(height: 48),
          const CustomText(
            'Conceptualizing Your Space',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          CustomText(
            'Our AI is analyzing lighting, architecture, and style patterns...',
            color: context.color.textLightColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('UPLOAD ROOM'),
          const SizedBox(height: 16),
          _imagePickerArea(),
          const SizedBox(height: 32),
          _buildSectionHeader('SELECT AESTHETIC'),
          const SizedBox(height: 16),
          _styleSelectorGrid(),
          const SizedBox(height: 32),
          _buildSectionHeader('ESTIMATED BUDGET'),
          const SizedBox(height: 8),
          _buildBudgetSelector(),
          const SizedBox(height: 48),
          _buildGenerateButton(),
          const SizedBox(height: 32),
        ],
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.color.secondaryColor.withOpacity(0.05),
            border: Border.all(
              color: context.color.borderColor.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: _selectedImage == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.color.tertiaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_a_photo_rounded,
                          size: 32, color: context.color.tertiaryColor),
                    ),
                    const SizedBox(height: 16),
                    CustomText(
                      'Capture your space',
                      fontWeight: FontWeight.w600,
                      fontSize: context.font.md,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      'Tap to upload room photo',
                      fontSize: context.font.xs,
                      color: context.color.textLightColor,
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_selectedImage!, fit: BoxFit.cover),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              color: Colors.black38,
                              child: const Icon(Icons.close,
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
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? context.color.tertiaryColor
                : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.color.tertiaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(assetPath, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      style['name'] as String,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: context.font.sm,
                    ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        height: 2,
                        width: 24,
                        color: context.color.tertiaryColor,
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF49A9B4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              '\$${_budgetRange.toInt().toString()}',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.color.textColorDark,
            ),
            CustomText(
              'Est. Cost',
              fontSize: context.font.xs,
              color: context.color.textLightColor,
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: context.color.tertiaryColor,
            inactiveTrackColor: context.color.borderColor,
            thumbColor: context.color.tertiaryColor,
            overlayColor: context.color.tertiaryColor.withOpacity(0.1),
            trackHeight: 4,
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
            color: context.color.tertiaryColor.withOpacity(0.3),
            blurRadius: 20,
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
            Icon(Icons.auto_awesome_rounded),
            SizedBox(width: 12),
            Text(
              'REIMAGINE SPACE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
