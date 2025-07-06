import 'package:flutter/cupertino.dart';

abstract class Story extends Widget {

  const Story({super.key});

  Duration getDuration();
  void pause();
  void resume();
  void restart();
}