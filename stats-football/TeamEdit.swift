//
//  TeamDetail.swift
//  stats-football
//
//  Created by grobinson on 9/10/15.
//  Copyright (c) 2015 Wambl. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TeamEdit: UIViewController,UITextFieldDelegate {

    var main: MainCTRL!
    
    @IBOutlet weak var nameTXT: UITextField!
    @IBOutlet weak var shortTXT: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTXT.delegate = self
        shortTXT.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        nameTXT.endEditing(true)
        shortTXT.endEditing(true)
        
    }

    @IBAction func saveTPD(sender: AnyObject) {
        
        saveData()
        
    }
    
    func saveData() -> Bool {
        
        if nameTXT.text == "" || shortTXT.text == "" { return false }
        
        nameTXT.endEditing(true)
        shortTXT.endEditing(true)
        
        let team = Team(name: nameTXT.text, short: shortTXT.text)
        
        team.save(nil)
        
        main.teamsTBL.teams.insert(team, atIndex: 0)
        main.teamsTBL.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
        
        return true
        
    }
    
}