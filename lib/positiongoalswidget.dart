import 'package:charts_common/common.dart' as commonCharts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:meta/meta.dart' as chartColor;

class PositionalGoalsWidget extends StatelessWidget {
  PositionalGoalsWidget(this.snapshots);

  final Stream<DocumentSnapshot> snapshots;

  static List<PositionSegment> positionSegments = List();

  List<commonCharts.Series<PositionSegment, String>> seriesList = [
    commonCharts.Series(
        id: 'Segments',
        domainFn: (PositionSegment positionSegment, _) =>
            positionSegment.position,
        measureFn: (PositionSegment positionSegment, _) =>
            positionSegment.value,
        labelAccessorFn: (PositionSegment positionSegment, _) =>
            positionSegment.position,
        data: positionSegments)
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: snapshots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            positionSegments.clear();
            addSegment("GK", snapshot.data);
            addSegment('RB', snapshot.data);
            addSegment('LB', snapshot.data);
            addSegment('RW', snapshot.data);
            addSegment('RM', snapshot.data);
            addSegment('RC', snapshot.data);
            addSegment('LM', snapshot.data);
            addSegment('LW', snapshot.data);
            addSegment('RF', snapshot.data);
            addSegment('CF', snapshot.data);
            addSegment('LF', snapshot.data);
            return Padding(
              padding: EdgeInsets.all(60.0),
              child: charts.PieChart(
                seriesList,
                animate: false,
                defaultRenderer: charts.ArcRendererConfig(
                    arcWidth: 40,
                    arcRendererDecorators: [
                      charts.ArcLabelDecorator(
                          labelPosition: charts.ArcLabelPosition.outside)
                    ]),
              ),
            );
          }
        });
  }

  void addSegment(String key, DocumentSnapshot snapshot) {
    int data = snapshot.data[key];
    if (data != null) {
      positionSegments.add(PositionSegment(key, data));
    }
  }

  int getGoalCount(DocumentSnapshot snapshot) {
    Map<String, dynamic> map = snapshot.data;
    return getOrDefault(map, 'GK') +
        getOrDefault(map, 'RB') +
        getOrDefault(map, 'LB') +
        getOrDefault(map, 'RW') +
        getOrDefault(map, 'RM') +
        getOrDefault(map, 'RC') +
        getOrDefault(map, 'LM') +
        getOrDefault(map, 'LW') +
        getOrDefault(map, 'RF') +
        getOrDefault(map, 'CF') +
        getOrDefault(map, 'LF');
  }

  int getOrDefault(Map<String, dynamic> map, String key) {
    debugPrint(map.toString());
    return map.containsKey(key) ? map[key] : 0;
  }
}

class StatWidget extends StatelessWidget {
  StatWidget(this.title, this.stat);

  final String title;
  final String stat;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              stat,
              style: TextStyle(fontSize: 22),
            ),
          ],
        ));
  }
}

class PositionSegment {
  PositionSegment(this.position, this.value);

  final String position;
  final int value;
}
