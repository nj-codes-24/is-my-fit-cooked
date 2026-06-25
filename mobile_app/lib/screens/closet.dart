import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

import '../models/types.dart';
import '../providers/wardrobe.dart';
import '../services/ai.dart';
import '../theme.dart';
import '../layout.dart';

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
  
  String _activeTab = 'items'; // 'items' or 'outfits'
  List<Outfit> _outfits = [];
  WardrobeItem? _selectedItem;
  
  final TextEditingController _linkController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _handleImageSource(ImageSource source) async {
    setState(() {
      _showPopover = false;
      _isUploading = true;
    });

    try {
      final file = await _picker.pickImage(source: source);
      if (file != null) {
        final bytes = await file.readAsBytes();
        
        // Simulate AI categorization
        await Future.delayed(const Duration(milliseconds: 1500));
        
        final categories = ['Shirts', 'T-Shirts', 'Pants', 'Shoes', 'Accessories'];
        categories.shuffle();
        
        final newItem = WardrobeItem(
          id: const Uuid().v4(),
          category: categories.first,
          color: 'Unknown',
          image: null,
          imageBytes: bytes,
          addedAt: DateTime.now().millisecondsSinceEpoch,
        );
        
        if (mounted) ref.read(wardrobeProvider.notifier).addItem(newItem);
      }
    } catch (e) {
      debugPrint("Image picker error: \$e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load image. If using camera on web, ensure HTTPS is used.')),
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
      await Future.delayed(const Duration(seconds: 2));
      
      final categories = ['Shirts', 'T-Shirts', 'Pants', 'Shoes', 'Accessories'];
      categories.shuffle();
      
      final mockImages = [
        "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&q=80&w=500",
        "https://images.unsplash.com/photo-1624378439575-d1ead6cb46bc?auto=format&fit=crop&q=80&w=500",
        "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=500",
      ];
      mockImages.shuffle();
      
      final newItem = WardrobeItem(
        id: const Uuid().v4(),
        category: categories.first,
        color: 'Unknown',
        image: mockImages.first,
        imageBytes: null,
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
      final generated = await AIService.generateOutfits(items);
      if (mounted) setState(() => _outfits = generated);
    } catch (e) {
      debugPrint("Generate error: \$e");
      if (mounted) {
        setState(() => _activeTab = 'items');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to generate outfits')));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Widget _buildItemImage(WardrobeItem item) {
    if (item.imageBytes != null) {
      return Image.memory(
        item.imageBytes!, 
        fit: BoxFit.cover, 
        width: double.infinity, 
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(LucideIcons.image_off, color: Colors.white54)),
      );
    }
    if (item.image != null && item.image!.startsWith('http')) {
      return Image.network(
        item.image!, 
        fit: BoxFit.cover, 
        width: double.infinity, 
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(LucideIcons.image_off, color: Colors.white54)),
      );
    }
    if (kIsWeb && item.image != null) {
      return Image.network(
        item.image!, 
        fit: BoxFit.cover, 
        width: double.infinity, 
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(LucideIcons.image_off, color: Colors.white54)),
      );
    }
    if (item.image != null) {
      return Image.file(
        File(item.image!), 
        fit: BoxFit.cover, 
        width: double.infinity, 
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(LucideIcons.image_off, color: Colors.white54)),
      );
    }
    return const Center(child: Icon(LucideIcons.image, color: Colors.white24));
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(wardrobeProvider);
    
    return Stack(
      children: [
        Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _activeTab == 'items' ? _buildItemsView(items) : _buildOutfitsView(items),
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
              ref.read(wardrobeProvider.notifier).removeItem(_selectedItem!.id);
              setState(() => _selectedItem = null);
            },
            imageBuilder: () => _buildItemImage(_selectedItem!),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      decoration: const BoxDecoration(
        color: Color(0xE6111111),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'closet',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => !_isUploading ? setState(() => _showPopover = true) : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _isUploading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(LucideIcons.plus, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSegmentedControl(),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth) / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                left: _activeTab == 'items' ? 0 : tabWidth,
                width: tabWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildTabButton('Items', 'items'),
                  _buildTabButton('Outfits', 'outfits'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    final isActive = _activeTab == value;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _activeTab = value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsView(List<WardrobeItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(LucideIcons.plus, size: 24, color: Colors.white.withOpacity(0.4)),
            ),
            const SizedBox(height: 16),
            const Text('Your closet is empty', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Add some clothes to start generating outfits.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _handleImageSource(ImageSource.gallery),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Add First Item', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    final Map<String, List<WardrobeItem>> categorized = {};
    for (var item in items) {
      categorized.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: categorized.entries.map((e) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(e.key.toLowerCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            SizedBox(
              height: 175,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: e.value.length,
                separatorBuilder: (c, i) => const SizedBox(width: 12),
                itemBuilder: (c, i) {
                  final item = e.value[i];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedItem = item),
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFF242426),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildItemImage(item),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }).toList(),
    ).animate().fadeIn();
  }

  Widget _buildOutfitsView(List<WardrobeItem> items) {
    if (_isGenerating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white54),
            SizedBox(height: 16),
            Text('Curating your looks...', style: TextStyle(color: Colors.white60)),
          ],
        ),
      );
    }

    if (_outfits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(LucideIcons.sparkles, size: 24, color: Colors.white.withOpacity(0.4)),
            ),
            const SizedBox(height: 16),
            const Text('No outfits yet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Generate some looks from your closet.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: items.length >= 2 ? _generateOutfits : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Generate Now', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        ..._outfits.map((outfit) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glassDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    outfit.style.toUpperCase(),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white54, letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(outfit.description, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: outfit.itemIds.length,
                    separatorBuilder: (c, i) => const SizedBox(width: 12),
                    itemBuilder: (c, i) {
                      final item = items.cast<WardrobeItem?>().firstWhere((element) => element?.id == outfit.itemIds[i], orElse: () => null);
                      if (item == null) return const SizedBox.shrink();
                      return Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildItemImage(item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )),
        
        ElevatedButton.icon(
          onPressed: _generateOutfits,
          icon: const Icon(LucideIcons.refresh_cw, size: 18),
          label: const Text('Regenerate'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.05),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: const BorderSide(color: Colors.white10),
            elevation: 0,
          ),
        ),
      ],
    ).animate().fadeIn();
  }
}

// ----------------------------------------------------------------------
// Extracted Widgets for Architecture Modularity
// ----------------------------------------------------------------------

class ClosetPopover extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onLink;

  const ClosetPopover({super.key, required this.onClose, required this.onCamera, required this.onGallery, required this.onLink});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            top: 96,
            right: 24,
            child: Container(
              width: 240,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xBF141414),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white10),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 40, offset: Offset(0, 16))],
              ),
              child: Column(
                children: [
                  _PopoverOption(
                    title: 'Camera',
                    subtitle: 'Take a photo',
                    icon: LucideIcons.camera,
                    onTap: onCamera,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  ),
                  _PopoverOption(
                    title: 'Import Link',
                    subtitle: 'Paste a store URL',
                    icon: LucideIcons.link_2,
                    onTap: onLink,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  ),
                  _PopoverOption(
                    title: 'Gallery',
                    subtitle: 'Choose from photos',
                    icon: LucideIcons.image,
                    onTap: onGallery,
                  ),
                ],
              ),
            ).animate().scale(begin: const Offset(0.8, 0.8), alignment: Alignment.topRight).fadeIn(),
          ),
        ],
      ),
    );
  }
}

class _PopoverOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PopoverOption({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
              ],
            ),
          ),
          Icon(LucideIcons.chevron_right, color: Colors.white.withOpacity(0.2), size: 18),
        ],
      ),
    );
  }
}

class LinkInputOverlay extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  const LinkInputOverlay({super.key, required this.controller, required this.onClose, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black45),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 48,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xCC1E1E1E),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Import via Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                          child: const Icon(LucideIcons.x, color: Colors.white70, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Paste product URL from any store', style: TextStyle(color: Colors.white60, fontSize: 14)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'https://...',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: Colors.black45,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white10)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white10)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white30)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Fetch Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ).animate().scale(begin: const Offset(0.9, 0.9)).fadeIn(),
          ),
        ],
      ),
    );
  }
}

class ItemDetailsModal extends StatelessWidget {
  final WardrobeItem item;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  final Widget Function() imageBuilder;

  const ItemDetailsModal({super.key, required this.item, required this.onClose, required this.onDelete, required this.imageBuilder});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black87),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 64,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: imageBuilder(),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: onClose,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.category,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Added \${DateTime.fromMillisecondsSinceEpoch(item.addedAt).toString().split(' ')[0]}',
                          style: const TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onDelete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.1),
                              foregroundColor: Colors.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.red.withOpacity(0.2)),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Delete Item', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().scale(begin: const Offset(0.9, 0.9)).fadeIn(),
          ),
        ],
      ),
    );
  }
}
