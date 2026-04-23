import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/moodboard/moodboard_bloc.dart';
import '../../models/design_model.dart';
import '../../models/moodboard_model.dart';
import '../../services/design_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class MoodboardCreateScreen extends StatefulWidget {
  final MoodboardModel? editMoodboard;
  const MoodboardCreateScreen({super.key, this.editMoodboard});

  @override
  State<MoodboardCreateScreen> createState() => _MoodboardCreateScreenState();
}

class _MoodboardCreateScreenState extends State<MoodboardCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  List<StyleModel> _styles = [];
  StyleModel? _selectedStyle;
  bool _loadingStyles = true;
  
  final List<String> _selectedColors = [];
  final List<String> _presetColors = [
    '#FFFFFF', '#000000', '#F5F5F5', '#8B4513', '#DEB887',
    '#5F9EA0', '#4682B4', '#2F4F4F', '#BC8F8F', '#BDB76B'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editMoodboard != null) {
      _titleController.text = widget.editMoodboard!.title;
      _descController.text = widget.editMoodboard!.description ?? '';
      _selectedColors.addAll(widget.editMoodboard!.colorPalette);
    }
    _fetchStyles();
  }

  Future<void> _fetchStyles() async {
    try {
      final styles = await context.read<DesignService>().getStyles();
      setState(() {
        _styles = styles;
        if (widget.editMoodboard?.styleId != null) {
          _selectedStyle = styles.where((s) => s.id == widget.editMoodboard!.styleId.toString()).firstOrNull;
        }
        _loadingStyles = false;
      });
    } catch (e) {
      setState(() => _loadingStyles = false);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.editMoodboard != null) {
        context.read<MoodboardBloc>().add(UpdateMoodboard(
          widget.editMoodboard!.id,
          title: _titleController.text,
          description: _descController.text,
          styleId: _selectedStyle != null ? int.tryParse(_selectedStyle!.id) : null,
          colorPalette: _selectedColors,
        ));
      } else {
        context.read<MoodboardBloc>().add(CreateMoodboard(
          title: _titleController.text,
          description: _descController.text,
          styleId: _selectedStyle != null ? int.tryParse(_selectedStyle!.id) : null,
          colorPalette: _selectedColors,
        ));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MoodboardBloc, MoodboardState>(
      listener: (context, state) {
        if (state is MoodboardOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          context.pop();
        } else if (state is MoodboardError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(widget.editMoodboard != null ? 'Edit Moodboard' : 'New Moodboard'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
          actions: [
            TextButton(
              onPressed: _submit,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g., My Dream Living Room'),
                  validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description (Optional)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                Text('SELECT STYLE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                _loadingStyles 
                  ? const CircularProgressIndicator()
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _styles.map((style) {
                        final isSelected = _selectedStyle?.id == style.id;
                        return ChoiceChip(
                          label: Text(style.name),
                          selected: isSelected,
                          onSelected: (v) => setState(() => _selectedStyle = v ? style : null),
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                const SizedBox(height: 32),
                Text('COLOR PALETTE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ..._presetColors.map((hex) {
                      final color = Color(int.parse(hex.replaceAll('#', '0xFF')));
                      final isSelected = _selectedColors.contains(hex);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedColors.remove(hex);
                            } else if (_selectedColors.length < 5) {
                              _selectedColors.add(hex);
                            }
                          });
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 40),
                BlocBuilder<MoodboardBloc, MoodboardState>(
                  builder: (context, state) {
                    if (state is MoodboardLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return PrimaryButton(
                      label: widget.editMoodboard != null ? 'Update Moodboard' : 'Create Moodboard',
                      onPressed: _submit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
