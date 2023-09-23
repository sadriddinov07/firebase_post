import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_post/models/post_model.dart';
import 'package:firebase_post/services/db_service.dart';

part 'main_event.dart';

part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(const MainInitial([])) {
    // on<GetAllDataEvent>(_fetchAllPost);
    on<SearchDataEvent>(_search);
    on<SortDataEvent>(_sort);
  }

  // void _fetchAllPost(GetAllDataEvent event, Emitter emit) async {
  //   emit(MainLoading(state.items));
  //   try {
  //     final list = await DBService.readAllPost();
  //     emit(FetchDataSuccess(list, "Successfully fetched!"));
  //   } catch (e) {
  //     emit(MainFailure(state.items, "Something error, try again later"));
  //   }
  // }

  void _search(SearchDataEvent event, Emitter emit) async {
    emit(MainLoading(state.items));
    try {
      final list = await DBService.search(event.title);

      emit(SearchDataSuccess(list));
    } catch (e) {
      emit(MainFailure(state.items, "Something error, try again later"));
    }
  }

  void _sort(SortDataEvent event, Emitter emit) async {
    emit(MainLoading(state.items));
    try {
      final list = await DBService.sortByPublic(event.isPublic);

      if (event.isPublic) {
        emit(GetAllDataSuccess(list));
      } else {
        emit(GetPrivateDataSuccess(list));
      }
    } catch (e) {
      emit(MainFailure(state.items, "Something error, try again later"));
    }
  }
}
