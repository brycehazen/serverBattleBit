# Simple Matchmaking System

A rudimentary matchmaking system implemented in C++ that pairs players based on their ranks.

## Features

- **Player Class**: A basic representation of a game player with unique ID and rank attributes.
- **Matchmaking Class**: A class responsible for matching players with similar ranks.

## Quickstart

### Prerequisites

- A C++ compiler (e.g., GCC, Clang).
- Basic understanding of C++ and object-oriented programming.

### Compilation

Compile the matchmaking system using your preferred C++ compiler:

\```bash
g++ matchmaking.cpp -o matchmaking
\```

### Execution

Run the compiled executable:

\```bash
./matchmaking
\```

## Implementation Details

- Players are added to a matchmaking pool.
- When searching for a match for a particular player, the system will look for another player within a specified rank tolerance.
- If no players within the rank tolerance are found, the system throws an exception.

## Potential Improvements

1. **Removing Matched Players**: After finding a suitable match, consider removing the paired players from the pool.
2. **Refined Matchmaking Logic**: Instead of finding the first player within a rank tolerance, implement logic to find the best match.
3. **Asynchronous Matchmaking**: Consider an implementation where players don't have to wait in a pool but are notified when a match is found.
4. **Scalability**: If the system needs to scale for a large number of players, consider using databases and optimized algorithms.

## Contributing

Feel free to fork the repository and submit pull requests for any enhancements or fixes. All contributions are welcome!

## License

This project is open source and available under the [MIT License](LICENSE).
