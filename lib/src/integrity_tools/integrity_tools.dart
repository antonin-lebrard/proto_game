
import 'dart:math';

class IdGenerator{

  static Set<num> _memory = new Set<num>();

  static Random _gen = new Random();

  static num generateId(){
    int rand = _gen.nextInt(2147483647);
    while(_memory.contains(rand)){
      rand = _gen.nextInt(2147483647);
    }
    _memory.add(rand);
    return rand;
  }

}