import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/banner_model.dart';
import '../../services/banner_service.dart';
import '../../widgets/admin_drawer.dart';
import 'dart:developer' as developer;

class AdminBannersScreen extends StatefulWidget {
  const AdminBannersScreen({Key? key}) : super(key: key);

  @override
  State<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends State<AdminBannersScreen> {
  final BannerService _bannerService = BannerService();
  bool _isLoading = true;
  List<BannerModel> _banners = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final banners = await _bannerService.getAllBanners();
      
      if (mounted) {
        setState(() {
          _banners = banners;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading banners', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load banners. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteBanner(String bannerId) async {
    try {
      await _bannerService.deleteBanner(bannerId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner deleted successfully')),
      );
      _loadBanners();
    } catch (e) {
      developer.log('Error deleting banner', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete banner: $e')),
      );
    }
  }

  Future<void> _toggleBannerStatus(String bannerId, bool newStatus) async {
    try {
      await _bannerService.toggleBannerStatus(bannerId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Banner ${newStatus ? 'activated' : 'deactivated'} successfully')),
      );
      _loadBanners();
    } catch (e) {
      developer.log('Error toggling banner status', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update banner status: $e')),
      );
    }
  }

  void _showAddEditBannerDialog({BannerModel? banner}) {
    showDialog(
      context: context,
      builder: (context) => AddEditBannerDialog(
        banner: banner,
        onSave: (newBanner) async {
          try {
            if (banner == null) {
              // Add new banner
              await _bannerService.addBanner(newBanner);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Banner added successfully')),
                );
              }
            } else {
              // Update existing banner
              await _bannerService.updateBanner(banner.id, newBanner);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Banner updated successfully')),
                );
              }
            }
            _loadBanners();
          } catch (e) {
            developer.log('Error saving banner', error: e);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save banner: $e')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Management'),
      ),
      drawer: const AdminDrawer(currentScreen: AdminScreen.banners),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppConstants.primaryColor,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBanners,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBanners,
                  child: _banners.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No banners available',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _showAddEditBannerDialog(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.primaryColor,
                                ),
                                child: const Text('Add Banner'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _banners.length,
                          itemBuilder: (context, index) {
                            final banner = _banners[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Banner image
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: banner.imageUrl.isNotEmpty
                                        ? Image.network(
                                            banner.imageUrl,
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: 180,
                                                width: double.infinity,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            height: 180,
                                            width: double.infinity,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                  
                                  // Banner details
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    banner.title,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    banner.subtitle,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '${banner.discountPercentage}% OFF',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    banner.isActive
                                                        ? Icons.check_circle
                                                        : Icons.cancel,
                                                    color: banner.isActive
                                                        ? Colors.green
                                                        : Colors.red,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    banner.isActive ? 'Active' : 'Inactive',
                                                    style: TextStyle(
                                                      color: banner.isActive
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Edit button
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              color: Colors.blue,
                                              onPressed: () => _showAddEditBannerDialog(banner: banner),
                                              tooltip: 'Edit Banner',
                                            ),
                                            // Toggle status button
                                            IconButton(
                                              icon: Icon(
                                                banner.isActive
                                                    ? Icons.unpublished
                                                    : Icons.public,
                                              ),
                                              color: banner.isActive
                                                  ? Colors.orange
                                                  : Colors.green,
                                              onPressed: () => _toggleBannerStatus(
                                                banner.id,
                                                !banner.isActive,
                                              ),
                                              tooltip: banner.isActive
                                                  ? 'Deactivate'
                                                  : 'Activate',
                                            ),
                                            // Delete button
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              color: Colors.red,
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Delete Banner'),
                                                    content: const Text(
                                                      'Are you sure you want to delete this banner? This action cannot be undone.',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          _deleteBanner(banner.id);
                                                        },
                                                        style: TextButton.styleFrom(
                                                          foregroundColor: Colors.red,
                                                        ),
                                                        child: const Text('Delete'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              tooltip: 'Delete',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditBannerDialog(),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEditBannerDialog extends StatefulWidget {
  final BannerModel? banner;
  final Function(BannerModel) onSave;

  const AddEditBannerDialog({
    Key? key,
    this.banner,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditBannerDialog> createState() => _AddEditBannerDialogState();
}

class _AddEditBannerDialogState extends State<AddEditBannerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _discountController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.banner != null) {
      _titleController.text = widget.banner!.title;
      _subtitleController.text = widget.banner!.subtitle;
      _imageUrlController.text = widget.banner!.imageUrl;
      _discountController.text = widget.banner!.discountPercentage.toString();
      _isActive = widget.banner!.isActive;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _imageUrlController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final banner = BannerModel(
        id: widget.banner?.id ?? 'temp-id',
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        discountPercentage: int.parse(_discountController.text.trim()),
        isActive: _isActive,
      );
      
      widget.onSave(banner);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.banner != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Banner' : 'Add New Banner'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(
                  labelText: 'Subtitle',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subtitle';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Image URL
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an image URL';
                  }
                  // Basic URL validation
                  if (!value.trim().startsWith('http')) {
                    return 'Please enter a valid URL starting with http:// or https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Discount percentage
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  labelText: 'Discount Percentage',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 20',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a discount percentage';
                  }
                  final discount = int.tryParse(value.trim());
                  if (discount == null || discount < 0 || discount > 100) {
                    return 'Please enter a valid percentage between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Active status
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
          ),
          child: Text(isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }
} 