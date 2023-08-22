#include <iostream>
#include <set>
#include <optional>
#include <chrono>
#include <thread>
#include <mutex>
#include <map>
#include <exception>
#include <string>
#include <sqlite3.h>
#include <boost/asio.hpp>
#include <boost/asio/spawn.hpp>

// 1. Error Handling
class MatchmakingException : public std::exception {
private:
    std::string message;
public:
    MatchmakingException(const std::string& msg) : message(msg) {}
    const char* what() const noexcept override { return message.c_str(); }
};

// 2. Database Management
class Database {
private:
    sqlite3* db;
    std::mutex dbMutex; // To make database operations thread-safe
public:
    Database(const std::string& filename) {
        if (sqlite3_open(filename.c_str(), &db)) {
            throw MatchmakingException("Failed to open database.");
        }

        char* errMsg = nullptr;
        std::string sql = "CREATE TABLE IF NOT EXISTS MatchmakingHistory(Player1Id INT, Player2Id INT);";
        
        if (sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsg)) {
            throw MatchmakingException("Failed to create table.");
        }
    }

    void insertMatch(int player1Id, int player2Id) {
        std::lock_guard<std::mutex> lock(dbMutex);
        
        char* errMsg = nullptr;
        std::string sql = "INSERT INTO MatchmakingHistory (Player1Id, Player2Id) VALUES (" 
                          + std::to_string(player1Id) + "," + std::to_string(player2Id) + ");";
        
        if (sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsg)) {
            throw MatchmakingException("Failed to insert match.");
        }
    }

    ~Database() {
        sqlite3_close(db);
    }
};

// 3. Player and Matchmaking
// ... (Include the Player and Matchmaking classes from previous examples, and make sure methods like addPlayer are thread-safe using mutexes.)

// 4. Networking
void handlePlayer(boost::asio::ip::tcp::socket socket, Matchmaking& matchmaking, boost::asio::yield_context yield) {
    try {
        boost::asio::streambuf buf;

        // Simple receive. Assume players send their ID and rank in a format "ID,RANK"
        boost::asio::async_read_until(socket, buf, '\n', yield);
        std::istream is(&buf);
        std::string data;
        std::getline(is, data);
        int commaPos = data.find(',');
        int id = std::stoi(data.substr(0, commaPos));
        int rank = std::stoi(data.substr(commaPos + 1));

        Player player(id, rank);
        matchmaking.addPlayer(player);

    }
    catch (const std::exception& e) {
        std::cerr << "Error handling player: " << e.what() << std::endl;
    }
}

void startAccept(boost::asio::ip::tcp::acceptor& acceptor, Matchmaking& matchmaking, boost::asio::yield_context yield) {
    while (true) {
        boost::system::error_code ec;
        boost::asio::ip::tcp::socket socket(acceptor.get_executor().context());
        acceptor.async_accept(socket, yield[ec]);

        if (!ec) {
            boost::asio::spawn(acceptor.get_executor(), [&socket, &matchmaking](boost::asio::yield_context yc) {
                handlePlayer(std::move(socket), matchmaking, yc);
            });
        } else {
            std::cerr << "Accept error: " << ec.message() << std::endl;
        }
    }
}

void server(Matchmaking& matchmaking) {
    boost::asio::io_context io_context(4);  // 4 threads in the thread pool
    boost::asio::ip::tcp::acceptor acceptor(io_context, boost::asio::ip::tcp::endpoint(boost::asio::ip::tcp::v4(), 12345));

    boost::asio::spawn(io_context, [&acceptor, &matchmaking](boost::asio::yield_context yield) {
        startAccept(acceptor, matchmaking, yield);
    });

    io_context.run();
}

int main() {
    Matchmaking matchmaking;
    Database db("matchmaking.db");

    // For simplicity, run the server in main thread
    server(matchmaking);

    return 0;
}
