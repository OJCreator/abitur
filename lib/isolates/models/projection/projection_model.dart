

import 'package:abitur/utils/extensions/lists/iterable_extension.dart';

class ProjectionModel {

  final double graduationAverage;
  final int resultBlock1;
  final int resultBlock2;

  final List<ProjectionSubjectBlock1Model> block1; // subjectId -> TermModelList
  final List<ProjectionSubjectBlock2Model> block2; // subjectId -> Model

  ProjectionModel(this.graduationAverage, this.resultBlock1, this.resultBlock2, this.block1, this.block2);
}

class ProjectionSubjectBlock1Model {
  final String subjectId;
  final List<ProjectionTermModel> terms;

  ProjectionSubjectBlock1Model(this.subjectId, this.terms);

  int countingPoints() {
    return terms.sumBy((term) => term.countingPoints()).toInt();
  }
}

class ProjectionSubjectBlock2Model {
  final String subjectId;
  final ProjectionTermModel result;

  ProjectionSubjectBlock2Model(this.subjectId, this.result);

  int countingPoints() {
    return result.countingPoints();
  }
}

class ProjectionTermModel {
  int? note;
  String get noteString => note?.toString() ?? "-";
  bool projection;
  bool counting;
  final int weight;

  ProjectionTermModel(this.note, this.projection, this.counting, this.weight);

  int countingPoints() {
    if (!counting) {
      return 0;
    }
    return weight * (note ?? 0);
  }
}