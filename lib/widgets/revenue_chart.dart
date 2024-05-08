import 'package:admin_dashboards/methods/common_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class RevenueChart extends StatefulWidget {
  const RevenueChart({super.key});

  @override
  State<RevenueChart> createState() => _TripsDataListState();
}



class _TripsDataListState extends State<RevenueChart>
{
  final completedTripsRecordsFromDatabase = FirebaseDatabase.instance.ref().child("tripRequests");
  CommonMethods cMethods = CommonMethods();

  // final List<double> data = [5, 10, 15, 20, 25, 30];
  // final List<String> titles = ["one", "two", "three", "four", "phat", "hello"];

  @override
  Widget build(BuildContext context)
  {
    return StreamBuilder(
      stream: completedTripsRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData)
      {
        if(snapshotData.hasError)
        {
          return const Center(
            child: Text(
              "Error Occurred. Try Later.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.blue,
              ),
            ),
          );
        }

        if(snapshotData.connectionState == ConnectionState.waiting)
        {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        Map<String, double> dailyIncome = {};
        Map<String, double> dailyTrips = {};

        Map dataMap = snapshotData.data!.snapshot.value as Map;
        List itemsList = [];
        dataMap.forEach((key, value)
        {
          if (value["status"] == "ended") {
            DateTime date = DateTime.parse(value["publishDateTime"]);
            int day = date.day;
            int month = date.month;
            int year = date.year;

            if (dailyIncome.containsKey('$day/${month.toString().padLeft(2, '0')}/$year')) {
              double fairAmount = double.parse(value["fareAmount"]);
              dailyIncome['$day/${month.toString().padLeft(2, '0')}/$year'] = (dailyIncome['$day/${month.toString().padLeft(2, '0')}/$year']! + fairAmount);
              dailyTrips ['$day/${month.toString().padLeft(2, '0')}/$year'] = dailyTrips ['$day/${month.toString().padLeft(2, '0')}/$year']! + 1;
            }
            else {
              double fairAmount = double.parse(value["fareAmount"]);
              dailyIncome['$day/${month.toString().padLeft(2, '0')}/$year'] = fairAmount;
              dailyTrips ['$day/${month.toString().padLeft(2, '0')}/$year'] = 1;
            }
            itemsList.add({"key": key, ...value});
          }
        });
        print(dailyIncome);
        List<String> dateList = dailyIncome.keys.toList();
        List<double> tripList = dailyTrips.values.toList();
        List<double> valueList = dailyIncome.values.toList();

        return
          Column(
            children: [
              Center(
                child: Container(
                  width: 1000,
                  height: 500,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: tripList.reduce((currentMax, next) => currentMax > next ? currentMax : next) + 5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: tripList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final value = entry.value;
                            return FlSpot(index.toDouble(), value);
                          }).toList(),
                          isCurved: false,
                          colors: [Colors.red],
                          barWidth: 4,
                          belowBarData: BarAreaData(show: false),
                          dotData: FlDotData(show: true),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(showTitles: true),
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTextStyles: (value) => const TextStyle(color: Colors.black, fontSize: 13),
                          margin: 10,
                          getTitles: (value) {
                            int index = value.toInt();
                            return dateList[index];
                          },
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 50),
                  child: Text(
                    'Number of trips per day (unit: \$)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Center(
                child: Container(
                  width: 1000,
                  height: 500,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(enabled: true),
                      maxY: valueList.reduce((currentMax, next) => currentMax > next ? currentMax : next) + 10,
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(
                            showTitles: true,
                            getTitles: (value) {
                              if (value % 2 == 0) {
                                return value.toInt().toString();
                              } else {
                                return '';
                              }
                            },
                        ),
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTextStyles: (value) => const TextStyle(color: Colors.black, fontSize: 13),
                          margin: 10,
                          getTitles: (double value) {
                            int index = value.toInt();
                            return dateList[index];
                          },
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      barGroups: valueList
                          .asMap()
                          .map(
                            (index, value) => MapEntry(
                          index,
                          BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                y: value,
                                colors: [Colors.blue],
                                width: 20,
                              ),
                            ],
                          ),
                        ),
                      )
                          .values
                          .toList(),
                    ),
                  ),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 50),
                  child: Text(
                    'Revenue by day (Unit: \$)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );

      },
    );
  }
}
