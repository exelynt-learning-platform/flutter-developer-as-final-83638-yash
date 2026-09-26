import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';

// EVENTS
abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmployeesEvent extends EmployeeEvent {
  final bool forceRefresh;

  const LoadEmployeesEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class SearchEmployeesByIdEvent extends EmployeeEvent {
  final String id;

  const SearchEmployeesByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterEmployeesEvent extends EmployeeEvent {
  final String query;
  final String filterBy; // 'All', 'Name', 'Email', 'Mobile', 'Country', 'ID'

  const FilterEmployeesEvent({
    required this.query,
    required this.filterBy,
  });

  @override
  List<Object?> get props => [query, filterBy];
}

class AddEmployeeEvent extends EmployeeEvent {
  final Employee employee;

  const AddEmployeeEvent(this.employee);

  @override
  List<Object?> get props => [employee];
}

class UpdateEmployeeEvent extends EmployeeEvent {
  final Employee employee;

  const UpdateEmployeeEvent(this.employee);

  @override
  List<Object?> get props => [employee];
}

class DeleteEmployeeEvent extends EmployeeEvent {
  final String id;

  const DeleteEmployeeEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadCountriesEvent extends EmployeeEvent {}


// STATES
abstract class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object?> get props => [];
}

class EmployeeInitialState extends EmployeeState {}

class EmployeeLoadingState extends EmployeeState {}

class EmployeeLoadedState extends EmployeeState {
  final List<Employee> allEmployees;
  final List<Employee> filteredEmployees;
  final List<Country> countries;
  final String searchQuery;
  final String filterType;
  final String? successMessage;
  final bool isSubmitting;

  const EmployeeLoadedState({
    required this.allEmployees,
    required this.filteredEmployees,
    this.countries = const [],
    this.searchQuery = '',
    this.filterType = 'All',
    this.successMessage,
    this.isSubmitting = false,
  });

  EmployeeLoadedState copyWith({
    List<Employee>? allEmployees,
    List<Employee>? filteredEmployees,
    List<Country>? countries,
    String? searchQuery,
    String? filterType,
    String? successMessage,
    bool? isSubmitting,
    bool clearSuccessMessage = false,
  }) {
    return EmployeeLoadedState(
      allEmployees: allEmployees ?? this.allEmployees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      countries: countries ?? this.countries,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        allEmployees,
        filteredEmployees,
        countries,
        searchQuery,
        filterType,
        successMessage,
        isSubmitting,
      ];
}

class EmployeeErrorState extends EmployeeState {
  final String message;

  const EmployeeErrorState(this.message);

  @override
  List<Object?> get props => [message];
}


// BLOC
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository repository;

  EmployeeBloc({required this.repository}) : super(EmployeeInitialState()) {
    on<LoadEmployeesEvent>(_onLoadEmployees);
    on<SearchEmployeesByIdEvent>(_onSearchById);
    on<FilterEmployeesEvent>(_onFilterEmployees);
    on<AddEmployeeEvent>(_onAddEmployee);
    on<UpdateEmployeeEvent>(_onUpdateEmployee);
    on<DeleteEmployeeEvent>(_onDeleteEmployee);
    on<LoadCountriesEvent>(_onLoadCountries);
  }

  Future<void> _onLoadEmployees(
    LoadEmployeesEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    List<Country> countries = [];
    if (state is EmployeeLoadedState) {
      countries = (state as EmployeeLoadedState).countries;
    }

    if (state is! EmployeeLoadedState || event.forceRefresh) {
      emit(EmployeeLoadingState());
    }

    try {
      final employees = await repository.getEmployees();
      if (countries.isEmpty) {
        try {
          countries = await repository.getCountries();
        } catch (_) {}
      }

      emit(EmployeeLoadedState(
        allEmployees: employees,
        filteredEmployees: employees,
        countries: countries,
      ));
    } on Failure catch (e) {
      emit(EmployeeErrorState(e.message));
    } catch (e) {
      emit(EmployeeErrorState('Failed to load employees: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCountries(
    LoadCountriesEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      final countries = await repository.getCountries();
      if (state is EmployeeLoadedState) {
        final currentState = state as EmployeeLoadedState;
        emit(currentState.copyWith(countries: countries));
      }
    } catch (_) {}
  }

  Future<void> _onSearchById(
    SearchEmployeesByIdEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state is EmployeeLoadedState) {
      final currentState = state as EmployeeLoadedState;
      final query = event.id.trim();

      if (query.isEmpty) {
        emit(currentState.copyWith(
          searchQuery: '',
          filteredEmployees: currentState.allEmployees,
          clearSuccessMessage: true,
        ));
        return;
      }

      // First check local list
      final localMatch = currentState.allEmployees
          .where((emp) => emp.id.toLowerCase() == query.toLowerCase())
          .toList();

      if (localMatch.isNotEmpty) {
        emit(currentState.copyWith(
          searchQuery: query,
          filterType: 'ID',
          filteredEmployees: localMatch,
          clearSuccessMessage: true,
        ));
      } else {
        // Fetch from API by ID
        emit(currentState.copyWith(isSubmitting: true));
        try {
          final employee = await repository.getEmployeeById(query);
          emit(currentState.copyWith(
            searchQuery: query,
            filterType: 'ID',
            filteredEmployees: [employee],
            isSubmitting: false,
            clearSuccessMessage: true,
          ));
        } catch (_) {
          emit(currentState.copyWith(
            searchQuery: query,
            filterType: 'ID',
            filteredEmployees: [],
            isSubmitting: false,
            clearSuccessMessage: true,
          ));
        }
      }
    }
  }

  void _onFilterEmployees(
    FilterEmployeesEvent event,
    Emitter<EmployeeState> emit,
  ) {
    if (state is EmployeeLoadedState) {
      final currentState = state as EmployeeLoadedState;
      final q = event.query.toLowerCase().trim();
      final filter = event.filterBy;

      if (q.isEmpty) {
        emit(currentState.copyWith(
          searchQuery: '',
          filterType: filter,
          filteredEmployees: currentState.allEmployees,
          clearSuccessMessage: true,
        ));
        return;
      }

      List<Employee> filtered = currentState.allEmployees.where((emp) {
        switch (filter) {
          case 'Name':
            return emp.name.toLowerCase().contains(q);
          case 'Email':
            return emp.email.toLowerCase().contains(q);
          case 'Mobile':
            return emp.mobile.contains(q);
          case 'Country':
            return emp.country.toLowerCase().contains(q);
          case 'ID':
            return emp.id.toLowerCase().contains(q);
          case 'All':
          default:
            return emp.name.toLowerCase().contains(q) ||
                emp.email.toLowerCase().contains(q) ||
                emp.mobile.contains(q) ||
                emp.country.toLowerCase().contains(q) ||
                emp.id.toLowerCase().contains(q);
        }
      }).toList();

      emit(currentState.copyWith(
        searchQuery: event.query,
        filterType: filter,
        filteredEmployees: filtered,
        clearSuccessMessage: true,
      ));
    }
  }

  Future<void> _onAddEmployee(
    AddEmployeeEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state is EmployeeLoadedState) {
      final currentState = state as EmployeeLoadedState;
      emit(currentState.copyWith(isSubmitting: true));

      try {
        final newEmployee = await repository.createEmployee(event.employee);
        final updatedList = [newEmployee, ...currentState.allEmployees];

        emit(currentState.copyWith(
          allEmployees: updatedList,
          filteredEmployees: updatedList,
          isSubmitting: false,
          successMessage: 'Employee "${newEmployee.name}" created successfully!',
        ));
      } on Failure catch (e) {
        emit(EmployeeErrorState(e.message));
        // Restore loaded state
        emit(currentState.copyWith(isSubmitting: false));
      } catch (e) {
        emit(EmployeeErrorState('Failed to add employee: ${e.toString()}'));
        emit(currentState.copyWith(isSubmitting: false));
      }
    }
  }

  Future<void> _onUpdateEmployee(
    UpdateEmployeeEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state is EmployeeLoadedState) {
      final currentState = state as EmployeeLoadedState;
      emit(currentState.copyWith(isSubmitting: true));

      try {
        final updatedEmployee =
            await repository.updateEmployee(event.employee.id, event.employee);

        final updatedAllList = currentState.allEmployees.map((emp) {
          return emp.id == updatedEmployee.id ? updatedEmployee : emp;
        }).toList();

        final updatedFilteredList = currentState.filteredEmployees.map((emp) {
          return emp.id == updatedEmployee.id ? updatedEmployee : emp;
        }).toList();

        emit(currentState.copyWith(
          allEmployees: updatedAllList,
          filteredEmployees: updatedFilteredList,
          isSubmitting: false,
          successMessage: 'Employee "${updatedEmployee.name}" updated successfully!',
        ));
      } on Failure catch (e) {
        emit(EmployeeErrorState(e.message));
        emit(currentState.copyWith(isSubmitting: false));
      } catch (e) {
        emit(EmployeeErrorState('Failed to update employee: ${e.toString()}'));
        emit(currentState.copyWith(isSubmitting: false));
      }
    }
  }

  Future<void> _onDeleteEmployee(
    DeleteEmployeeEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state is EmployeeLoadedState) {
      final currentState = state as EmployeeLoadedState;

      // Immediate UI update (Optimistic delete)
      final targetEmployee = currentState.allEmployees.firstWhere(
        (e) => e.id == event.id,
        orElse: () => Employee(
          id: event.id,
          name: 'Employee',
          email: '',
          mobile: '',
          country: '',
          state: '',
          district: '',
        ),
      );

      final updatedAll = currentState.allEmployees.where((e) => e.id != event.id).toList();
      final updatedFiltered = currentState.filteredEmployees.where((e) => e.id != event.id).toList();

      emit(currentState.copyWith(
        allEmployees: updatedAll,
        filteredEmployees: updatedFiltered,
        successMessage: 'Employee "${targetEmployee.name}" deleted successfully.',
      ));

      try {
        await repository.deleteEmployee(event.id);
      } catch (e) {
        // Rollback on remote error
        emit(currentState.copyWith(
          allEmployees: currentState.allEmployees,
          filteredEmployees: currentState.filteredEmployees,
          successMessage: null,
        ));
        emit(EmployeeErrorState('Failed to delete employee: ${e.toString()}'));
      }
    }
  }
}
