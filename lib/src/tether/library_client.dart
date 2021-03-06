library bridge.tether.client;

// Core libraries
import 'dart:html';
import 'dart:async';

// Client side of library
import 'library_shared.dart';
export 'library_shared.dart';

import 'package:bridge/transport.dart';

part 'client/client_socket_adapter.dart';
part 'client/client_tether_maker.dart';

Tether tether;

Future globalTether() async {
  tether = await ClientTetherMaker.makeTether();
}