//
//  User.swift
//  Asteroid
//
//  Created by Anthony W Fealy on 5/2/19.
//  Copyright © 2019 Anthony W Fealy. All rights reserved.
//

import Foundation

class User: Codable {
    
    var username: String!
    var coins: Int!
    var scores: [Score]
    var selectedPlayer: String!
    
    init(username: String) {
        self.username = username
        coins = 0
        scores = []
    }
    
    func userDefaultGets() {
        self.username = UserDefaults.standard.string(forKey: "username")
        self.coins = UserDefaults.standard.integer(forKey: "coins")
        if let data = UserDefaults.standard.value(forKey: "scores") as? Data {
            scores = try! PropertyListDecoder().decode([Score].self, from: data)
        } else {
            scores = []
        }
    }
    
    func userDefaultSaves() {
        UserDefaults.standard.set(self.username, forKey: "username")
        UserDefaults.standard.set(self.coins, forKey: "coins")
    }
    
    func saveScore(_ value: Int) {
        highScoreCache.save(value)
    }
    
    func databaseCalls() {
        
    }
}

struct Score: Codable {
    
    let score: Int
    let date: String
    
    init(score: Int, date: String) {
        self.score = score
        self.date = date
    }
    
}

struct highScoreCache {
    static let key = "scores"
    static let numOfScores = 5
    
    static func save(_ value: Int) {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: now)
        let newScore = Score(score: value, date: dateString)
        
        if var cachedScores = get() {
            cachedScores.sort { $0.score > $1.score }
            
            if cachedScores.count >= numOfScores && cachedScores.last!.score < newScore.score {
                _ = cachedScores.popLast()
                cachedScores.append(newScore)
                cachedScores.sort { $0.score > $1.score }
            } else if cachedScores.count < numOfScores {
                cachedScores.append(newScore)
                cachedScores.sort { $0.score > $1.score }
            }
            UserDefaults.standard.set(try? PropertyListEncoder().encode(cachedScores), forKey: key)
        } else {
            UserDefaults.standard.set(try? PropertyListEncoder().encode([newScore]), forKey: key)
        }
    }
    
    static func get() -> [Score]! {
        var scoreData: [Score]?
        if let data = UserDefaults.standard.value(forKey: key) as? Data {
            scoreData = try! PropertyListDecoder().decode([Score].self, from: data)
            return scoreData
        } else {
            return scoreData
        }
    }
    
    static func remove() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
