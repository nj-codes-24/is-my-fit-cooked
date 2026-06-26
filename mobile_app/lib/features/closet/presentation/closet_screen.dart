/// Closet screen — wardrobe management and outfit generation.
library;

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:is_my_fit_cooked/core/constants/app_constants.dart';
import 'package:is_my_fit_cooked/core/services/ai_service.dart';
import 'package:is_my_fit_cooked/core/theme/app_theme.dart';
import 'package:is_my_fit_cooked/features/closet/domain/outfit.dart';
import 'package:is_my_fit_cooked/features/closet/domain/wardrobe_item.dart';
import 'package:is_my_fit_cooked/features/closet/presentation/widgets/closet_popover.dart';
import 'package:is_my_fit_cooked/features/closet/presentation/widgets/item_details_modal.dart';
import 'package:is_my_fit_cooked/features/closet/presentation/widgets/link_input_overlay.dart';
import 'package:is_my_fit_cooked/features/closet/providers/wardrobe_provider.dart';
import 'package:uuid/uuid.dart';

/// Main closet screen with items and outfits tabs.
class ClosetScreen extends ConsumerStatefulWidget {
  const ClosetScreen({super.key});

  @override
  ConsumerState<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends ConsumerState<ClosetScreen> {
  bool _isUploading = false;
  bool _isGenerating = false;
  bool _showPopover = false;
  bool _linkInputMode = false;
  String _activeTab = 'items';
  List<Outfit> _outfits = [];
  WardrobeItem? _selectedItem;

  final TextEditingController _linkController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  // ── Image handling ──────────────────────────────────────────────────

  Future<void> _handleImageSource(ImageSource source) async {
    setState(() {
      _showPopover = false;
      _isUploading = true;
    });

    try {
      final file = await _picker.pickImage(source: source);
      if (file != null) {
        final bytes = await file.readAsBytes();

        // Simulate AI categorization.
        await Future<void>.delayed(const Duration(milliseconds: 1500));

        final categories = [
          'Shirts',
          'T-Shirts',
          'Pants',
          'Shoes',
          'Accessories',
        ]..shuffle();

        final newItem = WardrobeItem(
          id: const Uuid().v4(),
          category: categories.first,
          color: 'Unknown',
          imageBytes: bytes,
          addedAt: DateTime.now().millisecondsSinceEpoch,
        );

        if (mounted) ref.read(wardrobeProvider.notifier).addItem(newItem);
      }
    } on Exception catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to load image. On web, ensure HTTPS is used.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _handleLinkUpload() async {
    if (_linkController.text.isEmpty) return;

    setState(() {
      _isUploading = true;
      _linkInputMode = false;
    });

    try {
      await Future<void>.delayed(const Duration(seconds: 2));

      final categories = [
        'Shirts',
        'T-Shirts',
        'Pants',
        'Shoes',
        'Accessories',
      ]..shuffle();

      final mockImages = [
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&q=80&w=500',
        'https://images.unsplash.com/photo-1624378439575-d1ead6cb46bc?auto=format&fit=crop&q=80&w=500',
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=500',
      ]..shuffle();

      final newItem = WardrobeItem(
        id: const Uuid().v4(),
        category: categories.first,
        color: 'Unknown',
        image: mockImages.first,
        addedAt: DateTime.now().millisecondsSinceEpoch,
      );

      if (mounted) ref.read(wardrobeProvider.notifier).addItem(newItem);
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _linkController.clear();
        });
      }
    }
  }

  Future<void> _generateOutfits() async {
    final items = ref.read(wardrobeProvider);
    if (items.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _activeTab = 'outfits';
      _outfits = [];
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final metadata = items
          .map(
            (i) => {
              'id': i.id,
              'category': i.category,
              'color': i.color,
            },
          )
          .toList();
      final generated = await aiService.generateOutfits(metadata);
      if (mounted) setState(() => _outfits = generated);
    } on Exception catch (_) {
      if (mounted) {
        setState(() => _activeTab = 'items');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate outfits')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  // ── Image display ──────────────────────────────────────────────────

  Widget _buildItemImage(WardrobeItem item) {
    const errorWidget = Center(
      child: Icon(
        LucideIcons.image_off,
        color: AppTheme.textTertiary,
        semanticLabel: 'Image unavailable',
      ),
    );

    if (item.imageBytes != null) {
      return Image.memory(
        item.imageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        semanticLabel: '${item.category} clothing item',
        errorBuilder: (_, __, ___) => errorWidget,
      );
    }
    if (item.image != null && item.image!.startsWith('http')) {
      return Image.network(
        item.image!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        semanticLabel: '${item.category} clothing item',
        errorBuilder: (_, __, ___) => errorWidget,
      );
    }
    if (kIsWeb && item.image != null) {
      return Image.network(
        item.image!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        semanticLabel: '${item.category} clothing item',
        errorBuilder: (_, __, ___) => errorWidget,
      );
    }
    if (item.image != null) {
      return Image.file(
        File(item.image!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        semanticLabel: '${item.category} clothing item',
        errorBuilder: (_, __, ___) => errorWidget,
      );
    }
    return const Center(
      child: Icon(
        LucideIcons.image,
        color: AppTheme.textDisabled,
        semanticLabel: 'No image',
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(wardrobeProvider);

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Column(
            children: [
              _ClosetHeader(
                isUploading: _isUploading,
                activeTab: _activeTab,
                onAddTap: () {
                  if (!_isUploading) setState(() => _showPopover = true);
                },
                onTabChanged: (tab) => setState(() => _activeTab = tab),
              ),
              Expanded(
                child: _activeTab == 'items'
                    ? _ItemsView(
                        items: items,
                        onItemTap: (item) =>
                            setState(() => _selectedItem = item),
                        onAddFromGallery: () =>
                            _handleImageSource(ImageSource.gallery),
                        imageBuilder: _buildItemImage,
                      )
                    : _OutfitsView(
                        items: items,
                        outfits: _outfits,
                        isGenerating: _isGenerating,
                        onGenerate: _generateOutfits,
                        imageBuilder: _buildItemImage,
                      ),
              ),
            ],
          ),

          if (_showPopover)
            ClosetPopover(
              onClose: () => setState(() => _showPopover = false),
              onCamera: () {
                setState(() => _showPopover = false);
                _handleImageSource(ImageSource.camera);
              },
              onGallery: () => _handleImageSource(ImageSource.gallery),
              onLink: () => setState(() {
                _showPopover = false;
                _linkInputMode = true;
              }),
            ),

          if (_linkInputMode)
            LinkInputOverlay(
              controller: _linkController,
              onClose: () => setState(() => _linkInputMode = false),
              onSubmit: _handleLinkUpload,
            ),

          if (_selectedItem != null)
            ItemDetailsModal(
              item: _selectedItem!,
              onClose: () => setState(() => _selectedItem = null),
              onDelete: () {
                ref
                    .read(wardrobeProvider.notifier)
                    .removeItem(_selectedItem!.id);
                setState(() => _selectedItem = null);
              },
              imageBuilder: () => _buildItemImage(_selectedItem!),
            ),
        ],
      ),
    );
  }
}

// ── Private sub-widgets ──────────────────────────────────────────────

class _ClosetHeader extends StatelessWidget {
  const _ClosetHeader({
    required this.isUploading,
    required this.activeTab,
    required this.onAddTap,
    required this.onTabChanged,
  });

  final bool isUploading;
  final String activeTab;
  final VoidCallback onAddTap;
  final ValueChanged<String> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: Color(0xE6111111),
        border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Semantics(
                header: true,
                child: const Text(
                  'closet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: isUploading ? 'Uploading item' : 'Add new item',
                child: Tooltip(
                  message: 'Add item',
                  child: GestureDetector(
                    onTap: onAddTap,
                    child: Container(
                      width: AppTheme.minTouchTarget,
                      height: AppTheme.minTouchTarget,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                LucideIcons.plus,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SegmentedControl(
            activeTab: activeTab,
            onTabChanged: onTabChanged,
          ),
        ],
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.activeTab,
    required this.onTabChanged,
  });

  final String activeTab;
  final ValueChanged<String> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                left: activeTab == 'items' ? 0 : tabWidth,
                width: tabWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Row(
                children: [
                  _TabButton(
                    label: 'Items',
                    isActive: activeTab == 'items',
                    onTap: () => onTabChanged('items'),
                  ),
                  _TabButton(
                    label: 'Outfits',
                    isActive: activeTab == 'outfits',
                    onTap: () => onTabChanged('outfits'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        label: '$label tab',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemsView extends StatelessWidget {
  const _ItemsView({
    required this.items,
    required this.onItemTap,
    required this.onAddFromGallery,
    required this.imageBuilder,
  });

  final List<WardrobeItem> items;
  final ValueChanged<WardrobeItem> onItemTap;
  final VoidCallback onAddFromGallery;
  final Widget Function(WardrobeItem) imageBuilder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                LucideIcons.plus,
                size: 24,
                color: AppTheme.textDisabled,
                semanticLabel: 'Empty closet',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your closet is empty',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add some clothes to start generating outfits.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAddFromGallery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Add First Item',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    final categorized = <String, List<WardrobeItem>>{};
    for (final item in items) {
      categorized.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: categorized.length,
      itemBuilder: (context, index) {
        final entry = categorized.entries.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                entry.key.toLowerCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            SizedBox(
              height: 175,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: entry.value.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final item = entry.value[i];
                  return Semantics(
                    button: true,
                    label: '${item.category} item, tap to view details',
                    child: GestureDetector(
                      onTap: () => onItemTap(item),
                      child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.glassBorder,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageBuilder(item),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    ).animate().fadeIn();
  }
}

class _OutfitsView extends StatelessWidget {
  const _OutfitsView({
    required this.items,
    required this.outfits,
    required this.isGenerating,
    required this.onGenerate,
    required this.imageBuilder,
  });

  final List<WardrobeItem> items;
  final List<Outfit> outfits;
  final bool isGenerating;
  final VoidCallback onGenerate;
  final Widget Function(WardrobeItem) imageBuilder;

  @override
  Widget build(BuildContext context) {
    if (isGenerating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.textTertiary),
            SizedBox(height: 16),
            Text(
              'Curating your looks...',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    if (outfits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 24,
                color: AppTheme.textDisabled,
                semanticLabel: 'No outfits',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No outfits yet',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Generate some looks from your closet.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed:
                  items.length >= AppConstants.minItemsForOutfitGeneration
                      ? onGenerate
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Generate Now',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        ...outfits.map(
          (outfit) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.glassBorder),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      outfit.style.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    outfit.description,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: outfit.itemIds.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final item = items
                            .cast<WardrobeItem?>()
                            .firstWhere(
                              (element) =>
                                  element?.id == outfit.itemIds[i],
                              orElse: () => null,
                            );
                        if (item == null) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.glassBorder,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: imageBuilder(item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: onGenerate,
          icon: const Icon(LucideIcons.refresh_cw, size: 18),
          label: const Text('Regenerate'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: const BorderSide(color: Color(0x1AFFFFFF)),
            elevation: 0,
          ),
        ),
      ],
    ).animate().fadeIn();
  }
}
