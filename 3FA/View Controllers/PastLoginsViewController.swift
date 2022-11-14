//
//  PastLoginsViewController.swift
//  3FA
//
//  Created for E102 Final Project in the 2022 Fall Semester
//
//  Team members:
//  Ellie Baker
//  Skye Barnes
//  Shayla Battle
//  Griffin Tomaszewski

import UIKit
import Firebase

class PastLoginsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //user variables
    var username = ""
    var loginDictionary : NSDictionary!
    var loginInfo : [String]! = []
    
    //table showing logins
    @IBOutlet var loginTbl: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //setting up login values to go into table
        for (_, value) in loginDictionary {
            let login : String = value as! String
            loginInfo.append(login)
        }
        
        //set up of login table
        loginTbl.delegate = self
        loginTbl.dataSource = self
        
        self.loginTbl.reloadData()
        
    }
    
    //NUMBER OF ROWS IN LOGIN TABLE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loginInfo.count
    }
    
    //SETUP CELLS IN LOGIN TABLE
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let login = loginInfo[indexPath.row]
        cell.textLabel?.text = login
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        return cell
    }

}
