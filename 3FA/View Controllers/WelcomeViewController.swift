//
//  WelcomeViewController.swift
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

class WelcomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //user information variables
    var user : NSDictionary = [:]
    var userInfo : NSDictionary = [:]
    var authenticationInfo : NSDictionary = [:]
    var username : String = ""
    
    //UI variables
    @IBOutlet var welcomeTxt: UILabel!
    @IBOutlet var authenticationTxt: UILabel!
    @IBOutlet var authImg: UIImageView!
    @IBOutlet var authBtn: UIButton!

    //needed to verify other employee
    var otherUserAuthenticated = false
    var otherUsername = ""
    var otherUser : NSDictionary!
    
    //needed for self authentication
    var usersDictionary : NSDictionary!
    var otherUsers : [String]! = []
    @IBOutlet var userTbl: UITableView!
    var chosenUser : String!
    
    //timers
    var timer = Timer()
    var updateUITimer = Timer()
    
    //authentication variables
    var selfAuthenticate = false
    var needAuthentication = ""
    var otherNeedAuthentication = ""
    
    //database reference
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //put users into string array for input into table
        for (key, _) in usersDictionary {
            let user : String = key as! String
            if(user != username) {
                otherUsers.append(user)
            }
        }
        
        //get info related to current user
        userInfo = user.value(forKey: "User info") as! NSDictionary
        authenticationInfo = user.value(forKey: "Authentication") as! NSDictionary
        
        needAuthentication = authenticationInfo.value(forKey: "needAuthentication") as! String
        otherNeedAuthentication = authenticationInfo.value(forKey: "needToVerifyOther") as! String
        
        //updates UI depending on if authentication is needed or user needs to verify another employee
        userInterface()
        updateUITimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(userInterface), userInfo: nil, repeats: true)
        
        //welcome text set up
        welcomeTxt.text = "Welcome, \(userInfo.value(forKey: "first name")!) \(userInfo.value(forKey:"last name")!)"
        welcomeTxt.lineBreakMode = .byWordWrapping
        welcomeTxt.numberOfLines = 0
        welcomeTxt.textAlignment = .center
        
        //default authentication image/color
        authImg.image = UIImage(systemName: "lock.open.trianglebadge.exclamationmark")
        authImg.tintColor = UIColor.red
        authBtn.tintColor = UIColor.red
        
        //setting up table
        userTbl.delegate = self
        userTbl.dataSource = self
        
        self.userTbl.reloadData()
    }
    
    //SEGUE TO PREVIOUS LOGINS
    @IBAction func seePreviousLoginsBtn(_ sender: Any) {
        performSegue(withIdentifier: "PastLogins", sender: nil)
    }
    
    //SEGUE TO EDUCATIONAL MODULES
    @IBAction func educationalModulesBtn(_ sender: Any) {
        performSegue(withIdentifier: "Educational", sender: nil)
    }
    
    //AUTHENTICATION BUTTON PRESSED
    @IBAction func authentication(_ sender: Any) {
        
        //if authentication required for self
        if(selfAuthenticate) {
            
            //other user not selected yet error
            if(otherUsername == "") {
                let alert = UIAlertController(title: "Please select other user", message: "You need to select another user first!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                
                //authenticated by user, still needs to be authenticated by other employee
                authImg.tintColor = UIColor.yellow
                authBtn.tintColor = UIColor.yellow
                authBtn.setTitle("Waiting for other user...", for: .normal)
                
                //checks if other user has authenticated it every three seconds
                timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(checkOtherUser), userInfo: nil, repeats: true)
            }
        } else {
            
            //authentication required by other employee, verifies their login
            ref.child(username).child("Authentication").child("needToVerifyOther").setValue("false")
            ref.child(username).child("Authentication").child("otherUser").setValue("")
            authImg.image = UIImage(systemName: "lock.fill")
            authImg.tintColor = UIColor.green
            authBtn.tintColor = UIColor.green
        }
    }
    
    @objc func checkOtherUser() {
        
        //gets updated information for other user
        ref.child(otherUsername).child("Authentication").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.otherUser = snapshot.value as? NSDictionary
            print(self.otherUser!)
        })
        
        //if other user has verified the login yet
        if(otherUser.value(forKey: "needToVerifyOther") as! String == "false") {
            otherUserAuthenticated = true
        }
        
        //changes UI and resets things to show that login has been authenticated
        if(otherUserAuthenticated) {
            timer.invalidate()
            authImg.image = UIImage(systemName: "lock.fill")
            authImg.tintColor = UIColor.green
            authBtn.tintColor = UIColor.green
            authBtn.setTitle("Authenticated!", for: .normal)
            authBtn.isUserInteractionEnabled = false
            userTbl.isUserInteractionEnabled = false
            ref.child(username).child("Authentication").child("needAuthentication").setValue("false")
            ref.child(username).child("Authentication").child("haveAuthorized").setValue("true")
            
        }
    }
    
    //UPDATES USER INTERFACE
    @objc func userInterface() {
        
        //gets updated authentication info for user
        ref.child(username).child("Authentication").child("needAuthentication").observeSingleEvent(of: .value, with: { (snapshot) in
            self.needAuthentication = snapshot.value as! String
        })
        ref.child(username).child("Authentication").child("needToVerifyOther").observeSingleEvent(of: .value, with: { (snapshot) in
            self.otherNeedAuthentication = snapshot.value as! String
        })

        //no authentication needed at all
        if(needAuthentication == "false" && otherNeedAuthentication == "false") {
            authenticationTxt.text = "No authentication needed right now."
            authImg.isHidden = true
            authBtn.isHidden = true
            userTbl.isHidden = true
            
        //other employee needs authentication
        } else if (otherNeedAuthentication == "true") {
            ref.child(username).child("Authentication").child("otherUser").observeSingleEvent(of: .value, with: { (snapshot) in
                self.otherUsername = snapshot.value as! String
            })
            authenticationTxt.text = "\(otherUsername) is requesting that you be the third factor in their authentication."
            authImg.isHidden = false
            authBtn.isHidden = false
            userTbl.isHidden = true
            
        //self needs authentication
        } else {
            authenticationTxt.text = "Select other employee to verify authentication:"
            authImg.isHidden = false
            authBtn.isHidden = false
            userTbl.isHidden = false
            selfAuthenticate = true

        }
    }
    

    //prepare to pass info to past logins view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "PastLogins") {
            let loginsViewController = segue.destination as! PastLoginsViewController
            loginsViewController.username = username
            
            if(user.value(forKey: "Logins") == nil) {
                loginsViewController.loginDictionary = ([:])
            } else {
                loginsViewController.loginDictionary = (user.value(forKey: "Logins") as! NSDictionary)
            }
        }
    }
    
    //NUMBER OF ROWS IN TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherUsers.count
    }
    
    //SET UP CELLS IN TABLE VIEW
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "otherUser", for: indexPath)
        let otherUser = otherUsers[indexPath.row]
        cell.textLabel?.text = otherUser
        
        return cell
    }
    
    //ROW SELECTED IN TABLE VIEW
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if the user previously selected an employee, takes away that employees need to verify
        if(otherUsername != "") {
            ref.child(otherUsername).child("Authentication").child("needToVerifyOther").setValue("false")
            ref.child(otherUsername).child("Authentication").child("otherUser").setValue("")
        }
        otherUsername = otherUsers[indexPath.row]
        ref.child(otherUsername).child("Authentication").child("needToVerifyOther").setValue("true")
        ref.child(otherUsername).child("Authentication").child("otherUser").setValue(username)
        ref.child(otherUsername).child("Authentication").observeSingleEvent(of: .value, with: { (snapshot) in            
            self.otherUser = snapshot.value as? NSDictionary
        })
    }
    

}
