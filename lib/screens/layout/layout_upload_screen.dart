import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/layout/layout_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class LayoutUploadScreen extends StatefulWidget {
  const LayoutUploadScreen({super.key});

  @override
  State<LayoutUploadScreen> createState() => _LayoutUploadScreenState();
}

class _LayoutUploadScreenState extends State<LayoutUploadScreen> {
  final _nameController = TextEditingController();
  File? _selectedImage;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _handleSubmit() {
    if (_nameController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a name and select an image')),
      );
      return;
    }
    context.read<LayoutBloc>().add(CreateLayout(_nameController.text, _selectedImage!));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<LayoutBloc, LayoutState>(
      listener: (context, state) {
        if (state is LayoutSuccess) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Layout processing started!')),
          );
        }
        if (state is LayoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.textPrimaryL),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'New 3D Layout',
            style: GoogleFonts.playfairDisplay(
              color: isDark ? Colors.white : AppColors.textPrimaryL,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Name',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                borderRadius: 16,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. My New Living Room',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Floor Plan or Sketch',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded, size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to upload floor plan',
                              style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 48),
              BlocBuilder<LayoutBloc, LayoutState>(
                builder: (context, state) {
                  return PrimaryButton(
                    label: 'Generate 3D Layout',
                    onPressed: state is LayoutLoading ? null : _handleSubmit,
                    isLoading: state is LayoutLoading,
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'AI will convert your 2D plan into a 3D visualization',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
