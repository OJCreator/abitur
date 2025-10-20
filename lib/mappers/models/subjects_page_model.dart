import '../../sqlite/entities/subject.dart';

class SubjectsPageModel {

  final bool timeToChoseGraduationSubjects;
  final List<Subject> subjects;
  final Map<Subject, bool> isGraduationSubject;

  SubjectsPageModel({required this.timeToChoseGraduationSubjects, required this.subjects, required this.isGraduationSubject});
}