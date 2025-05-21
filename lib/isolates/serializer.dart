abstract class Serializable {
  Map<String, dynamic> toJson();
}

extension SerializeExtension<T extends Serializable> on List<T> {
  List<Map<String, dynamic>> serialize() {
    return map((e) => e.toJson()).toList();
  }
}