import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/service_model.dart';
import '../../services/service_service.dart';
import '../../widgets/admin_drawer.dart';
import 'dart:developer' as developer;

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({Key? key}) : super(key: key);

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  final ServiceService _serviceService = ServiceService();
  bool _isLoading = true;
  List<ServiceModel> _services = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final services = await _serviceService.getAllServices();
      
      if (mounted) {
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading services', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load services. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteService(String serviceId) async {
    try {
      await _serviceService.deleteService(serviceId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service deleted successfully')),
      );
      _loadServices();
    } catch (e) {
      developer.log('Error deleting service', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete service: $e')),
      );
    }
  }

  Future<void> _toggleServiceStatus(String serviceId, bool newStatus) async {
    try {
      await _serviceService.toggleServiceStatus(serviceId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service ${newStatus ? 'activated' : 'deactivated'} successfully')),
      );
      _loadServices();
    } catch (e) {
      developer.log('Error toggling service status', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update service status: $e')),
      );
    }
  }

  void _showAddEditServiceDialog({ServiceModel? service}) {
    showDialog(
      context: context,
      builder: (context) => AddEditServiceDialog(
        service: service,
        onSave: (newService) async {
          try {
            if (service == null) {
              // Add new service
              await _serviceService.addService(newService);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Service added successfully')),
                );
              }
            } else {
              // Update existing service
              await _serviceService.updateService(service.id, newService);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Service updated successfully')),
                );
              }
            }
            _loadServices();
          } catch (e) {
            developer.log('Error saving service', error: e);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save service: $e')),
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
        title: const Text('Service Management'),
      ),
      drawer: const AdminDrawer(currentScreen: AdminScreen.services),
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
                        onPressed: _loadServices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadServices,
                  child: _services.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No services available',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _showAddEditServiceDialog(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.primaryColor,
                                ),
                                child: const Text('Add Service'),
                              ),
                            ],
                          ),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _services.length,
                          onReorder: (oldIndex, newIndex) async {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            
                            final item = _services.removeAt(oldIndex);
                            _services.insert(newIndex, item);
                            
                            // Update the sort order in Firestore
                            try {
                              final serviceIds = _services.map((s) => s.id).toList();
                              await _serviceService.reorderServices(serviceIds);
                              
                              // Refresh the list to get updated sort orders
                              _loadServices();
                            } catch (e) {
                              developer.log('Error reordering services', error: e);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to reorder services: $e')),
                              );
                            }
                          },
                          itemBuilder: (context, index) {
                            final service = _services[index];
                            return Card(
                              key: Key(service.id),
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
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _serviceService.getIconDataFromName(service.iconName),
                                    color: AppConstants.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  service.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      service.description,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          service.isActive
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: service.isActive
                                              ? Colors.green
                                              : Colors.red,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          service.isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            color: service.isActive
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
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
                                      onPressed: () => _showAddEditServiceDialog(service: service),
                                      tooltip: 'Edit Service',
                                    ),
                                    // Toggle status button
                                    IconButton(
                                      icon: Icon(
                                        service.isActive
                                            ? Icons.unpublished
                                            : Icons.public,
                                      ),
                                      color: service.isActive
                                          ? Colors.orange
                                          : Colors.green,
                                      onPressed: () => _toggleServiceStatus(
                                        service.id,
                                        !service.isActive,
                                      ),
                                      tooltip: service.isActive
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
                                            title: const Text('Delete Service'),
                                            content: Text(
                                              'Are you sure you want to delete "${service.name}"? This action cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteService(service.id);
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
        onPressed: () => _showAddEditServiceDialog(),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEditServiceDialog extends StatefulWidget {
  final ServiceModel? service;
  final Function(ServiceModel) onSave;

  const AddEditServiceDialog({
    Key? key,
    this.service,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditServiceDialog> createState() => _AddEditServiceDialogState();
}

class _AddEditServiceDialogState extends State<AddEditServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedIconName = 'miscellaneous_services';
  bool _isActive = true;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'build', 'label': 'Build'},
    {'name': 'electrical_services', 'label': 'Electrical'},
    {'name': 'miscellaneous_services', 'label': 'Miscellaneous'},
    {'name': 'home_repair_service', 'label': 'Home Repair'},
    {'name': 'construction', 'label': 'Construction'},
    {'name': 'plumbing', 'label': 'Plumbing'},
    {'name': 'settings', 'label': 'Settings'},
    {'name': 'work', 'label': 'Work'},
    {'name': 'engineering', 'label': 'Engineering'},
    {'name': 'handyman', 'label': 'Handyman'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description;
      _imageUrlController.text = widget.service!.imageUrl ?? '';
      _selectedIconName = widget.service!.iconName;
      _isActive = widget.service!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final service = ServiceModel(
        id: widget.service?.id ?? 'temp-id',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        iconName: _selectedIconName,
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        sortOrder: widget.service?.sortOrder ?? 0,
        isActive: _isActive,
      );
      
      widget.onSave(service);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.service != null;
    final serviceService = ServiceService();
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Service' : 'Add New Service'),
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
                  labelText: 'Service Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a service name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Icon selection
              const Text('Select Icon:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableIcons.map((iconData) {
                  final isSelected = _selectedIconName == iconData['name'];
                  final icon = serviceService.getIconDataFromName(iconData['name']);
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIconName = iconData['name'];
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppConstants.primaryColor 
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected ? Colors.white : Colors.grey[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          iconData['label'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? AppConstants.primaryColor : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
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