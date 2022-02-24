import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:personal_tracking_app/model/track.dart';
import '../model/geo_position.dart';

class LineChartWidget extends StatelessWidget {
  final List<Color> gradientColors = [
    Colors.indigo,
    const Color.fromRGBO(204, 0, 0, 100)
  ];

  final Track track;

  LineChartWidget(this.track, {Key? key}) : super(key: key);

  List<FlSpot> _getSpotsList(Track track) {
    var spots = <FlSpot>[];
    for (int i = 0; i < track.positions.length; i++) {
      GeoPosition currentPos = track.positions.elementAt(i);
      spots.add(FlSpot(track.calcDistanceAt(i), currentPos.altitude!));
    }
    return spots;
  }

  @override
  Widget build (BuildContext context) {
    return LineChart(LineChartData(
      titlesData: FlTitlesData(
          bottomTitles: SideTitles(showTitles: false),
          rightTitles: SideTitles(showTitles: false),
          topTitles: SideTitles(
            showTitles: true,
            reservedSize: 14,
          ),
          leftTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
          )),
      axisTitleData: FlAxisTitleData(
          leftTitle: AxisTitle(
              showTitle: true,
              margin: 0,
              titleText: "altitude in meters",
              textAlign: TextAlign.center),
          topTitle: AxisTitle(
              showTitle: true,
              margin: 0,
              titleText: "distance in meters",
              textAlign: TextAlign.center)),
      minX: 0,
      maxX: track.totalDistance.toDouble(),
      minY: track.minAltitude,
      maxY: track.maxAltitude,
      gridData: FlGridData(
        show: true,
      ),
      lineBarsData: [
        LineChartBarData(
            spots: _getSpotsList(track),
            isCurved: true,
            preventCurveOvershootingThreshold: 20,
            colors: gradientColors,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              colors: gradientColors
                  .map((color) => color.withOpacity(0.2))
                  .toList(),
            ))
      ],
      lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.indigo.withOpacity(.2),
            /*getTooltipItems: (List<LineBarSpot> touchedBarSpots) {

            }*/
          ))));
  }
}