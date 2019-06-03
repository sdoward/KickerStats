import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stm_kicker/positiongoalswidget.dart';

import 'goalbreakdownwidget.dart';

class STMStatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("STM Stats"),
          bottom: TabBar(
            tabs: [
              Tab(
                text: "By Position",
              ),
              Tab(
                text: "By Position 2",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PositionalGoalsWidget(Firestore.instance
                .collection('stats')
                .document('stm')
                .snapshots()),
            GoalBreakDownWidget(
              Firestore.instance.collection('stats').document('stm'),
            ),
          ],
        ),
      ),
    );
  }
}
