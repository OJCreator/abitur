import 'package:abitur/sqlite/entities/graduation_evaluation.dart';
import 'package:abitur/sqlite/entities/subject.dart';

class SubjectPageModel {

  final Subject? subject;
  final GraduationEvaluation? graduationEvaluation;

  SubjectPageModel({required this.subject, required this.graduationEvaluation});


}