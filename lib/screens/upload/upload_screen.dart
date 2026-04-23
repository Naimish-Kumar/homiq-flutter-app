// lib/screens/upload/upload_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/design/design_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  String _selectedRoomType = 'Living Room';

  final List<Map<String, dynamic>> _roomTypes = [
    {'name': 'Living Room', 'icon': Icons.weekend_rounded},
    {'name': 'Bedroom', 'icon': Icons.bed_rounded},
    {'name': 'Kitchen', 'icon': Icons.kitchen_rounded},
    {'name': 'Office', 'icon': Icons.work_rounded},
    {'name': 'Bathroom', 'icon': Icons.bathtub_rounded},
    {'name': 'Dining Room', 'icon': Icons.restaurant_rounded},
    {'name': 'Balcony', 'icon': Icons.balcony_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: AppCurves.defaultCurve),
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not pick image: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _proceed() {
    if (_selectedImage == null) return;
    context.read<DesignBloc>().add(DesignUploadImage(
          image: _selectedImage!,
          roomType: _selectedRoomType,
        ));
    context.push('/style-select', extra: {
      'image': _selectedImage,
      'roomType': _selectedRoomType,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: isDark ? Colors.white : AppColors.textPrimaryL),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Upload Space',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── Mesh Background
          const MeshGradient(),

          // ── Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Let AI redesign\nyour space',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryL,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload a clear photo for best results',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: isDark ? AppColors.textSecondary : AppColors.textSecondaryL,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Room Type Selection
                      const SectionHeader(
                        title: 'Room Category',
                        subtitle: 'Select the type of space',
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 50,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _roomTypes.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final type = _roomTypes[i];
                            final isSelected = _selectedRoomType == type['name'];
                            return GestureDetector(
                              onTap: () => setState(() => _selectedRoomType = type['name']),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.primary 
                                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppColors.primary 
                                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                                  ),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      type['icon'],
                                      size: 18,
                                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textSecondaryL),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      type['name'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimaryL),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Upload Area
                      Expanded(
                        child: _selectedImage == null
                            ? _UploadPlaceholder(
                                onCamera: () => _pickImage(ImageSource.camera),
                                onGallery: () => _pickImage(ImageSource.gallery),
                              )
                            : _ImagePreview(
                                image: _selectedImage!,
                                onRetake: () =>
                                    setState(() => _selectedImage = null),
                              ),
                      ),

                      const SizedBox(height: 24),

                      // Tips / Actions
                      if (_selectedImage == null) ...[
                        const _TipsSection(),
                      ] else ...[
                        PrimaryButton(
                          label: 'Continue to Styles',
                          onPressed: _proceed,
                          icon: Icons.arrow_forward_rounded,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: OutlinedButton(
                            onPressed: () => setState(() => _selectedImage = null),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark ? Colors.white12 : Colors.black12,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: Text(
                              'Choose Different Photo',
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textPrimaryL,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _UploadPlaceholder({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onGallery,
            child: GlassCard(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Select from Gallery',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to browse your photos',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.black12)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: AppTextStyles.overline.copyWith(
                  color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.black12)),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: OutlinedButton.icon(
            onPressed: onCamera,
            icon: const Icon(Icons.camera_alt_rounded, size: 22),
            label: const Text('Capture with Camera'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File image;
  final VoidCallback onRetake;

  const _ImagePreview({required this.image, required this.onRetake});

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.file(
              image,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: onRetake,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Photo ready!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TipsSection extends StatelessWidget {
  const _TipsSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tips = [
      (FontAwesomeIcons.doorOpen, 'Capture from doorway', 'Get the full view'),
      (FontAwesomeIcons.sun, 'Use natural light', 'Avoid dark shadows'),
      (FontAwesomeIcons.rulerHorizontal, 'Keep it level', 'Don\'t tilt the camera'),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'Tips for best results',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimaryL,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: FaIcon(t.$1, size: 16, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.$2,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textPrimaryL,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            t.$3,
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textMuted : AppColors.textMutedL,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
