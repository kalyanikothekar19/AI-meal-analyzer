// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealResultAdapter extends TypeAdapter<MealResult> {
  @override
  final int typeId = 0;

  @override
  MealResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealResult(
      mealName: fields[0] as String,
      calories: fields[1] as int,
      protein: fields[2] as double,
      carbs: fields[3] as double,
      fat: fields[4] as double,
      healthTip: fields[5] as String,
      imagePath: fields[6] as String,
      analyzedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MealResult obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.mealName)
      ..writeByte(1)
      ..write(obj.calories)
      ..writeByte(2)
      ..write(obj.protein)
      ..writeByte(3)
      ..write(obj.carbs)
      ..writeByte(4)
      ..write(obj.fat)
      ..writeByte(5)
      ..write(obj.healthTip)
      ..writeByte(6)
      ..write(obj.imagePath)
      ..writeByte(7)
      ..write(obj.analyzedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
