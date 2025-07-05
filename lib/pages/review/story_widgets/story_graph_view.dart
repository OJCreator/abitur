import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StoryGraphView extends StatefulWidget {
  final String title;
  final Duration delay;
  final List<num> data;
  final String? xAxisTitle;
  final String yAxisTitle;
  final String Function(int index)? xValues;

  const StoryGraphView({
    super.key,
    required this.title,
    this.delay = const Duration(seconds: 0),
    required this.data,
    required this.xAxisTitle,
    required this.yAxisTitle,
    this.xValues,
  });

  @override
  State<StoryGraphView> createState() => _StoryGraphViewState();
}

class _StoryGraphViewState extends State<StoryGraphView> with TickerProviderStateMixin {
  late AnimationController _slideInController;
  late Animation<Offset> _slideInAnimation;

  late AnimationController _offsetController;
  late Animation<double> _offsetAnimation;

  late AnimationController _slideOutController;
  late Animation<Offset> _slideOutAnimation;

  bool showSubtitle = false;

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
      showSubtitle = true;
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
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: showSubtitle ? 1 : 0,
                    duration: Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _StoryGraphViewGraph(
                        widget.data,
                        widget.xAxisTitle,
                        widget.yAxisTitle,
                        widget.xValues
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

class _StoryGraphViewGraph extends StatelessWidget {

  final List<num> data;
  final String? xAxisTitle;
  final String yAxisTitle;
  final String Function(int index)? xValues;

  const _StoryGraphViewGraph(this.data, this.xAxisTitle, this.yAxisTitle, this.xValues);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: data.length.toDouble()-1,
            minY: 0,
            maxY: data.map((e) => e.toDouble()).reduce((curr, next) => curr > next ? curr : next).toDouble(),

            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                axisNameWidget: Text(yAxisTitle),
                axisNameSize: 24,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        xValues != null ? xValues!(value.toInt()) : value.toInt().toString(),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: xAxisTitle == null ? null : Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(xAxisTitle!),
                ),
                axisNameSize: 24,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: (data.map((e) => e.toDouble()).reduce((curr, next) => curr > next ? curr : next) / 5).ceilToDouble(),
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.all(3),
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),

              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),

            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              verticalInterval: 1,
              horizontalInterval: (data.map((e) => e.toDouble()).reduce((curr, next) => curr > next ? curr : next) / 5).ceilToDouble(),
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withAlpha(77),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey.withAlpha(77),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              },
            ),

            borderData: FlBorderData(
              show: false, // Rahmen entfernt
            ),

            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                  data.length,
                      (index) => FlSpot(
                    index.toDouble(),
                    data[index].toDouble(),
                  ),
                ),
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withAlpha(102),
                      Colors.blue.withAlpha(26),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );


  }
}

