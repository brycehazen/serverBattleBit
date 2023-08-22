#include <iostream>
#include <vector>
#include <algorithm>

class Player {
public:
    Player(int id, int rank) : id(id), rank(rank) {}
    
    int getId() const { return id; }
    int getRank() const { return rank; }
    
private:
    int id;    // Player's unique ID
    int rank;  // Player's rank
};

class Matchmaking {
public:
    // Add a player to the matchmaking pool
    void addPlayer(const Player& player) {
        pool.push_back(player);
    }

    // Find a match for a given player. This function will try to find a player
    // of a similar rank within a given tolerance. If no players are found within
    // that tolerance, it expands the search.
    Player findMatch(const Player& player, int tolerance = 5) {
        int rank = player.getRank();

        for (int i = 0; i < tolerance; ++i) {
            for (const Player& candidate : pool) {
                if (candidate.getId() != player.getId() && 
                    abs(candidate.getRank() - rank) <= i) {
                    return candidate;  // Found a match!
                }
            }
        }

        throw std::runtime_error("No suitable match found.");
    }

private:
    std::vector<Player> pool;  // Pool of players waiting for a match
};

int main() {
    Matchmaking matchmaking;

    // Sample players
    Player player1(1, 1500);
    Player player2(2, 1505);
    Player player3(3, 1520);
    Player player4(4, 1600);

    matchmaking.addPlayer(player2);
    matchmaking.addPlayer(player3);
    matchmaking.addPlayer(player4);

    try {
        Player match = matchmaking.findMatch(player1);
        std::cout << "Player with ID: " << player1.getId() << " (Rank: " << player1.getRank() 
                  << ") matched with Player ID: " << match.getId() << " (Rank: " << match.getRank() << ")\n";
    } catch (const std::exception& e) {
        std::cout << e.what() << "\n";
    }

    return 0;
}
