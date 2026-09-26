import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/employee.dart';
import '../bloc/employee_bloc.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _stateController;
  late TextEditingController _districtController;

  String? _selectedCountry;
  bool get _isEditing => widget.employee != null;

  static final RegExp _emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp _mobileRegExp = RegExp(r'^[0-9]{10}$');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee?.name ?? '');
    _emailController = TextEditingController(text: widget.employee?.email ?? '');
    _mobileController = TextEditingController(text: widget.employee?.mobile ?? '');
    _stateController = TextEditingController(text: widget.employee?.state ?? '');
    _districtController = TextEditingController(text: widget.employee?.district ?? '');
    _selectedCountry = widget.employee?.country;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCountry == null || _selectedCountry!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a country')),
        );
        return;
      }

      final employeeData = Employee(
        id: widget.employee?.id ?? '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        country: _selectedCountry!,
        state: _stateController.text.trim(),
        district: _districtController.text.trim(),
        avatar: widget.employee?.avatar ??
            'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/male/512/${(DateTime.now().millisecondsSinceEpoch % 90) + 1}.jpg',
        createdAt: widget.employee?.createdAt ?? DateTime.now().toIso8601String(),
      );

      if (_isEditing) {
        context.read<EmployeeBloc>().add(UpdateEmployeeEvent(employeeData));
      } else {
        context.read<EmployeeBloc>().add(AddEmployeeEvent(employeeData));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Employee' : 'Add New Employee'),
      ),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          List<Country> countries = [];
          bool isSubmitting = false;

          if (state is EmployeeLoadedState) {
            countries = state.countries;
            isSubmitting = state.isSubmitting;
          }

          // Build country dropdown options
          final countryNames = countries.map((c) => c.name).toSet().toList();
          if (_selectedCountry != null && !countryNames.contains(_selectedCountry)) {
            countryNames.insert(0, _selectedCountry!);
          }
          if (countryNames.isEmpty) {
            countryNames.addAll(['India', 'United States', 'United Kingdom', 'Canada', 'Australia', 'Germany']);
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Card Header
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: theme.colorScheme.primary,
                              child: Icon(
                                _isEditing ? Icons.edit_note : Icons.person_add_alt_1,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isEditing ? 'Update Employee Record' : 'Create Employee Profile',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Please provide accurate contact & location details.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name Input
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: 'e.g. Mansi Sharma',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Input
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address *',
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'e.g. employee@company.com',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email address is required';
                        }
                        if (!_emailRegExp.hasMatch(value.trim())) {
                          return 'Enter a valid email address (e.g. user@domain.com)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mobile Input
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number * (10 Digits)',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: 'e.g. 9876543210',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Mobile number is required';
                        }
                        if (!_mobileRegExp.hasMatch(value.trim())) {
                          return 'Enter a valid 10-digit mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Country Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: countryNames.contains(_selectedCountry) ? _selectedCountry : null,
                      decoration: const InputDecoration(
                        labelText: 'Country *',
                        prefixIcon: Icon(Icons.public_outlined),
                      ),
                      items: countryNames.map((countryName) {
                        return DropdownMenuItem<String>(
                          value: countryName,
                          child: Text(countryName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a country';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // State Input
                    TextFormField(
                      controller: _stateController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'State *',
                        prefixIcon: Icon(Icons.map_outlined),
                        hintText: 'e.g. Maharashtra',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'State is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // District Input
                    TextFormField(
                      controller: _districtController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'District / City *',
                        prefixIcon: Icon(Icons.location_city_outlined),
                        hintText: 'e.g. Pune',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'District is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: isSubmitting ? null : _submitForm,
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isEditing ? 'UPDATE EMPLOYEE' : 'SAVE EMPLOYEE'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
