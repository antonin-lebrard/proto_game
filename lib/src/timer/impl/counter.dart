part of proto_game.timer;

class GameCounter implements GameTimer {

  int curCount = 0, toReach;
  bool started = false;

  Function f;

  GameCounter(this.toReach);

  void start(){
    started = true;
  }

  void onEnd(void func()){
    f = func;
  }

  void gameLoop(){
    if (started) {
      curCount++;
      if (curCount == toReach) {
        started = false;
        f();
      }
    }
  }

}