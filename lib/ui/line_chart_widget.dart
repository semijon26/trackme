import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
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
              reservedSize: 40,
            )),
        axisTitleData: FlAxisTitleData(
            leftTitle: AxisTitle(
                showTitle: true,
                margin: 5,
                titleText: t.altitudeInMeters,
                textAlign: TextAlign.center,
                textStyle: const TextStyle(color: Colors.indigo)),
            topTitle: AxisTitle(
                showTitle: true,
                margin: 5,
                titleText: t.distanceInMeters,
                textAlign: TextAlign.center,
                textStyle: const TextStyle(color: Colors.indigo))),
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
                tooltipBgColor: Colors.white.withOpacity(.8),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    final textStyle = TextStyle(
                      color: touchedSpot.bar.colors[0],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    );
                    return LineTooltipItem(
                        '${t.distance}: ${touchedSpot.x.round()} m'
                        '\n${t.altitude}: ${touchedSpot.y.round()} m',
                        textStyle);
                  }).toList();
                }))));
  }
}
