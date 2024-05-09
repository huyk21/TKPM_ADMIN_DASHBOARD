import 'package:admin_dashboards/methods/common_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class RevenueChart extends StatefulWidget {
  const RevenueChart({super.key});

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}



class _RevenueChartState extends State<RevenueChart>
{
  final completedTripsRecordsFromDatabase = FirebaseDatabase.instance.ref().child("tripRequests");
  CommonMethods cMethods = CommonMethods();

  List<String> comboboxSource = ['Day', 'Month', 'Year'];
  String _selectedLineCombobox = 'Day';
  String _selectedBarCombobox = 'Day';

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
        Map<String, double> monthlyIncome = {};
        Map<String, double> yearlyIncome = {};

        Map<String, double> dailyTrips = {};
        Map<String, double> monthlyTrips = {};
        Map<String, double> yearlyTrips = {};


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


            //Monthly
            if (monthlyIncome.containsKey('${month.toString().padLeft(2, '0')}/$year')) {
              double fairAmount = double.parse(value["fareAmount"]);
              monthlyIncome['${month.toString().padLeft(2, '0')}/$year'] = (monthlyIncome['${month.toString().padLeft(2, '0')}/$year']! + fairAmount);
              monthlyTrips ['${month.toString().padLeft(2, '0')}/$year'] = monthlyTrips ['${month.toString().padLeft(2, '0')}/$year']! + 1;
            }
            else {
              double fairAmount = double.parse(value["fareAmount"]);
              monthlyIncome['${month.toString().padLeft(2, '0')}/$year'] = fairAmount;
              monthlyTrips ['${month.toString().padLeft(2, '0')}/$year'] = 1;
            }


            //Yearly
            if (yearlyIncome.containsKey('$year')) {
              double fairAmount = double.parse(value["fareAmount"]);
              yearlyIncome['$year'] = (yearlyIncome['$year']! + fairAmount);
              yearlyTrips ['$year'] = yearlyTrips ['$year']! + 1;
            }
            else {
              double fairAmount = double.parse(value["fareAmount"]);
              yearlyIncome['$year'] = fairAmount;
              yearlyTrips ['$year'] = 1;
            }

            itemsList.add({"key": key, ...value});
          }
        });
        print(dailyIncome);
        List<String> dateList = dailyIncome.keys.toList();
        List<String> monthList = monthlyIncome.keys.toList();
        List<String> yearList = yearlyIncome.keys.toList();

        List<double> dailyTripList = dailyTrips.values.toList();
        List<double> dailyValueList = dailyIncome.values.toList();

        List<double> monthlyTripList = monthlyTrips.values.toList();
        List<double> monthlyValueList = monthlyIncome.values.toList();

        List<double> yearlyTripList = yearlyTrips.values.toList();
        List<double> yearhlyValueList = yearlyIncome.values.toList();

        List<double> lineChartData = dailyTripList;
        List<double> barChartData = dailyValueList;
        List<String> lineChartTitle = dateList;
        List<String> barChartTitle = dateList;

        if (_selectedLineCombobox == 'Day') {
          lineChartData = dailyTripList;
          lineChartTitle = dateList;
        }
        else if (_selectedLineCombobox == 'Month') {
          lineChartData = monthlyTripList;
          lineChartTitle = monthList;
        }
        else if (_selectedLineCombobox == 'Year') {
          lineChartData = yearlyTripList;
          lineChartTitle = yearList;
        }

        if (_selectedBarCombobox == 'Day') {
          barChartData = dailyValueList;
          barChartTitle = dateList;
        }
        else if (_selectedBarCombobox == 'Month') {
          barChartData = monthlyValueList;
          barChartTitle = monthList;
        }
        else if (_selectedBarCombobox == 'Year') {
          barChartData = yearhlyValueList;
          barChartTitle = yearList;
        }

        return
          Column(
            children: [
              DropdownButton<String>(
                hint: Text('Select Item'),
                value: _selectedLineCombobox,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLineCombobox = newValue!;
                  });
                },
                items: comboboxSource.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
              ),

              Center(
                child: Container(
                  width: 1000,
                  height: 500,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: lineChartData.reduce((currentMax, next) => currentMax > next ? currentMax : next) + 5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: lineChartData.asMap().entries.map((entry) {
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
                            return lineChartTitle[index];
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
                    'Number of trips per $_selectedLineCombobox',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              DropdownButton<String>(
                hint: Text('Select Item'),
                value: _selectedBarCombobox,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBarCombobox = newValue!;
                  });
                },
                items: comboboxSource.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
              ),

              Center(
                child: Container(
                  width: 1000,
                  height: 500,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(enabled: true),
                      maxY: barChartData.reduce((currentMax, next) => currentMax > next ? currentMax : next) + 10,
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
                            return barChartTitle[index];
                          },
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      barGroups: barChartData
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
                    'Revenue by $_selectedBarCombobox (Unit: \$)',
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
