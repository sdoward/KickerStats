import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GoalBreakDownWidget extends StatefulWidget {
  GoalBreakDownWidget(this.documentReference);

  final DocumentReference documentReference;

  @override
  State<StatefulWidget> createState() {
    return GoalBreakDownState(documentReference);
  }
}

class GoalBreakDownState extends State<GoalBreakDownWidget> {
  GoalBreakDownState(this.documentReference);

  final DocumentReference documentReference;
  bool loading = true;
  DocumentSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    documentReference.get().then((snapshot) {
      this.snapshot = snapshot;
      setState(() {
        loading = false;
      });
    });

    if (loading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                StatPoleWidget([
                  getSafeString('LF'),
                  getSafeString('CF'),
                  getSafeString('RF')
                ]),
                StatPoleWidget([
                  getSafeString('LW'),
                  getSafeString('LM'),
                  getSafeString('CM'),
                  getSafeString('RM'),
                  getSafeString('RW')
                ]),
                StatPoleWidget([getSafeString('LB'), getSafeString('RB')]),
                StatPoleWidget([getSafeString('GK')]),
              ]));
    }
  }

  String getSafeString(String key) {
    int data = snapshot.data[key];
    return data == null ? '0' : data.toString();
  }
}

class StatPoleWidget extends StatelessWidget {
  StatPoleWidget(this.stats);

  final List<String> stats;

  @override
  Widget build(BuildContext context) {
    List<StatPlayerWidget> players = new List<StatPlayerWidget>(stats.length);
    for (var i = 0; i < stats.length; i++) {
      players[i] = StatPlayerWidget(stats[i]);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: players,
    );
  }
}

class StatPlayerWidget extends StatelessWidget {
  StatPlayerWidget(this.stat);

  final String stat;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      shape: CircleBorder(),
      constraints: BoxConstraints.tight(Size(50, 50)),
      fillColor: Colors.blue,
      onPressed: () {},
      child: Text(
        stat,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}