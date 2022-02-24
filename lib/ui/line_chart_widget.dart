import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../model/Track.dart';

class LineChartWidget extends StatelessWidget {
  final List<Color> gradientColors = [
    Colors.indigo, const Color.fromRGBO(204, 0, 0, 100)
  ];

  final Track track;

  LineChartWidget(this.track, {Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) => LineChart(
      LineChartData(
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: 6,
          gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(

                    color: const Color(0xff37434d)
                );
              }
          ),
          lineBarsData: [
            LineChartBarData(
                spots: [
                  FlSpot(0, 3),
                  FlSpot(2.6, 2),
                  FlSpot(4.9, 2.5),
                ],
                isCurved: true,
                colors: gradientColors,
                dotData: FlDotData(
                  show: false,
                ),
                belowBarData: BarAreaData(
                  show: true,
                  colors: gradientColors.map((color) => color.withOpacity(0.2)).toList(),
                )
            )
          ]
      )
  );
}