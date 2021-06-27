import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import 'mqtt.dart';

class MyHoePage extends StatefulWidget {
  @override
  _MyHoePageState createState() => _MyHoePageState();
}

class _MyHoePageState extends State<MyHoePage> {
  List<User> chartData = [];
  @override
  Future loadSalesData() async {
    final String jsonString = await getJsonFromAssets();
    final dynamic jsonResponse = json.decode(jsonString);
    for (Map<String, dynamic> i in jsonResponse) {
      chartData.add(User.fromJson(i));
    }
  }

  void initState() {
    loadSalesData();
    super.initState();
  }

  Future<String> getJsonFromAssets() async {
    return await rootBundle.loadString('assets/user.json');
  }

  @override
  Widget build(BuildContext context) {
    Widget _areaChart() {
      SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(text: 'chart on mqtt data'),
          series: <ChartSeries<User, int>>[
            LineSeries<User, int>(
              dataSource: chartData,
              xValueMapper: (User mqtt, _) => mqtt.switchNumber,
              yValueMapper: (User mqtt, _) => mqtt.value,
            )
          ]);
      ;
      ;
    }
  }
}
