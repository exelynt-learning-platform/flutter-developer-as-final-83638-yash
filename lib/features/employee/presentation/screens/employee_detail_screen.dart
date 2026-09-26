import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/employee.dart';
import '../bloc/employee_bloc.dart';
import 'employee_form_screen.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete "${employee.name}" (ID: ${employee.id})? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<EmployeeBloc>().add(DeleteEmployeeEvent(employee.id));
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = employee.avatar;
    final hasValidAvatar = avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Employee',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EmployeeFormScreen(employee: employee),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Employee',
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: hasValidAvatar ? NetworkImage(avatarUrl) : null,
                      child: !hasValidAvatar
                          ? Text(
                              employee.name.isNotEmpty
                                  ? employee.name[0].toUpperCase()
                                  : 'E',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      employee.name,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Employee ID: #${employee.id}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Details List Card
            Card(
              child: Column(
                children: [
                  _buildDetailTile(
                    context,
                    icon: Icons.email_outlined,
                    label: 'Email Address',
                    value: employee.email,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildDetailTile(
                    context,
                    icon: Icons.phone_outlined,
                    label: 'Mobile Number',
                    value: employee.mobile,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildDetailTile(
                    context,
                    icon: Icons.public_outlined,
                    label: 'Country',
                    value: employee.country,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildDetailTile(
                    context,
                    icon: Icons.map_outlined,
                    label: 'State',
                    value: employee.state,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildDetailTile(
                    context,
                    icon: Icons.location_city_outlined,
                    label: 'District',
                    value: employee.district,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      subtitle: Text(
        value.isNotEmpty ? value : 'N/A',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
