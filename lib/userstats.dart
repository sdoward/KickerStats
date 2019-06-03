import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stm_kicker/positiongoalswidget.dart';

import 'goalbreakdownwidget.dart';

class UserStatsPage extends StatelessWidget {
  UserStatsPage(this.user);

  final String user;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("$user stats"),
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
                .collection('users')
                .document(user)
                .snapshots()),
            GoalBreakDownWidget(
              Firestore.instance.collection('users').document(user),
            ),
          ],
        ),
      ),
    );
  }
}
