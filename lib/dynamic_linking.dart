import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

class GameInfo {
  final String username;
  final int id;

  GameInfo({@required this.username, @required this.id});
}

// This global variable is set yet we enter a game room
GameInfo gameInfo;

main() {
  runApp(
    VRouter(
      routes: [
        VStacked(
          path: '/game',
          widget: GamePage(),
          subroutes: [
            VStacked(
              path: r':id(\d+)', // Matches any digit
              name: 'gameRoom',
              widget: GameRoomPage(),
              // Before we enter a gameRoom, we check that the gameInfo is set
              // if not we redirect to "/game"
              beforeEnter: (vRedirector) async => (gameInfo == null)
                  ? vRedirector.push('/game',
                      routerState: vRedirector.newVRouteData.pathParameters['id'])
                  : null,
            )
          ],
        ),
        // Redirect any miss-typed url to "/game"
        VRouteRedirector(path: ':_(.*)', redirectTo: '/game'),
      ],
    ),
  );
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // The username is whatever the user types in the TextFild
  String username;

  // The game id is gotten from the history state if any
  // This happens when the user goes back to the previous page
  int gameId;

  @override
  Widget build(BuildContext context) {
    return VNavigationGuard(
      // in afterEnter we try to get the gameId from the historyState
      afterEnter: (_, __, ___) => (VRouterData.of(context).historyState != null)
          ? setState(() => gameId = int.parse(VRouterData.of(context).historyState))
          : null,
      child: Material(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
              ),
              onChanged: (username) => this.username = username,
              onSubmitted: (_) =>
                  (gameId == null) ? createGameRoom() : joinGameRoom(id: gameId),
            ),
            TextButton(
              onPressed: () => (gameId == null) ? createGameRoom() : joinGameRoom(id: gameId),
              child: Text((gameId == null) ? 'Create game room' : 'Join game room $gameId'),
            ),
            if (gameId == null && gameInfo != null)
              TextButton(
                onPressed: () => joinGameRoom(id: gameInfo.id),
                child: Text('Go back game room ${gameInfo.id}'),
              ),
          ],
        ),
      ),
    );
  }

  // This is used when the user want to create a fresh new room
  void createGameRoom() {
    gameInfo = GameInfo(username: username, id: Random().nextInt(1000));
    VRouterData.of(context).pushNamed('gameRoom', pathParameters: {'id': '${gameInfo.id}'});
  }

  // This is used when the user want to join a game room which he has the game id
  void joinGameRoom({@required int id}) {
    gameInfo = GameInfo(username: username, id: id);
    VRouterData.of(context).pushNamed('gameRoom', pathParameters: {'id': '${gameInfo.id}'});
  }
}

class GameRoomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        child: Text('Welcome ${gameInfo.username}, you are in the room number ${gameInfo.id}'
            '\nCopy the url to invite other to join!'),
      ),
    );
  }
}
