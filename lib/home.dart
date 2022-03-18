import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'game_logic.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String activePlayer = 'X';
  bool gameOver = false;
  int turn = 0;
  String result = "";
  Game game = Game();
  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: MediaQuery.of(context).orientation == Orientation.portrait
            ? Column(
                children: [
                  ..._switchSection(),
                  _expanded(context),
                  ..._resultSection(context),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ..._switchSection(),
                        const SizedBox(height: 20,),
                        ..._resultSection(context),
                      ],
                    ),
                  ),
                  _expanded(context),
                ],
              ),
      ),
    );
  }

  List<Widget> _switchSection() {
    return [
      SwitchListTile.adaptive(
          title: const Text(
            'Turn on/off two player',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          value: isSwitched,
          onChanged: (newValue) {
            setState(() {
              isSwitched = newValue;
            });
          }),
      Text(
        ('It\'s $activePlayer turn').toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 52,
        ),
      )
    ];
  }

  List<Widget> _resultSection(context) {
    return [
      Text(
        result,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            wordSpacing: 2,
            fontWeight: FontWeight.w800),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              activePlayer = 'X';
              gameOver = false;
              turn = 0;
              Player.playerX = [];
              Player.playerO = [];
              result = "";
            });
          },
          icon: const Icon(Icons.repeat),
          label: const Text('Repeat the game'),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).splashColor)),
        ),
      )
    ];
  }

  _expanded(context) {
    return Expanded(
      child: GridView.count(
        padding: const EdgeInsets.all(15),
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 1.0,
        crossAxisCount: 3,
        children: List.generate(
            9,
            (index) => InkWell(
                  onTap: gameOver ? null : () => _onTap(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(16)),
                    child: Center(
                      child: Text(
                        Player.playerX.contains(index)
                            ? 'X'
                            : Player.playerO.contains(index)
                                ? 'O'
                                : '',
                        style: TextStyle(
                            color: Player.playerX.contains(index)
                                ? Colors.blue
                                : Colors.pink,
                            fontSize: 52),
                      ),
                    ),
                  ),
                )),
      ),
    );
  }

  _onTap(int index) async {
    if (Player.playerX.isEmpty ||
        Player.playerO.isEmpty ||
        (!Player.playerX.contains(index) && !Player.playerO.contains(index))) {
      game.playGame(index, activePlayer);
      updateState();

      if (!isSwitched && !gameOver && turn != 9) {
        await game.autoPlay(activePlayer);
        updateState();
      }
    }
  }

  void updateState() {
    setState(() {
      turn++;
      activePlayer = (activePlayer == 'X') ? 'O' : 'X';
      String winnerPlayer = game.checkWinner();
      if (winnerPlayer != '') {
        gameOver = true;
        result = '$winnerPlayer is the winner';
      } else if (!gameOver && turn == 9) {
        result = 'It\'s Draw!';
      }
    });
  }
}
