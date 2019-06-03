import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stm_kicker/userstats.dart';

class RankingsPage extends StatefulWidget {
  @override
  State createState() {
    return UserRankingState();
  }
}

class RankingWidget extends StatelessWidget {
  RankingWidget(this.player);

  final UserRanking player;

  @override
  Widget build(BuildContext context) {
    String winpercentage = (player.winPercentage == -1)
        ? "-"
        : player.winPercentage.toStringAsFixed(2);
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserStatsPage(player.name)),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Text(
                  player.name,
                  maxLines: 1,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Games played: ${player.gamesPlayed}",
                    ),
                    Text(
                      "Win percentage: $winpercentage",
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class UserRankingState extends State<RankingsPage> {
  bool loading = true;
  List<UserRanking> userRankings;

  @override
  Widget build(BuildContext context) {
    Firestore.instance.collection('users').snapshots().listen((data) {
      userRankings =
          data.documents.map((snapshot) => mapToUserRanking(snapshot)).toList();
      userRankings.sort((a, b) => compare(a, b));

      setState(() {
        loading = false;
      });
    });
    if (loading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
          itemCount: userRankings.length,
          itemBuilder: (context, index) {
            return RankingWidget(userRankings[index]);
          });
    }
  }

  UserRanking mapToUserRanking(DocumentSnapshot snapshot) {
    String name = snapshot.documentID;
    int wins = snapshot.data['wins'];
    int loses = snapshot.data['loses'];
    wins = wins == null ? 0 : wins;
    loses = loses == null ? 0 : loses;
    int gamesPlayed = wins + loses;
    if (gamesPlayed == 0) {
      return UserRanking(name, -1, gamesPlayed.toString());
    } else if (wins == 0) {
      return UserRanking(name, 0, gamesPlayed.toString());
    } else {
      double winPercentage = (wins / gamesPlayed) * 100;
      return UserRanking(name, winPercentage, gamesPlayed.toString());
    }
  }

  int compare(UserRanking a, UserRanking b) {
    if (a.winPercentage == b.winPercentage) {
      return 0;
    } else if (a.winPercentage > b.winPercentage) {
      return -1;
    } else {
      return 1;
    }
  }
}

class UserRanking {
  UserRanking(this.name, this.winPercentage, this.gamesPlayed);

  final String name;
  final double winPercentage;
  final String gamesPlayed;
}
