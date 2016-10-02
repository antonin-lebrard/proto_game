part of proto_game.io;



class GameLinkIo {

  LowLevelIo lowLevelIo;

  GameLinkIo(this.lowLevelIo);

  void write(String text){
    if (text == null || text == "") return;
    lowLevelIo.writeLine(text);
  }

  Future<Choice> presentChoices(List<Choice> choices) async {
    String choseChoice = await Game.game.lowLevelIo.presentChoices(choices.map((Choice c)=>c.name));
    for (Choice c in choices){
      if (choseChoice == c.name){
        return c;
      }
    }
    print("$choseChoice choice not present in list of choices");
    return null;
  }

}