import 'package:flutter_bloc/flutter_bloc.dart';

class ColorCubit extends Cubit<int> {
  final int? color;
  ColorCubit(this.color) : super(color ?? 0);
  void update(int index) => emit(index);
}

class ColorPressedCubit extends Cubit<bool> {
  ColorPressedCubit() : super(false);
  void toggle() => emit(!state);
}
