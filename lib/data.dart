class Game {
  Game(this.teamOne, this.teamTwo);

  final Team teamOne;
  final Team teamTwo;
}

class Team {
  Team(this.defense, this.attack);

  final String defense;
  final String attack;
}

class Player {
  Player(this.name, this.winPercentage, this.gamesPlayed);

  final String name;
  final double winPercentage;
  final int gamesPlayed;
}
