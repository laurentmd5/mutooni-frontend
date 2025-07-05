import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Graphique de ventes : ligne sur 6 mois (exemple).
class SalesChart extends StatelessWidget {
  final List<double> data; // longueur 6 : Jan..Jun
  const SalesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, __) => Text(
                      ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin'][v.toInt()]),
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                spots: [
                  for (int i = 0; i < data.length; i++)
                    FlSpot(i.toDouble(), data[i]),
                ],
                barWidth: 3,
                belowBarData: BarAreaData(show: false),
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
