class ProjectionModel {

  final double graduationAverage;
  final int resultBlock1;
  final int resultBlock2;

  final Map<String, List<ProjectionTermModel>> block1; // subjectId -> TermModelList
  final Map<String, ProjectionTermModel> block2; // subjectId -> Model

  ProjectionModel(this.graduationAverage, this.resultBlock1, this.resultBlock2, this.block1, this.block2);
}

class ProjectionTermModel {
  final int? note;
  String get noteString => note?.toString() ?? "-";
  final bool projection;
  bool counting;
  final int weight;

  ProjectionTermModel(this.note, this.projection, this.counting, this.weight);
}