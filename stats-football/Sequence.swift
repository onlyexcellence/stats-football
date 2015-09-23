// ========================================================
// ========================================================
//  Sequence.swift
//  stats-football
//
//  Created by grobinson on 8/27/15.
//  Copyright (c) 2015 Wambl. All rights reserved.
//
import UIKit
import CoreData
import Alamofire
import SwiftyJSON
// ========================================================
// ========================================================
@objc(SequenceObject)
class SequenceObject: NSManagedObject {
    
    @NSManaged var id: String?
    @NSManaged var qtr: String
    @NSManaged var key: String
    @NSManaged var down: String?
    @NSManaged var fd: String?
    @NSManaged var startX: String
    @NSManaged var startY: String
    @NSManaged var replay: Bool
    @NSManaged var game: GameObject
    @NSManaged var team: TeamObject
    @NSManaged var plays: NSSet
    @NSManaged var penalties: NSSet
    @NSManaged var created_at: NSDate
    
}
// ========================================================
// ========================================================
class Sequence {
    
    var id: Int?
    var game: Game!
    var team: Team!
    var qtr: Int!
    var key: String!
    var down: Int?
    var fd: Int?
    var startX: Int!
    var startY: Int!
    var replay: Bool = false
    var plays: [Play] = []
    var penalties: [Penalty] = []
    var created_at: NSDate!
    var object: SequenceObject!
    
    init(){
        
        var entity = NSEntityDescription.entityForName("Sequences", inManagedObjectContext: context)
        var o = SequenceObject(entity: entity!, insertIntoManagedObjectContext: context)
        
        object = o
        startY = 50
        created_at = NSDate()
        
    }
    
    init(sequence: SequenceObject){
        
        if let i = sequence.id { id = i.toInt()! }
        created_at = sequence.created_at
        team = Team(team: sequence.team)
        game = Game(game: sequence.game)
        qtr = sequence.qtr.toInt()!
        key = sequence.key
        if let d = sequence.down { down = d.toInt()! }
        if let f = sequence.fd { fd = f.toInt()! }
        startX = sequence.startX.toInt()!
        startY = sequence.startY.toInt()!
        replay = sequence.replay
        object = sequence
        
    }
    
    typealias Completion = (error: NSError?) -> Void
    
    func delete(completion: Completion?){
        
        var c = completion
        
        var error: NSError?
        
        let p = object.plays.allObjects as! [PlayObject]
        for o in p { o.managedObjectContext?.deleteObject(o) }
        let pe = object.penalties.allObjects as! [PenaltyObject]
        for o in pe { o.managedObjectContext?.deleteObject(o) }
        
        object.managedObjectContext?.deleteObject(object)
        object.managedObjectContext?.save(&error)
        
        if let e = error {
            
            println("DELETE SEQUENCE ERROR!")
            println(e)
            
        } else {
            
            println("SEQUENCE DELETED!")
            
        }
        
        c?(error: error)
        
    }
    
    func save(completion: Completion?){
        
        var c = completion
        
        var error: NSError?
        
        if let i = id { object.id = i.string() }
        object.created_at = created_at
        object.game = game.object
        object.key = key
        object.team = team.object
        object.qtr = "\(qtr)"
        if let d = down { object.down = "\(d)" } else { object.down = nil }
        if let f = fd { object.fd = "\(f)" } else { object.fd = nil }
        object.startX = "\(startX)"
        object.startY = "\(startY)"
        object.replay = replay
        
        object.managedObjectContext?.save(&error)
        
        if let e = error {
            
            println("SEQUENCE SAVE ERROR!")
            println(e)
            
        } else {
            
            println(object)
            println("SEQUENCE SAVED!")
//            if game.id != nil && team.id != nil { saveRemote(nil) }
            
        }
        
        c?(error: error)
        
    }
    
    func saveRemote(completion: Completion?){
        println("SAVE REMOTE")
        var c = completion
        
        var s = "\(domain)"
        var method = Method.PUT
        var successCode = 200
        
        if let id = id {
            
            s += "/api/v1/sequences/\(id).json"
            method = Method.PUT
            successCode = 200
            
        } else {
            
            s += "/api/v1/sequences.json"
            method = Method.POST
            successCode = 201
            
        }
        
        var inner = [
                "game_id": game.object.id!.toInt()!,
                "team_id": team.object.id!.toInt()!,
                "qtr": qtr,
                "key": key,
                "start_x": startX,
                "start_y": startY,
                "replay": replay,
                "created_at": created_at
        ]
    
        if let d = down { inner["down"] = d }
        if let d = fd { inner["fd"] = d }
        
        let sequence = [
            "sequence": inner
        ]
        
        Alamofire.request(method, s, parameters: sequence,encoding: .JSON)
            .responseJSON { request, response, data, error in
                
                if error == nil {
                    
                    if response?.statusCode == successCode {
                        
                        var json = JSON(data!)
                        
                        if let id = self.id {
                            
                        } else {
                            
                            self.id = json["sequence"]["id"].intValue
                            self.object.id = self.id?.string()
                            self.object.managedObjectContext?.save(nil)
                            
                        }
                        
                    } else {
                        
                        println("Status Code Error: \(response?.statusCode)")
                        println(request)
                        
                    }
                    
                } else {
                    
                    println("Error!")
                    println(error)
                    println(request)
                    
                }
                
                c?(error: error)
                
        }
        
    }
    
    func getPlays(){
        
        var playObjects = object.plays.allObjects as! [PlayObject]
        
        plays = playObjects.map { o in
         
            let play = Play(play: o)
            
            return play
            
        }
        
        plays.sort({ $0.created_at.compare($1.created_at) == NSComparisonResult.OrderedAscending })
        
    }
    
    func getPenalties(){
        
        var penaltyObjects = object.penalties.allObjects as! [PenaltyObject]
        
        penalties = penaltyObjects.map { o in
            
            let penalty = Penalty(penalty: o)
            
            return penalty
            
        }
        
        penalties.sort({ $0.created_at.compare($1.created_at) == NSComparisonResult.OrderedAscending })
        
    }
    
}