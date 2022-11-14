//
//  ViewController.swift
//  3FA
//
//  Created for E102 Final Project in the 2022 Fall Semester
//
//  Team members:
//  Ellie Baker
//  Skye Barnes
//  Shayla Battle
//  Griffin Tomaszewski

import CoreLocation
import UIKit
import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate {

    //UI variables
    @IBOutlet var forgotPasswordBtn: UIButton!
    @IBOutlet var createAccountBtn: UIButton!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
    //database variables
    var ref: DatabaseReference!
    var users : NSDictionary!
    
    //location variables
    var country, state, city : String!
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.green]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        password.isSecureTextEntry = true
        
        ref = Database.database().reference()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
    //get all users - in future updates, could just get data for single user key being used to sign in but this is useful for passing user keys to the user table in the authentication view controller
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists()
            {
                self.users = snapshot.value as? NSDictionary ?? [:]
            }
        })

    }
    
    //LOGIN BUTTON PRESSED
    @IBAction func login(_ sender: Any) {
        
        //bug here, if account was just created, need to press button twice to log in. there is also a bug where if the user has allowed location permissions while app is in use rather than allowing location permissions individually for each login, the button needs to be pressed twice to log in as well. This can be addressed in future updates.
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists()
            {
                self.users = snapshot.value as? NSDictionary ?? [:]
            }
        })
        
        //get username and password
        guard let username = username.text, let password = password.text else { return }
        
        //if there is a matching username
        if(users != nil) {
            
            //username is in system
            if (users[username]) != nil {
                
                //checks if passwords match
                let user : NSDictionary = users[username] as! NSDictionary
                let userInfo : NSDictionary = user.value(forKey: "User info") as! NSDictionary
                let pw : String = userInfo.value(forKey: "password") as! String
                if(password == pw && password.count > 1) {
                    
                    //request location
                    locationManager.requestLocation()
                    
                    if(city != nil && country != nil) {
                        
                        //get date info
                        let calendar = NSCalendar.current
                        let year = calendar.component(.year, from: Date())
                        let month = calendar.component(.month, from: Date())
                        let day = calendar.component(.day, from: Date())
                        let hour = calendar.component(.hour, from: Date())
                        let minute = calendar.component(.minute, from: Date())
                        let second = calendar.component(.second, from: Date())
                        
                        //makes time more aesthetically pleasing :-)
                        var h, m, s : String
                        if(hour < 10) {
                            h = "0\(hour)"
                        } else {
                            h = "\(hour)"
                        }
                        
                        if(minute < 10) {
                            m = "0\(minute)"
                        } else {
                            m = "\(minute)"
                        }
                        
                        if(second < 10) {
                            s = "0\(second)"
                        } else {
                            s = "\(second)"
                        }
                        
                        //this string will be put in the database
                        let date = "\(h):\(m):\(s) on \(month)/\(day)/\(year) at or near \(city!), \(state!), \(country!) from \(UIDevice.current.name)."
                        
                        let key = ref.childByAutoId().key!
                        ref.child(username).child("Logins").child(key).setValue(date)
                        performSegue(withIdentifier: "Login", sender: nil)
                    }
                } else {
                    
                    //create alert for invalid password
                    let alert = UIAlertController(title: "Invalid password", message: "Incorrect password for \(username)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                
                //create alert for invalid username
                let alert = UIAlertController(title: "Invalid username", message: "There is not an account for \(username)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //for login screen, pass user info and dictionary of all other usernames for third factor. Could be changed to dictionary of coworkers names rather than usernames in the future.
        if(segue.identifier == "Login") {
            let welcomeViewController = segue.destination as! WelcomeViewController
            guard let username = username.text else {return}
            welcomeViewController.username = username
            welcomeViewController.user = users[username] as! NSDictionary
            welcomeViewController.usersDictionary = users
        }
        
        guard let sender = sender as? UIButton else {return}
        
        //go to create account/forgot password page
        if sender == createAccountBtn {
            segue.destination.title = "Create Account"
        } else {
            segue.destination.title = ""
        }
        
            
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            //turn coordinates into city, state, country format
            geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
                if (error != nil)
                {
                    Swift.print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                
                if(placemarks == nil) {
                    return
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    self.country = pm.country!
                    self.state = pm.administrativeArea!
                    self.city = pm.locality!
                }
            })
            
        }
        
    }
        
    //ERROR WITH GETTING LOCATION
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Could not login", message: "Need location for login history.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //LOCATION AUTHORIZATION CHANGED - STARTS UPDATING
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager.startUpdatingLocation()
    }
}




