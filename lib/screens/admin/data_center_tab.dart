import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:green_share/core/app_theme.dart';
import 'package:green_share/main.dart';
import 'package:green_share/models/item_model.dart';
import 'package:green_share/services/database_service.dart';

class DataCenterTab extends StatefulWidget {
  const DataCenterTab({super.key});

  @override
  State<DataCenterTab> createState() => _DataCenterTabState();
}

class _DataCenterTabState extends State<DataCenterTab> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ItemModel>>(
      stream: _databaseService.getGlobalActivityStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];
        
        int totalDonates = items.where((i) => i.type == 'Donate').length;
        int totalRequests = items.where((i) => i.type == 'Request').length;
        int impactCount = items.where((i) => i.status == 'donated' || i.status == 'awarded' || i.status == 'completed').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: AppTheme.primaryColor.withOpacity(0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.eco, size: 48, color: AppTheme.primaryColor),
                      const SizedBox(height: 12),
                      Text(context.l10n.greenImpact, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        '$impactCount Items Shared Successfully!',
                        style: const TextStyle(fontSize: 16, color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Activity Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 250,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (totalDonates > totalRequests ? totalDonates : totalRequests).toDouble() + 5,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(value.toInt() == 0 ? context.l10n.totalDonations : context.l10n.totalRequests);
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(toY: totalDonates.toDouble(), color: Colors.green, width: 40, borderRadius: BorderRadius.circular(4)),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(toY: totalRequests.toDouble(), color: Colors.blue, width: 40, borderRadius: BorderRadius.circular(4)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

