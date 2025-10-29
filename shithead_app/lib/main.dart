import 'package:flutter/material.dart';
import 'dart:math';

// Card model - represents a single playing card
class PlayingCard {
  final String rank;  // '2', '3', 'J', 'K', 'A', etc.
  final String suit;  // '♠', '♥', '♦', '♣'
  
  PlayingCard(this.rank, this.suit);
  
  // Helper to get numeric value for comparison
  int get value {
    const values = {
      '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7,
      '8': 8, '9': 9, '10': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14
    };
    return values[rank]!;
  }
}

void main() {
  runApp(ShitheadApp());
}

class ShitheadApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shithead',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<PlayingCard> hand;
  Set<int> selectedCards = {};
  
  @override
  void initState() {
    super.initState();
    List<PlayingCard> deck = createDeck();
    shuffleDeck(deck);
    hand = deck.take(3).toList();
  }
  
  List<PlayingCard> createDeck() {
    List<PlayingCard> deck = [];
    List<String> suits = ['♠', '♥', '♦', '♣'];
    List<String> ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    
    for (var suit in suits) {
      for (var rank in ranks) {
        deck.add(PlayingCard(rank, suit));
      }
    }
    
    return deck;
  }
  
  void shuffleDeck(List<PlayingCard> deck) {
    deck.shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      body: SafeArea(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: hand.map((card) => _buildCard(card)).toList(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCard(PlayingCard card, int index) {
  bool isRed = card.suit == '♥' || card.suit == '♦';
  bool isSelected = selectedCards.contains(index);
  
  return GestureDetector(
    onTap: () {
      setState(() {
        if (isSelected) {
          selectedCards.remove(index);
        } else {
          selectedCards.add(index);
        }
      });
    },
    child: Container(
      width: 80,
      height: 120,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.yellow : Colors.black,
          width: isSelected ? 4 : 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.rank,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isRed ? Colors.red : Colors.black,
            ),
          ),
          Text(
            card.suit,
            style: TextStyle(
              fontSize: 40,
              color: isRed ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}
} 