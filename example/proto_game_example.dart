// Copyright (c) 2015, Antonin Lebrard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library proto_game.example;

import 'dart:io';
import 'dart:async';

import 'package:proto_game/proto_game.dart';

main() {

  String json = new File('example/example.json').readAsStringSync();
  Game game = new GameDecoderJSON().readFromFormat(json);

  Room start = game.player.plateau.rooms.firstWhere((Room elem) => elem.name == "Start");
  Room test = game.player.plateau.rooms.firstWhere((Room elem) => elem.name == "Test");
  Room test2 = game.player.plateau.rooms.firstWhere((Room elem) => elem.name == "Test2");

  new EventsManager().emitEvent(new MoveEvent(start, test));
  new EventsManager().emitEvent(new MoveEvent(start, test));
  new EventsManager().emitEvent(new MoveEvent(start, test2));

  new EventsManager().emitEvent(new MoveEvent(test, start));
  new EventsManager().emitEvent(new MoveEvent(test, test2));

  // meaningless line just to put breakpoint
  var x = 0;

  while(true) {
    print("You are in the room: ${game.player.plateau.currentRoom.name}");
    String line = stdin.readLineSync();
    String command = line.substring(0, line.indexOf(' '));
    if (command == "move"){
      String arg = line.substring(line.indexOf(' ') + 1, line.length);
      if (arg == "n" || arg == "north")
        game.player.plateau.move(Direction.NORTH);
      if (arg == "s" || arg == "south")
        game.player.plateau.move(Direction.SOUTH);
    }
  }
}