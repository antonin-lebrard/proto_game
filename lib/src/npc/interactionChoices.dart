part of proto_game.npc;



class InteractionChoice {

  String id;

  List<Choice> choices = new List();

  InteractionChoice(this.id);

  Future execute() async {
    Choice c = await Game.game.gameLinkIo.presentChoices(choices);
    if (c != null) {
      Game.game.gameLinkIo.write(c.text);
      c.operations.forEach((StoredOperation o) => o.applyOperation());
    }
  }

}

class Choice {

  String name;

  String text;

  List<StoredOperation> operations = new List();

  Choice(this.name, this.text);

  Choice.cancel() {
    this.name = "Cancel";
  }

}
