import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../domain/entities/employee.dart';
import '../bloc/employee_bloc.dart';
import 'employee_detail_screen.dart';
import 'employee_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All'; // 'All', 'Name', 'Email', 'Mobile', 'Country', 'ID'
  bool _isSearchExpanded = false;

  final List<String> _filterOptions = ['All', 'Name', 'Email', 'Mobile', 'Country', 'ID'];

  @override
  void initState() {
    super.initState();
    // Load employees on initial launch
    context.read<EmployeeBloc>().add(const LoadEmployeesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_selectedFilter == 'ID') {
      context.read<EmployeeBloc>().add(SearchEmployeesByIdEvent(query));
    } else {
      context.read<EmployeeBloc>().add(
            FilterEmployeesEvent(query: query, filterBy: _selectedFilter),
          );
    }
  }

  void _confirmDelete(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to delete ${employee.name}? This will remove their record permanently.',
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
              Navigator.pop(dialogContext);
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
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isSearchExpanded
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: _selectedFilter == 'ID'
                        ? 'Search by Employee ID...'
                        : 'Search by $_selectedFilter...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  onChanged: _onSearchChanged,
                )
              : const Text('Employee Dashboard'),
          actions: [
            IconButton(
              icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
              tooltip: _isSearchExpanded ? 'Close Search' : 'Search',
              onPressed: () {
                setState(() {
                  _isSearchExpanded = !_isSearchExpanded;
                  if (!_isSearchExpanded) {
                    _searchController.clear();
                    _onSearchChanged('');
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              tooltip: 'Toggle Theme',
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            ),
          ],
        ),
        drawer: _buildAppDrawer(context),
        body: BlocConsumer<EmployeeBloc, EmployeeState>(
          listener: (context, state) {
            if (state is EmployeeLoadedState && state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green.shade700,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state is EmployeeErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () {
                      context.read<EmployeeBloc>().add(const LoadEmployeesEvent(forceRefresh: true));
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is EmployeeLoadingState) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Fetching employees from server...'),
                  ],
                ),
              );
            }

            if (state is EmployeeErrorState) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load employees',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<EmployeeBloc>()
                              .add(const LoadEmployeesEvent(forceRefresh: true));
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is EmployeeLoadedState) {
              final employees = state.filteredEmployees;
              final totalCount = state.allEmployees.length;

              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<EmployeeBloc>()
                      .add(const LoadEmployeesEvent(forceRefresh: true));
                },
                child: Column(
                  children: [
                    // Search & Filter Header Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: theme.colorScheme.surface,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Quick Stat Chip
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$totalCount Employees',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Filter Dropdown Selector
                              const Text(
                                'Filter by: ',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: _selectedFilter,
                                underline: const SizedBox(),
                                items: _filterOptions.map((opt) {
                                  return DropdownMenuItem(
                                    value: opt,
                                    child: Text(
                                      opt,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedFilter = val;
                                    });
                                    _onSearchChanged(_searchController.text);
                                  }
                                },
                              ),
                            ],
                          ),

                          // Search Bar Input (when not in AppBar)
                          if (!_isSearchExpanded) ...[
                            const SizedBox(height: 8),
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: _selectedFilter == 'ID'
                                    ? 'Enter exact Employee ID...'
                                    : 'Search by $_selectedFilter...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          _onSearchChanged('');
                                        },
                                      )
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              onChanged: _onSearchChanged,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Employee List or Empty View
                    Expanded(
                      child: employees.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person_search_outlined,
                                        size: 72,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No employees found',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _searchController.text.isNotEmpty
                                            ? 'No matching records for "${_searchController.text}" under filter "$_selectedFilter".'
                                            : 'Tap "+" below to add your first employee.',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: employees.length,
                              itemBuilder: (context, index) {
                                final employee = employees[index];
                                return _buildEmployeeCard(context, employee);
                              },
                            ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmployeeFormScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Employee'),
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, Employee employee) {
    final theme = Theme.of(context);
    final avatarUrl = employee.avatar;
    final hasValidAvatar = avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EmployeeDetailScreen(employee: employee),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar with fallback
              CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                backgroundImage: hasValidAvatar ? NetworkImage(avatarUrl) : null,
                child: !hasValidAvatar
                    ? Text(
                        employee.name.isNotEmpty ? employee.name[0].toUpperCase() : 'E',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),

              // Employee Summary Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${employee.id}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          employee.mobile,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.public_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            employee.country,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons (Edit & Delete)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmployeeFormScreen(employee: employee),
                      ),
                    );
                  } else if (value == 'delete') {
                    _confirmDelete(context, employee);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Delete',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String displayName = 'Admin User';
        String email = 'admin@company.com';
        String? photoUrl;

        if (authState is Authenticated) {
          displayName = authState.user.displayName;
          email = authState.user.email;
          photoUrl = authState.user.photoUrl;
        }

        final hasValidPhoto = photoUrl != null &&
            photoUrl.isNotEmpty &&
            (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'));

        return Drawer(
          child: Column(
            children: [
              // User Account Header
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: hasValidPhoto ? NetworkImage(photoUrl) : null,
                  child: !hasValidPhoto
                      ? Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : null,
                ),
                accountName: Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                accountEmail: Text(email),
              ),

              ListTile(
                leading: const Icon(Icons.dashboard_outlined),
                title: const Text('Dashboard'),
                selected: true,
                onTap: () => Navigator.pop(context),
              ),

              ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: const Text('Add Employee'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmployeeFormScreen()),
                  );
                },
              ),

              ListTile(
                leading: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                title: Text(isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme'),
                onTap: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),

              const Spacer(),
              const Divider(),

              // Logout Button
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
