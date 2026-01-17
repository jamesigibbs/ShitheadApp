import 'package:flutter/material.dart';
import 'dart:math';

// Card model - represents a single playing card
class PlayingCard {
  final String rank; // '2', '3', 'J', 'K', 'A', etc.
  final String suit; // '♠', '♥', '♦', '♣'

  PlayingCard(this.rank, this.suit);

  // Helper to get numeric value for comparison
  int get value {
    const values = {
      '2': 2,
      '3': 3,
      '4': 4,
      '5': 5,
      '6': 6,
      '7': 7,
      '8': 8,
      '9': 9,
      '10': 10,
      'J': 11,
      'Q': 12,
      'K': 13,
      'A': 14,
    };
    return values[rank]!;
  }
}

void main() {
  runApp(ShitheadApp());
}

class ShitheadApp extends StatelessWidget {
  const ShitheadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shithead',
      theme: ThemeData(primarySwatch: Colors.green),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<PlayingCard> hand;
  Set<int> selectedCards = {};
  List<PlayingCard> discardPile = [];
  String errorMessage = '';

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
    List<String> ranks = [
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K',
      'A',
    ];

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

  bool canPlayCard(PlayingCard card) {
    // If discard pile is empty, any card can be played
    if (discardPile.isEmpty) return true;

    // Get the top card of the discard pile
    PlayingCard topCard = discardPile.last;

    // Card must be equal or higher value
    return card.value >= topCard.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // Discard Pile
              Text(
                'Discard Pile: ${discardPile.length} cards',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),

              SizedBox(height: 10),

              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: discardPile.isEmpty ? Colors.grey : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: discardPile.isEmpty
                    ? Center(
                        child: Text(
                          'Empty',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : _buildCard(discardPile.last, -1),
              ),

              SizedBox(height: 30),
              // Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: hand
                    .asMap()
                    .entries
                    .map((entry) => _buildCard(entry.value, entry.key))
                    .toList(),
              ),

              SizedBox(height: 20),

              // Play button (only show if cards are selected)
              if (selectedCards.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Get the selected cards
                      List<PlayingCard> cardsToPlay = selectedCards
                          .map((index) => hand[index])
                          .toList();

                      // Check if all cards are valid
                      bool allValid = cardsToPlay.every(
                        (card) => canPlayCard(card),
                      );

                      if (!allValid) {
                        // Show error message
                        errorMessage =
                            'Cannot play! Card must be equal or higher.';
                        return; // Exit without playing
                      }

                      // Add them to discard pile
                      discardPile.addAll(cardsToPlay);

                      // Remove them from hand
                      hand = hand
                          .asMap()
                          .entries
                          .where((entry) => !selectedCards.contains(entry.key))
                          .map((entry) => entry.value)
                          .toList();

                      // Clear selection
                      selectedCards = {};
                      errorMessage = '';
                    });
                  },
                  child: Text('Play Selected Cards'),
                ),
            ],
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

        if (index == -1) return;

        setState(() {
          if (isSelected) {
            // Deselect this card
            selectedCards.remove(index);
          } else {
            // Selecting a new card
            if (selectedCards.isEmpty) {
              // First card - always allow
              selectedCards.add(index);
            } else {
              // Check if same rank as already selected cards
              PlayingCard firstSelectedCard = hand[selectedCards.first];
              if (card.rank == firstSelectedCard.rank) {
                // Same rank - allow selection
                selectedCards.add(index);
              }
              // Different rank - do nothing (can't select)
            }
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
