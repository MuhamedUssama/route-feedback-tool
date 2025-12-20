import 'package:equatable/equatable.dart';

class SheetColumnEntity extends Equatable {
  final int index;
  final String headerName;

  const SheetColumnEntity({required this.index, required this.headerName});

  @override
  List<Object?> get props => [index, headerName];
}
