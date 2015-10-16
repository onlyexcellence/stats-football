//
//  PlayKeySelector.swift
//  stats-football
//
//  Created by grobinson on 9/7/15.
//  Copyright (c) 2015 Wambl. All rights reserved.
//

import UIKit

class KeySelector: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPopoverControllerDelegate {

    var tracker: Tracker!
    var newPlay: Play?
    var newPenalty: Penalty?
    private var keys: [Key] = []
    var type: String!
    
    var nsel: NumberSelector!
    var ksel: KeySelector!
    
    var s: Sequence!
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        s = tracker.game.sequences[tracker.index]
        
        keys = Filters.keys(s,type: type)
        
        nsel = NumberSelector(nibName: "NumberSelector", bundle: nil)
        nsel.tracker = tracker
        
        ksel = KeySelector(nibName: "KeySelector", bundle: nil)
        ksel.tracker = tracker
        
        table.delegate = self
        table.dataSource = self
        
        edgesForExtendedLayout = UIRectEdge()
        
        if type == "play_key_select" {
            
            if let play = newPlay {
                
                title = "#\(play.player_a)"
                
            }
            
            if let penalty = newPenalty {
                
                title = "#\(penalty.player)"
                
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return keys.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell") as UITableViewCell
        
        let key = keys[indexPath.row]
        
        if key == .Home {
            cell.textLabel?.text = "Recovered by \(tracker.game.home.short)"
        } else if key == .Away {
            cell.textLabel?.text = "Recovered by \(tracker.game.away.short)"
        } else {
            cell.textLabel?.text = key.displayKey
        }
        
        cell.textLabel?.textAlignment = .Center
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let key = keys[indexPath.row]
        
        // =========================================================
        // =========================================================
        if let play = newPlay {
            
            switch type {
            case "play_key_select":
            // ++++++++++++++++++++++++++++++++++++++++++++++++
                
                play.key = key
                
                switch key {
                case .Pass,.Interception,.Incomplete:
                    
                    nsel.type = "player_b"
                    nsel.newPlay = play
                    
                    navigationController?.pushViewController(nsel, animated: false)
                    
                case .FumbledSnap,.BadSnap,.Fumble:
                    
                    ksel.type = "fumble"
                    ksel.newPlay = play
                    
                    navigationController?.pushViewController(ksel, animated: false)
                    
                default:
                    
                    tracker.newPlay = play
                    
                    tracker.spot()
                    
                    close()
                    
                }
                
            // ++++++++++++++++++++++++++++++++++++++++++++++++
            case "fumble":
            // ++++++++++++++++++++++++++++++++++++++++++++++++
                
                switch key {
                case .Home:
                    
                    play.team = tracker.game.home
                    
                    nsel.type = "player_b"
                    nsel.newPlay = play
                    
                    navigationController?.pushViewController(nsel, animated: false)
                    
                case .Away:
                    
                    play.team = tracker.game.away
                    
                    nsel.type = "player_b"
                    nsel.newPlay = play
                    
                    navigationController?.pushViewController(nsel, animated: false)
                    
                default:
                    
                    tracker.newPlay = play
                    
                    tracker.spot()
                    
                    close()
                    
                }
                
            // ++++++++++++++++++++++++++++++++++++++++++++++++
            default:
                
                ()
                
            }
            
        }
        // =========================================================
        // =========================================================
        
        if let penalty = newPenalty {
            
            switch type {
                
            // ++++++++++++++++++++++++++++++++++++++++++++++++
            case "penalty_distance":
            // ++++++++++++++++++++++++++++++++++++++++++++++++
                
                penalty.distance = key.int
                nsel.newPenalty = penalty
                nsel.type = "penalty_player"
                
                navigationController?.pushViewController(nsel, animated: false)
                
            // ++++++++++++++++++++++++++++++++++++++++++++++++
            case "penalty_options":
            // ++++++++++++++++++++++++++++++++++++++++++++++++
                
                switch key {
                case .OnKick:
                    
                    penalty.enforcement = key
                    
                    penalty.save(nil)
                    
                    s.penalties.append(penalty)
                    tracker.penaltyTBL.penalties.append(penalty)
                    let ip = NSIndexPath(forRow: tracker.penaltyTBL.penalties.count-1, inSection: 0)
                    tracker.penaltyTBL.insertRowsAtIndexPaths([ip], withRowAnimation: .Top)
                    
                    s.scoreSave(nil)
                    tracker.updateScoreboard()
                    
                    
                case .Offset,.Declined:
                    
                    penalty.enforcement = key
                    
                    penalty.save(nil)
                    
                    s.penalties.append(penalty)
                    tracker.penaltyTBL.penalties.append(penalty)
                    let ip = NSIndexPath(forRow: tracker.penaltyTBL.penalties.count-1, inSection: 0)
                    tracker.penaltyTBL.insertRowsAtIndexPaths([ip], withRowAnimation: .Top)
                    
                    s.save(nil)
                    tracker.updateScoreboard()
                    
                case .PreviousSpot:
                    
                    if s.team.object.isEqual(penalty.team.object) {
                        
                        penalty.endX = s.startX.penaltyMinus(penalty.distance)
                        
                    } else {
                        
                        penalty.endX = s.startX.penaltyPlus(penalty.distance)
                        
                    }
                    
                    penalty.enforcement = key
                    
                    penalty.save(nil)
                    
                    s.penalties.append(penalty)
                    tracker.penaltyTBL.penalties.append(penalty)
                    let ip = NSIndexPath(forRow: tracker.penaltyTBL.penalties.count-1, inSection: 0)
                    tracker.penaltyTBL.insertRowsAtIndexPaths([ip], withRowAnimation: .Top)
                    
                    s.replay = true
                    
                    s.scoreSave(nil)
                    tracker.updateScoreboard()
                    
                    tracker.replaySWI.setOn(true, animated: true)
                    tracker.field.setNeedsDisplay()
                    tracker.drawButtons()
                    
                case .DeadBallSpot:
                    
                    var yard = Yardline(spot: s.startX.spot)
                    
                    for play in reverse(s.plays) {
                        
                        if let x = play.endX {
                            
                            var b = false
                            
                            switch play.key as Key {
                            case .Incomplete: ()
                            default:
                                
                                yard = Yardline(spot: x.spot)
                                b = true
                                
                            }
                            
                            if b { break }
                            
                        }
                        
                    }
                    
                    for p in reverse(s.penalties) {
                        
                        if let x = p.endX {
                            
                            yard = Yardline(spot: x.spot)
                            
                            break
                            
                        }
                        
                    }
                    
                    if s.team.object.isEqual(penalty.team.object) {
                        
                        penalty.endX = yard.increment(penalty.distance * -1)
                        
                    } else {
                        
                        penalty.endX = yard.increment(penalty.distance)
                        
                    }
                    
                    penalty.enforcement = key
                    
                    penalty.save(nil)
                    
                    s.penalties.append(penalty)
                    tracker.penaltyTBL.penalties.append(penalty)
                    let ip = NSIndexPath(forRow: tracker.penaltyTBL.penalties.count-1, inSection: 0)
                    tracker.penaltyTBL.insertRowsAtIndexPaths([ip], withRowAnimation: .Top)
                    
                    tracker.field.setNeedsDisplay()
                    tracker.drawButtons()
                    
                    s.scoreSave(nil)
                    tracker.updateScoreboard()
                    
                case .SpotOfFoul:
                    
                    penalty.enforcement = key
                    
                    tracker.newPenalty = penalty
                    
                    tracker.spot()
                    
                default:
                    
                    ()
                    
                }
                
                close()
            
            // ++++++++++++++++++++++++++++++++++++++++++++++++
            default:
                
                ()
                
            }
            
        }
        
    }
    
    func close(){
        
        dismissViewControllerAnimated(false, completion: nil)
        
    }

}