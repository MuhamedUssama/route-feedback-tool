import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'navigation_state.dart';

@injectable
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void changeIndex(int index) {
    emit(state.copyWith(selectedIndex: index));
  }
}
