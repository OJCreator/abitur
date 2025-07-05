import 'package:flutter/material.dart';

class RankingElement {
  final String title;
  final String subtitle;
  final Color color;

  RankingElement({required this.title, required this.subtitle, required this.color});
}

class StoryRankingView extends StatefulWidget {
  final String title;
  final Duration delay;
  final List<RankingElement> ranking;

  const StoryRankingView({
    super.key,
    required this.title,
    required this.ranking,
    this.delay = const Duration(seconds: 0),
  });

  @override
  State<StoryRankingView> createState() => _StoryRankingViewState();
}

class _StoryRankingViewState extends State<StoryRankingView> with TickerProviderStateMixin {
  late AnimationController _slideInController;
  late Animation<Offset> _slideInAnimation;

  late AnimationController _offsetController;
  late Animation<double> _offsetAnimation;

  late AnimationController _slideOutController;
  late Animation<Offset> _slideOutAnimation;

  bool showRanking = false;

  @override
  void initState() {
    super.initState();

    _slideInController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _slideInAnimation = Tween<Offset>(
      begin: Offset(1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideInController,
      curve: Curves.easeOut,
    ));

    _offsetController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _offsetAnimation = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(
      parent: _offsetController,
      curve: Curves.easeOut,
    ));

    _slideOutController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-1.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideOutController,
      curve: Curves.easeIn,
    ));

    startAnimation();
  }

  Future<void> startAnimation() async {
    await Future.delayed(widget.delay);
    if (!mounted) return;
    await _slideInController.forward();

    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    _offsetController.forward();
    setState(() {
      showRanking = true;
    });

    await Future.delayed(Duration(seconds: 5));
    if (!mounted) return;
    await _slideOutController.forward();
  }

  @override
  void dispose() {
    _slideInController.dispose();
    _offsetController.dispose();
    _slideOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SlideTransition(
        position: _slideOutAnimation,
        child: SlideTransition(
          position: _slideInAnimation,
          child: AnimatedBuilder(
            animation: _offsetController,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, _offsetAnimation.value),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 36),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: showRanking ? 1 : 0,
                    duration: Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: widget.ranking.asMap().entries.map((entry) {
                          final index = entry.key;
                          final r = entry.value;
                          return AnimatedSlide(
                            offset: showRanking ? Offset.zero : Offset(0, 0.2 + index * 0.05),
                            duration: Duration(milliseconds: 400 + index * 100),
                            curve: Curves.easeOut,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      r.color.withAlpha(204),
                                      r.color.withAlpha(128),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "${index + 1}",
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              r.title,
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              r.subtitle,
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
