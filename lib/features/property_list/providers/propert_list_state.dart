import 'package:notifyapp/models/property.dart';

enum PropertyListScreenConcreteState {
  loading,
  initial,
  error,
  fetchingMore,
  fetchedAllProperties,
}

class PropertyListScreenState {
  final List<Property> propertyList;
  final PropertyListScreenConcreteState state;
  final int page;
  final String message;

  PropertyListScreenState({
    this.propertyList = const [],
    this.state = PropertyListScreenConcreteState.initial,
    this.page = 0,
    this.message = "",
  });

  PropertyListScreenState copyWith({
    List<Property>? propertyList,
    int? page,
    PropertyListScreenConcreteState? state,
    String? message,
  }) {
    return PropertyListScreenState(
      propertyList: propertyList ?? this.propertyList,
      page: page ?? this.page,
      state: state ?? this.state,
      message: message ?? this.message,
    );
  }
}
