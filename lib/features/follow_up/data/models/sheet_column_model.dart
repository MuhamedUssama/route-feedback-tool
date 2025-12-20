import '../../domain/entities/sheet_column_entity.dart';

class SheetColumnModel extends SheetColumnEntity {
  const SheetColumnModel({required super.index, required super.headerName});

  factory SheetColumnModel.fromIndexedValue(int index, String value) {
    return SheetColumnModel(index: index, headerName: value);
  }
}
