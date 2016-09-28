part of proto_game.io;



class GameLinkIo {

  LowLevelIo lowLevelIo;

  GameLinkIo(this.lowLevelIo);

  void write(String text){
    if (text == null || text == "") return;

  }

}