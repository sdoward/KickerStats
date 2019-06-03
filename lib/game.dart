import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'data.dart';

class GamePage extends StatelessWidget {
  GamePage(this.game);

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game),
    );
  }
}

class GameWidget extends StatefulWidget {
  GameWidget(this.game);

  final Game game;

  @override
  State<StatefulWidget> createState() {
    return _GameBoardState(game);
  }
}

class _GameBoardState extends State<GameWidget> {
  _GameBoardState(this.game);

  final Firestore firestore = Firestore.instance;
  final Queue<Goal> goals = Queue();
  final Game game;

  void _registerGoal(Goal goal) {
    setState(() {
      goals.add(goal);
      int teamOneGoals = getTeamOneGoals();
      int teamTwoGoals = getTeamTwoGoals();
      if ((teamOneGoals > 6 || teamTwoGoals > 6) &&
          (teamOneGoals - teamTwoGoals).abs() > 1) {
        showDialog(
            barrierDismissible: false,
            context: context,
            child: GameFinishedDialog(() {
              finishGame();
            }, () {
              replayGame();
            }));
      }
    });
  }

  void undoGoal() {
    setState(() {
      goals.removeLast();
    });
  }

  void replayGame() {
    saveGame();
    Navigator.pop(context);
    setState(() {
      goals.clear();
    });
  }

  void finishGame() {
    saveGame();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void saveGame() {
    Map<String, int> goalCount = Map<String, int>();
    goals.toList().forEach((goal) {
      String position = getStringValue(goal.position);
      int count = goalCount.containsKey(position) ? goalCount[position] : 0;
      goalCount[position] = count + 1;
    });
    Map<String, dynamic> statsData = Map<String, dynamic>();
    goalCount.forEach((key, value) {
      statsData[key] = FieldValue.increment(value);
    });
    statsData['games'] = FieldValue.increment(1);
    firestore.collection("stats").document('stm').updateData(statsData);
    setTeamOneData(game.teamOne.defense);
    setTeamOneData(game.teamOne.attack);
    setTeamTwoData(game.teamTwo.defense);
    setTeamTwoData(game.teamTwo.attack);
  }

  void setTeamOneData(String user) {
    Map<String, dynamic> data = getGoalCountForUser(user);
    String gameIncrement = didTeamOneWin() ? "wins" : "loses";
    data[gameIncrement] = FieldValue.increment(1);
    firestore.collection('users').document(user).updateData(data);
  }

  void setTeamTwoData(String user) {
    Map<String, dynamic> data = getGoalCountForUser(user);
    String gameIncrement = didTeamOneWin() ? "loses" : "wins";
    data[gameIncrement] = FieldValue.increment(1);
    firestore.collection('users').document(user).updateData(data);
  }

  Map<String, dynamic> getGoalCountForUser(String user) {
    Map<String, int> goalCount = Map<String, int>();
    goals.toList().where((goal) => goal.user == user).forEach((goal) {
      String position = getStringValue(goal.position);
      int count = goalCount.containsKey(position) ? goalCount[position] : 0;
      goalCount[position] = count + 1;
    });
    Map<String, dynamic> statsData = Map<String, dynamic>();
    goalCount.forEach((key, value) {
      statsData[key] = FieldValue.increment(value);
    });
    return statsData;
  }

  Map<String, dynamic> getGoalCount() {
    Map<String, int> goalCount = Map<String, int>();
    goals.toList().forEach((goal) {
      String position = getStringValue(goal.position);
      int count = goalCount.containsKey(position) ? goalCount[position] : 0;
      goalCount[position] = count + 1;
    });
    Map<String, dynamic> statsData = Map<String, dynamic>();
    goalCount.forEach((key, value) {
      statsData[key] = FieldValue.increment(value);
    });
    return statsData;
  }

  bool didTeamOneWin() {
    return getTeamOneGoals() > getTeamTwoGoals();
  }

  int getTeamOneGoals() {
    return goals.where((goal) => goal.team == TeamEnum.ONE).length;
  }

  int getTeamTwoGoals() {
    return goals.where((goal) => goal.team == TeamEnum.TWO).length;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ScoreBoard(goals.toList()),
        Pole(_registerGoal,
            [Goal(game.teamOne.defense, Position.GK, TeamEnum.ONE)]),
        Pole(_registerGoal, [
          Goal(game.teamOne.defense, Position.RB, TeamEnum.ONE),
          Goal(game.teamOne.defense, Position.LB, TeamEnum.ONE)
        ]),
        Pole(_registerGoal, [
          Goal(game.teamTwo.attack, Position.LF, TeamEnum.TWO),
          Goal(game.teamTwo.attack, Position.CF, TeamEnum.TWO),
          Goal(game.teamTwo.attack, Position.RF, TeamEnum.TWO)
        ]),
        Pole(_registerGoal, [
          Goal(game.teamOne.attack, Position.RW, TeamEnum.ONE),
          Goal(game.teamOne.attack, Position.RM, TeamEnum.ONE),
          Goal(game.teamOne.attack, Position.CM, TeamEnum.ONE),
          Goal(game.teamOne.attack, Position.LM, TeamEnum.ONE),
          Goal(game.teamOne.attack, Position.LW, TeamEnum.ONE)
        ]),
        Pole(_registerGoal, [
          Goal(game.teamTwo.attack, Position.LW, TeamEnum.TWO),
          Goal(game.teamTwo.attack, Position.LM, TeamEnum.TWO),
          Goal(game.teamTwo.attack, Position.CM, TeamEnum.TWO),
          Goal(game.teamTwo.attack, Position.RM, TeamEnum.TWO),
          Goal(game.teamTwo.attack, Position.RW, TeamEnum.TWO)
        ]),
        Pole(_registerGoal, [
          Goal(game.teamOne.attack, Position.RF, TeamEnum.ONE),
          Goal(game.teamOne.attack, Position.CF, TeamEnum.ONE),
          Goal(game.teamOne.attack, Position.LF, TeamEnum.ONE)
        ]),
        Pole(_registerGoal, [
          Goal(game.teamTwo.defense, Position.LB, TeamEnum.TWO),
          Goal(game.teamTwo.defense, Position.RB, TeamEnum.TWO)
        ]),
        Pole(_registerGoal,
            [Goal(game.teamTwo.defense, Position.GK, TeamEnum.TWO)]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            RaisedButton(
                onPressed: () {
                  undoGoal();
                },
                child: Text("Undo"))
          ],
        )
      ],
    ));
  }
}

class ScoreBoard extends StatelessWidget {
  ScoreBoard(this.goals);

  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          goals.where((goal) => goal.team == TeamEnum.ONE).length.toString(),
          style: TextStyle(
              fontSize: 40, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        Text(
          goals.where((goal) => goal.team == TeamEnum.TWO).length.toString(),
          style: TextStyle(
              fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
        )
      ],
    );
  }
}

class Pole extends StatelessWidget {
  Pole(this.onTap, this.goals);

  final List<Goal> goals;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    List<PlayerWidget> players = new List<PlayerWidget>(goals.length);
    for (var i = 0; i < goals.length; i++) {
      Color color = (goals[i].team == TeamEnum.ONE) ? Colors.red : Colors.blue;
      players[i] = PlayerWidget(color, onTap, goals[i]);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: players,
    );
  }
}

class PlayerWidget extends StatelessWidget {
  PlayerWidget(this.color, this.onTap, this.goal);

  final Function onTap;
  final Color color;
  final Goal goal;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      shape: CircleBorder(),
      constraints: BoxConstraints.tight(Size(40, 40)),
      fillColor: color,
      onPressed: () => onTap(goal),
      child: Text(
        getStringValue(goal.position),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class GameFinishedDialog extends StatelessWidget {
  GameFinishedDialog(this.finishCallback, this.replayCallback);

  final Function finishCallback;
  final Function replayCallback;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Padding(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            onPressed: replayCallback,
            child: Text("Replay"),
          ),
          RaisedButton(
            onPressed: finishCallback,
            child: Text("Finish"),
          )
        ],
      ),
    ));
  }
}

enum Position { GK, RB, LB, RW, RM, CM, LM, LW, RF, CF, LF }

enum TeamEnum { ONE, TWO }

class Goal {
  Goal(this.user, this.position, this.team);

  final String user;
  final Position position;
  final TeamEnum team;
}

String getStringValue(Position position) {
  return Position.values[position.index].toString().replaceRange(0, 9, "");
}
