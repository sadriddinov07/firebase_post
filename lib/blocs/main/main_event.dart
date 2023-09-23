part of 'main_bloc.dart';

abstract class MainEvent extends Equatable {
  const MainEvent();
}

// class GetAllDataEvent extends MainEvent {
//   const GetAllDataEvent();
//
//   @override
//   List<Object?> get props => [];
// }

class SearchDataEvent extends MainEvent {
  final String title;

  const SearchDataEvent(this.title);

  @override
  List<Object?> get props => [title];
}

class SortDataEvent extends MainEvent {
  final bool isPublic;

  const SortDataEvent(this.isPublic);

  @override
  List<Object?> get props => [isPublic];
}
