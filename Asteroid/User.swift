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
    var playerSkins: [PlayerNode]
    var selectedPlayer: Int!
    
    init(username: String) {
        self.username = username
        coins = 0
        scores = []
        playerSkins = [PlayerNode(name: "laserShark", cost: 0, purchased: true), PlayerNode(name: "blackLaserShark", cost: 20, purchased: false)]
    }
    
    func userDefaultGets() {
        self.username = UserDefaults.standard.string(forKey: "username")
        self.coins = UserDefaults.standard.integer(forKey: "coins")
        if let data = UserDefaults.standard.value(forKey: "scores") as? Data {
            self.scores = try! PropertyListDecoder().decode([Score].self, from: data)
        } else {
            self.scores = []
        }
        if let data = UserDefaults.standard.value(forKey: "skins") as? Data {
            self.playerSkins = try! PropertyListDecoder().decode([PlayerNode].self, from: data)
        } else {
            
        }
    }
    
    func userDefaultSaves() {
        UserDefaults.standard.set(self.username, forKey: "username")
        UserDefaults.standard.set(self.coins, forKey: "coins")
        UserDefaults.standard.set(self.playerSkins, forKey: "skins")
    }
    //try? PropertyListEncoder().encode(self.playerSkins)
    func saveScore(_ value: Int) {
        highScoreCache.save(value)
        self.userDefaultGets()
    }
    
    func unlockPlayer(name: String) -> Bool{
        for i in 0..<self.playerSkins.count {
            if self.playerSkins[i].name == name && self.coins >= self.playerSkins[i].cost {
                self.coins -= self.playerSkins[i].cost
                self.playerSkins[i].purchased = true
                self.userDefaultSaves()
                return true
            }
        }
        return false
    }
    
    func clearUser() {
        UserDefaults.standard.set(self.username, forKey: "username")
        UserDefaults.standard.set(0, forKey: "coins")
        UserDefaults.standard.set(try? PropertyListEncoder().encode([PlayerNode(name: "laserShark", cost: 0, purchased: true), PlayerNode(name: "blackLaserShark", cost: 20, purchased: false)]), forKey: "skins")
        self.userDefaultGets()
    }
    
}

struct PlayerNode: Codable {
    
    var name: String!
    var cost: Int!
    var purchased: Bool!
    
    init(name: String, cost: Int, purchased: Bool) {
        self.name = name
        self.cost = cost
        self.purchased = purchased
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
