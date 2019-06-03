import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'data.dart';
import 'game.dart';
import 'loadingdialog.dart';

class CreateGamePage extends StatelessWidget {
  String player1;
  String player2;
  String player3;
  String player4;

  Game getGame() {
    Team team1 = Team(player1, player2);
    Team team2 = Team(player3, player4);
    return Game(team1, team2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Game"),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_forward),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GamePage(getGame())),
            );
          }),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
      Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          AddPlayerWidget("Defense", (name) {
            player1 = name;
          }, Colors.red),
          AddPlayerWidget("Offense", (name) {
            player2 = name;
          }, Colors.red),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Vs",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),)
        ],
      )
      Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        AddPlayerWidget("Defense", (name) {
          player3 = name;
        }, Colors.blue),
        AddPlayerWidget("Offense", (name) {
          player4 = name;
        }, Colors.blue),
      ],
    )],
    )
    );
  }
}

class AddPlayerWidget extends StatefulWidget {
  AddPlayerWidget(this.position, this.userSelectedCallback, this.color);

  final String position;
  final Function userSelectedCallback;
  final Color color;

  @override
  State<StatefulWidget> createState() {
    return AddPlayerState(position, userSelectedCallback, color);
  }
}

class AddPlayerState extends State<AddPlayerWidget> {
  AddPlayerState(this.position, this.userSelectedCallback, this.color);

  final Color color;
  final String position;
  final Function userSelectedCallback;

  String player = "";

  void _updatePlayer(String player) {
    setState(() {
      this.player = player;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          player,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        Text(position),
        RaisedButton(
          color: color,
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return createUserWidget();
                });
          },
          child: Text("Add/Modify"),
        )
      ],
    );
  }

  Widget createUserWidget() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingDialog();
          } else {
            List<SimpleDialogOption> dialogOptions = snapshot.data.documents
                .map((snapshot) => snapshot.documentID)
                .map((name) => getSimpleDialogOption(name))
                .toList();
            return createSimpleDialog(dialogOptions);
          }
        });
  }

  SimpleDialog createSimpleDialog(List<SimpleDialogOption> dialogOptions) {
    SimpleDialog dialog = SimpleDialog(
      title: const Text('Choose a player'),
      children: dialogOptions,
    );
    return dialog;
  }

  SimpleDialogOption getSimpleDialogOption(String name) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.of(context).pop();
        userSelectedCallback(name);
        _updatePlayer(name);
      },
      child: Text(
        name,
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
