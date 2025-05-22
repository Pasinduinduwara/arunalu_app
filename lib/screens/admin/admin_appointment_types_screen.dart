import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import '../../widgets/admin_drawer.dart';
import 'dart:developer' as developer;

class AdminAppointmentTypesScreen extends StatefulWidget {
  const AdminAppointmentTypesScreen({Key? key}) : super(key: key);

  @override
  State<AdminAppointmentTypesScreen> createState() => _AdminAppointmentTypesScreenState();
}

class _AdminAppointmentTypesScreenState extends State<AdminAppointmentTypesScreen> {
  final AppointmentTypeService _appointmentTypeService = AppointmentTypeService();
  bool _isLoading = true;
  List<AppointmentTypeModel> _appointmentTypes = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAppointmentTypes();
  }

  Future<void> _loadAppointmentTypes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final appointmentTypes = await _appointmentTypeService.getAllAppointmentTypes();
      
      if (mounted) {
        setState(() {
          _appointmentTypes = appointmentTypes;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading appointment types', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load appointment types. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAppointmentType(String appointmentTypeId) async {
    try {
      await _appointmentTypeService.deleteAppointmentType(appointmentTypeId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment type deleted successfully')),
      );
      _loadAppointmentTypes();
    } catch (e) {
      developer.log('Error deleting appointment type', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete appointment type: $e')),
      );
    }
  }

  Future<void> _toggleAppointmentTypeStatus(String appointmentTypeId, bool newStatus) async {
    try {
      await _appointmentTypeService.toggleAppointmentTypeStatus(appointmentTypeId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment type ${newStatus ? 'activated' : 'deactivated'} successfully')),
      );
      _loadAppointmentTypes();
    } catch (e) {
      developer.log('Error toggling appointment type status', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update appointment type status: $e')),
      );
    }
  }

  void _showAddEditAppointmentTypeDialog({AppointmentTypeModel? appointmentType}) {
    showDialog(
      context: context,
      builder: (context) => AddEditAppointmentTypeDialog(
        appointmentType: appointmentType,
        onSave: (newAppointmentType) async {
          try {
            if (appointmentType == null) {
              // Add new appointment type
              await _appointmentTypeService.addAppointmentType(newAppointmentType);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment type added successfully')),
                );
              }
            } else {
              // Update existing appointment type
              await _appointmentTypeService.updateAppointmentType(appointmentType.id, newAppointmentType);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment type updated successfully')),
                );
              }
            }
            _loadAppointmentTypes();
          } catch (e) {
            developer.log('Error saving appointment type', error: e);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save appointment type: $e')),
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
        title: const Text('Appointment Type Management'),
      ),
      drawer: const AdminDrawer(currentScreen: AdminScreen.appointmentTypes),
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
                        onPressed: _loadAppointmentTypes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAppointmentTypes,
                  child: _appointmentTypes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No appointment types available',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _showAddEditAppointmentTypeDialog(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.primaryColor,
                                ),
                                child: const Text('Add Appointment Type'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _appointmentTypes.length,
                          itemBuilder: (context, index) {
                            final appointmentType = _appointmentTypes[index];
                            return Card(
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
                                    color: appointmentType.color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    appointmentType.isEmergency
                                        ? Icons.emergency
                                        : Icons.calendar_today,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      appointmentType.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (appointmentType.isEmergency)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'EMERGENCY',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      appointmentType.description,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          appointmentType.isActive
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: appointmentType.isActive
                                              ? Colors.green
                                              : Colors.red,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          appointmentType.isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            color: appointmentType.isActive
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
                                      onPressed: () => _showAddEditAppointmentTypeDialog(
                                        appointmentType: appointmentType,
                                      ),
                                      tooltip: 'Edit',
                                    ),
                                    // Toggle status button
                                    IconButton(
                                      icon: Icon(
                                        appointmentType.isActive
                                            ? Icons.unpublished
                                            : Icons.public,
                                      ),
                                      color: appointmentType.isActive
                                          ? Colors.orange
                                          : Colors.green,
                                      onPressed: () => _toggleAppointmentTypeStatus(
                                        appointmentType.id,
                                        !appointmentType.isActive,
                                      ),
                                      tooltip: appointmentType.isActive
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
                                            title: const Text('Delete Appointment Type'),
                                            content: Text(
                                              'Are you sure you want to delete "${appointmentType.name}"? This action cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteAppointmentType(appointmentType.id);
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
                              ),
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditAppointmentTypeDialog(),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEditAppointmentTypeDialog extends StatefulWidget {
  final AppointmentTypeModel? appointmentType;
  final Function(AppointmentTypeModel) onSave;

  const AddEditAppointmentTypeDialog({
    Key? key,
    this.appointmentType,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditAppointmentTypeDialog> createState() => _AddEditAppointmentTypeDialogState();
}

class _AddEditAppointmentTypeDialogState extends State<AddEditAppointmentTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Color _selectedColor = Colors.blue;
  bool _isEmergency = false;
  bool _isActive = true;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.appointmentType != null) {
      _nameController.text = widget.appointmentType!.name;
      _descriptionController.text = widget.appointmentType!.description;
      _selectedColor = widget.appointmentType!.color;
      _isEmergency = widget.appointmentType!.isEmergency;
      _isActive = widget.appointmentType!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final appointmentType = AppointmentTypeModel(
        id: widget.appointmentType?.id ?? 'temp-id',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _selectedColor,
        isEmergency: _isEmergency,
        isActive: _isActive,
      );
      
      widget.onSave(appointmentType);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appointmentType != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Appointment Type' : 'Add New Appointment Type'),
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
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
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
              
              // Color selection
              const Text('Select Color:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableColors.map((color) {
                  final isSelected = _selectedColor.value == color.value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // Emergency toggle
              SwitchListTile(
                title: const Text('Emergency Type'),
                subtitle: const Text('Mark as emergency appointment'),
                value: _isEmergency,
                activeColor: Colors.red,
                onChanged: (value) {
                  setState(() {
                    _isEmergency = value;
                    if (value) {
                      // Auto select red color for emergency types
                      _selectedColor = Colors.red;
                    }
                  });
                },
              ),
              
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