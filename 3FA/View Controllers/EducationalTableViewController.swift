//
//  EducationalTableViewController.swift
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

class EducationalTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //UI variables
    @IBOutlet var module1Tbl: UITableView!
    @IBOutlet var module2Tbl: UITableView!
    @IBOutlet var module3Tbl: UITableView!
    @IBOutlet var module4Tbl: UITableView!

    //topics to put into tables
    var info1 = ["Creating a Password", "Two-Factor Authentication"]
    var info2 = ["WiFi", "Secure Websites", "Downloading from the Internet"]
    var info3 = ["Scams", "Phishing"]
    var info4 = ["Using this App", "How to Report a Cyberattack"]
    
    //selected topic to pass to info view controller
    var selectedTopic : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //setting up table views - one for each module
        module1Tbl.delegate = self
        module1Tbl.dataSource = self
        self.module1Tbl.reloadData()
        
        module2Tbl.delegate = self
        module2Tbl.dataSource = self
        self.module2Tbl.reloadData()
        
        module3Tbl.delegate = self
        module3Tbl.dataSource = self
        self.module3Tbl.reloadData()
        
        module4Tbl.delegate = self
        module4Tbl.dataSource = self
        self.module4Tbl.reloadData()
        
    }
    
    //SEGUE TO QUIZ
    @IBAction func takeQuizBtn(_ sender: Any) {
        performSegue(withIdentifier: "Quiz", sender: nil)
    }
    
    //NUMBER OF ROWS FOR EACH TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == module1Tbl) {
            return 2 // MODULE 1 creating a secure account
        } else if (tableView == module2Tbl) {
            return 3 // MODULE 2 staying secure online
        } else if (tableView == module3Tbl) {
            return 2 // MODULE 3 scams and phishing
        } else {
            return 2 // MODULE 4 miscellaneous
        }
    }
    
    //SETTING UP CELLS IN TABLE VIEW
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //MODULE 1 creating a secure account
        if(tableView == module1Tbl) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
            let info = info1[indexPath.row]
            cell.textLabel?.text = info
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            return cell
            
        //MODULE 2 staying secure online
        } else if (tableView == module2Tbl) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
            let info = info2[indexPath.row]
            cell.textLabel?.text = info
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            return cell
            
        //MODULE 3 scams and phishing
        } else if (tableView == module3Tbl) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath)
            let info = info3[indexPath.row]
            cell.textLabel?.text = info
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            return cell
        
        //MODULE 4 miscellaneous
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath)
            let info = info4[indexPath.row]
            cell.textLabel?.text = info
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            return cell
        }
    }
    
    //TOPIC SELECTED IN TABLE VIEWS
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //pulls topic from related string array
        if(tableView == module1Tbl) {
            selectedTopic = info1[indexPath.row]
        } else if(tableView == module2Tbl) {
            selectedTopic = info2[indexPath.row]
        } else if(tableView == module3Tbl) {
            selectedTopic = info3[indexPath.row]
        } else {
            selectedTopic = info4[indexPath.row]
        }
        performSegue(withIdentifier: "Info", sender: nil)
        
    }
    
    //PREPARE FOR INFO VIEW
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "Info") {
            let infoViewController = segue.destination as! InfoViewController
            infoViewController.selectedTopic = self.selectedTopic
            
        }
    }

}
