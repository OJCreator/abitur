import 'package:abitur/isolates/models/subject/subjects_model.dart';
import 'package:abitur/isolates/serializer.dart';

import '../storage/entities/subject.dart';

class SubjectIsolates {

  static SubjectsModel sortSubjects(SubjectsModel model) {
    List<Subject> evaluationDates = model.subjects.map((e) => Subject.fromJson(e)).toList();
    evaluationDates.sort((a, b) => a.name.compareTo(b.name));
    return SubjectsModel(evaluationDates.serialize());
  }
}