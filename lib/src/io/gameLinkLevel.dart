part of proto_game.io;



class GameLinkIo {

  LowLevelIo lowLevelIo;

  GameLinkIo(this.lowLevelIo);

  // TODO:
  void write(Text text){
    if (text == null || text == "") return;
    lowLevelIo.writeLine(text.getWholeText());
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