//
//  DataFlow.swift
//  29Pika
//
//  Created by Владимир Кацап on 23.12.2024.
//

import Foundation

class DataFlow {
    
    static func loadFavoriteIdArrFromFile() -> [Int]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("ids.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let athleteArr = try JSONDecoder().decode([Int].self, from: data)
            return athleteArr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }
    
    static func saveAthleteArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("ids.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    
    static func loadHistoryArrFromFile() -> [UserHistory]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("history.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let athleteArr = try JSONDecoder().decode([UserHistory].self, from: data)
            return athleteArr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }
    
    static func saveHistoryToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("history.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
}
