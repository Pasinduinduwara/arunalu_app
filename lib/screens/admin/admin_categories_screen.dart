import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';
import '../../widgets/admin_drawer.dart';
import 'dart:developer' as developer;

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final CategoryService _categoryService = CategoryService();
  bool _isLoading = true;
  List<CategoryModel> _categories = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final categories = await _categoryService.getAllCategories();
      
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading categories', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load categories. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteCategory(String categoryId) async {
    try {
      await _categoryService.deleteCategory(categoryId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully')),
      );
      _loadCategories();
    } catch (e) {
      developer.log('Error deleting category', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete category: $e')),
      );
    }
  }

  Future<void> _toggleCategoryStatus(String categoryId, bool newStatus) async {
    try {
      await _categoryService.toggleCategoryStatus(categoryId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category ${newStatus ? 'activated' : 'deactivated'} successfully')),
      );
      _loadCategories();
    } catch (e) {
      developer.log('Error toggling category status', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update category status: $e')),
      );
    }
  }

  void _showAddEditCategoryDialog({CategoryModel? category}) {
    showDialog(
      context: context,
      builder: (context) => AddEditCategoryDialog(
        category: category,
        onSave: (newCategory) async {
          try {
            if (category == null) {
              // Add new category
              await _categoryService.addCategory(newCategory);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category added successfully')),
                );
              }
            } else {
              // Update existing category
              await _categoryService.updateCategory(category.id, newCategory);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category updated successfully')),
                );
              }
            }
            _loadCategories();
          } catch (e) {
            developer.log('Error saving category', error: e);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save category: $e')),
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
        title: const Text('Category Management'),
      ),
      drawer: const AdminDrawer(currentScreen: AdminScreen.categories),
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
                        onPressed: _loadCategories,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCategories,
                  child: _categories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No categories available',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _showAddEditCategoryDialog(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.primaryColor,
                                ),
                                child: const Text('Add Category'),
                              ),
                            ],
                          ),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _categories.length,
                          onReorder: (oldIndex, newIndex) async {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            
                            final item = _categories.removeAt(oldIndex);
                            _categories.insert(newIndex, item);
                            
                            // Update the sort order in Firestore
                            try {
                              final categoryIds = _categories.map((c) => c.id).toList();
                              await _categoryService.reorderCategories(categoryIds);
                              
                              // Refresh the list to get updated sort orders
                              _loadCategories();
                            } catch (e) {
                              developer.log('Error reordering categories', error: e);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to reorder categories: $e')),
                              );
                            }
                          },
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return Card(
                              key: Key(category.id),
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            category.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.category,
                                                size: 24,
                                                color: Colors.grey,
                                              );
                                            },
                                          ),
                                        )
                                      : const Icon(
                                          Icons.category,
                                          size: 24,
                                          color: Colors.grey,
                                        ),
                                ),
                                title: Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Icon(
                                      category.isActive
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: category.isActive
                                          ? Colors.green
                                          : Colors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      category.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        color: category.isActive
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Edit button
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      color: Colors.blue,
                                      onPressed: () => _showAddEditCategoryDialog(category: category),
                                      tooltip: 'Edit Category',
                                    ),
                                    // Toggle status button
                                    IconButton(
                                      icon: Icon(
                                        category.isActive
                                            ? Icons.unpublished
                                            : Icons.public,
                                      ),
                                      color: category.isActive
                                          ? Colors.orange
                                          : Colors.green,
                                      onPressed: () => _toggleCategoryStatus(
                                        category.id,
                                        !category.isActive,
                                      ),
                                      tooltip: category.isActive
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
                                            title: const Text('Delete Category'),
                                            content: Text(
                                              'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteCategory(category.id);
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
                                    // Drag handle
                                    const Icon(
                                      Icons.drag_handle,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCategoryDialog(),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEditCategoryDialog extends StatefulWidget {
  final CategoryModel? category;
  final Function(CategoryModel) onSave;

  const AddEditCategoryDialog({
    Key? key,
    this.category,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _imageUrlController.text = widget.category!.imageUrl ?? '';
      _isActive = widget.category!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final category = CategoryModel(
        id: widget.category?.id ?? 'temp-id',
        name: _nameController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        sortOrder: widget.category?.sortOrder ?? 0,
        isActive: _isActive,
      );
      
      widget.onSave(category);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Category' : 'Add New Category'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Image URL (optional)
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    // Basic URL validation
                    if (!value.trim().startsWith('http')) {
                      return 'Please enter a valid URL starting with http:// or https://';
                    }
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