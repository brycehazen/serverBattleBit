#include <iostream>
#include <set>
#include <algorithm>
#include <optional>
#include <chrono>

class Player {
public:
    // Constructor to initialize a player with their unique ID and rank.
    Player(int id, int rank) 
        : id(id), rank(rank), timestamp(std::chrono::system_clock::now()) {}
    
    // Get the player's unique ID.
    int getId() const { return id; }

    // Get the player's rank.
    int getRank() const { return rank; }

    // Get the timestamp when the player was added to the matchmaking pool.
    auto getTimestamp() const { return timestamp; }

    // Overload the '<' operator to enable sorting players by rank in the set.
    bool operator<(const Player& other) const {
        return rank < other.rank;
    }

private:
    int id;  // Player's unique ID.
    int rank;  // Player's rank.

    // The time point when the player was added to the matchmaking pool.
    std::chrono::system_clock::time_point timestamp;
};

class Matchmaking {
public:
    // Add a player to the matchmaking pool.
    void addPlayer(const Player& player) {
        pool.insert(player);
    }

    // Find the best match for a given player within a certain rank tolerance.
    // If no match is found within the initial tolerance, it incrementally increases 
    // until a match is found or a maximum tolerance is reached.
    std::optional<Player> findBestMatch(const Player& player, int initial_tolerance = 5, int max_tolerance = 50) {
        int rank = player.getRank();
        int tolerance = initial_tolerance;

        while (tolerance <= max_tolerance) {
            // Define the lower and upper bounds of the search range.
            auto lower = pool.lower_bound(Player(0, rank - tolerance));
            auto upper = pool.upper_bound(Player(0, rank + tolerance));

            Player* bestMatch = nullptr;
            auto oldestTimestamp = std::chrono::system_clock::now();

            // Iterate through the range to find the best match based on rank 
            // and time they've been in the pool (prioritizing older entries).
            for (auto it = lower; it != upper; ++it) {
                if (it->getId() != player.getId() && it->getTimestamp() < oldestTimestamp) {
                    bestMatch = const_cast<Player*>(&(*it));
                    oldestTimestamp = it->getTimestamp();
                }
            }

            // If a match is found, remove them from the pool and return.
            if (bestMatch) {
                pool.erase(*bestMatch);
                return *bestMatch;
            }

            // Increase tolerance for the next iteration.
            tolerance += 5;
        }

        // Return empty if no match is found within max tolerance.
        return {};
    }

private:
    // A set (sorted data structure) to maintain the pool of players waiting for a match.
    std::set<Player> pool;
};

int main() {
    Matchmaking matchmaking;

    // Create some sample players.
    Player player1(1, 1500);
    Player player2(2, 1505);
    Player player3(3, 1520);
    Player player4(4, 1600);

    // Add the sample players to the matchmaking pool.
    matchmaking.addPlayer(player1);
    matchmaking.addPlayer(player2);
    matchmaking.addPlayer(player3);
    matchmaking.addPlayer(player4);

    // Attempt to find a match for player1.
    auto match = matchmaking.findBestMatch(player1);
    if (match) {
        std::cout << "Player with ID: " << player1.getId() << " (Rank: " << player1.getRank() 
                  << ") matched with Player ID: " << match->getId() << " (Rank: " << match->getRank() << ")\n";
    } else {
        std::cout << "No suitable match found for Player ID: " << player1.getId() << "\n";
    }

    return 0;
}
