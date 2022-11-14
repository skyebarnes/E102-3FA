//
//  CreateViewController.swift
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

class CreateViewController: UIViewController,  UIPickerViewDataSource, UIPickerViewDelegate {

    //database
    var ref: DatabaseReference!
    var users : NSDictionary!
    
    
    //text fields
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var IDTxt: UITextField!
    @IBOutlet var questionTxt: UITextField!
    @IBOutlet var firstNameTxt: UITextField!
    @IBOutlet var lastNameTxt: UITextField!
    
    //security question variables
    @IBOutlet var questionBtn: UIButton!
    @IBOutlet var confirmQuestionBtn: UIButton!
    @IBOutlet var questionTbl: UIPickerView!
    var chosenQuestion = ""
    var choseQuestion : Bool = false
    var questions = ["""
                     What was the make and model of your first car?
                     """,
                     """
                     What was the first concert you attended?
                     """,
                     """
                     In what city/town did your parents meet?
                     """,
                     """
                     Who was your favorite elementary school teacher?
                     """,
                     """
                     What was your childhood nickname?
                     """,
                     """
                     What is the middle name of your best friend in high school?
                     """,
                     """
                     What was the first thing you learned how to cook?
                     """]
    
    
    //variables for the password requirement icons/labels
    @IBOutlet var passwordReqStack: UIStackView!
    
    @IBOutlet var charLbl: UILabel!
    @IBOutlet var exclusionsLbl: UILabel!
    @IBOutlet var letterLbl: UILabel!
    @IBOutlet var numberLbl: UILabel!
    @IBOutlet var specialLbl: UILabel!
    
    @IBOutlet var charImg: UIImageView!
    @IBOutlet var exclusionsImg: UIImageView!
    @IBOutlet var letterImg: UIImageView!
    @IBOutlet var numberImg: UIImageView!
    @IBOutlet var specialImg: UIImageView!
    
    //employee IDs, would change to API(?) in greater scope
    let employeeIDs = [Employee(ID: "1", first: "Ellie", last: "Baker"),
                    Employee(ID: "2", first: "Skye", last: "Barnes"),
                    Employee(ID: "3", first: "Shayla", last: "Battle"),
                    Employee(ID: "4", first: "Griffin", last: "Tomaszewski")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    // Do any additional setup after loading the view.
        questionTbl.delegate = self
        questionTbl.dataSource = self
        questionTbl.isHidden = true
        confirmQuestionBtn.isHidden = true
        passwordReqStack.isHidden = true
        
    //makes keyboard go away when screen is clicked outside of text fields
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        ref = Database.database().reference()
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists()
            {
                self.users = snapshot.value as? NSDictionary ?? [:]
            }
        })
        
    //secure text entry
        usernameTxt.isSecureTextEntry = false
        passwordTxt.isSecureTextEntry = true
        IDTxt.isSecureTextEntry = false
        questionTxt.isSecureTextEntry = false
        firstNameTxt.isSecureTextEntry = false
        lastNameTxt.isSecureTextEntry = false
        
    }
    
    //GET KEYBOARD OUT OF VIEW
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    //CREATE ACCOUNT
    @IBAction func Create(_ sender: Any) {
        //get username and password
        guard let username = usernameTxt.text, let password = passwordTxt.text, let ID = IDTxt.text, let questionAnswer = questionTxt.text, let firstName = firstNameTxt.text, let lastName = lastNameTxt.text else {return}
        
        
    //checks if username is available
        if (checkAvailability()) {
            
            //creates all neccessary info to put into database for new user
            let newUserInfo = ["password": password,
                           "employeeID": ID,
                           "first name": firstName,
                           "last name": lastName,
                           "question": chosenQuestion,
                           "answer": questionAnswer]
            
            let newUserAuthentication = ["needAuthentication": "false",
                                         "haveAuthorized": "false",
                                         "needToVerifyOther": "false",
                                         "otherUser": ""]
            
            let newLogins :NSDictionary = [:]
            ref.child(username).child("User info").setValue(newUserInfo)
            ref.child(username).child("Authentication").setValue(newUserAuthentication)
            ref.child(username).child("Logins").setValue(newLogins)
            
            
            //alert that account has been created
            let alert = UIAlertController(title: "Account created", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                self.dismiss(animated: true)
                self.IDTxt.text = ""
                self.firstNameTxt.text = ""
                self.lastNameTxt.text = ""
                self.usernameTxt.text = ""
                self.passwordTxt.text = ""
                self.questionTxt.text = ""
                self.questionBtn.setTitle("Select Security Question", for: .normal)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    //function to check availability of account
    func checkAvailability() -> Bool {
        guard let username = usernameTxt.text, let password = passwordTxt.text, let ID = IDTxt.text, let firstName = firstNameTxt.text, let lastName = lastNameTxt.text, let question = questionTxt.text else {return false}
        
    //security question not answered/chosen
        if(!choseQuestion || question == "") {
            let alert = UIAlertController(title: "No security question", message: "You need to choose/answer a security question!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        //username not entered
        if(username == "") {
            let alert = UIAlertController(title: "No username", message: "Please enter a username.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }

        //see if username is taken or employee already has account
        if(users != nil) {
            if (users[username]) != nil {
                
                //username not available
                let alert = UIAlertController(title: "Username not available", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false;
            }
            for user in users {
                let userInfo : NSDictionary = user.value as! Dictionary<String, NSDictionary> as NSDictionary
                let accountInfo : NSDictionary = userInfo.value(forKey: "User info") as! NSDictionary
                if(accountInfo.value(forKey: "employeeID") as! String == ID) {
                    
                    //employee already has an account
                    let alert = UIAlertController(title: "Account already exists", message: "There is already an existing account for this employee.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return false;
                }
            }
        }
        
        //see if employee exists
        let enteredEmployeeInfo = Employee(ID: ID, first: firstName, last: lastName)
        
        //no employee associated with info
        if(!employeeIDs.contains(enteredEmployeeInfo)) {
            let alert = UIAlertController(title: "Employee not found", message: "That information does not match an employee. Contact your supervisor for assistance.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        //see if password is strong enough (if strong enough, account can be created)
        if(checkPasswordStrength(password: password, username: username, firstName: firstName, lastName: lastName)) {
            return true
        }
        
        //password not strong enough
        let alert = UIAlertController(title: "Password not allowed", message: "Your password does not meet the minimum requirements.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return false
        
    }
    
    
    //SEE STRENGTH OF PASSWORD
    func checkPasswordStrength(password:String, username:String, firstName:String, lastName:String) -> Bool {
        if(password.uppercased().contains(username.uppercased()) || password.uppercased().contains(firstName.uppercased()) || password.uppercased().contains(lastName.uppercased())) {
            return false
        }
        
        let passwordChars = Array(password)
        
        var numbers : Int = 0
        var lowercase : Int = 0
        var uppercase : Int = 0
        var special : Int = 0
        
        for c in passwordChars {
            if (c.isLetter) {
                if (c.isLowercase) {
                    lowercase += 1
                }
                if(c.isUppercase) {
                    uppercase += 1
                }
            } else if (c.isNumber) {
                numbers += 1
            } else if (c.isPunctuation) || (c.isSymbol){
                special += 1
            } else {
                return false
            }
        }
        
        //enough characters, includes lowercase and uppercase letters, special character, and number
        if(passwordChars.count > 10 && numbers > 0 && lowercase > 0 && uppercase > 0 && special > 0) {
            return true
        } else {
            return false
        }
    }
    
    //CHANGING TXT/IMG ASSOCIATED WITH PASSWORD REQS AS THEY ARE MET/UNMET
    @IBAction func UpdatePWRequirements(_ sender: Any) {
        guard let password = passwordTxt.text, let firstName = firstNameTxt.text, let lastName = lastNameTxt.text, let username = usernameTxt.text else {return}
        
        if (password.count <= 10) {
            charImg.image = UIImage(systemName: "xmark")
            charImg.tintColor = UIColor.red
            charLbl.font = UIFont.systemFont(ofSize: 14, weight: .light)
        } else {
            charImg.image = UIImage(systemName: "checkmark")
            charImg.tintColor = UIColor.green
            charLbl.font = UIFont.systemFont(ofSize: 14, weight: .ultraLight)
        }
        
        if(password.uppercased().contains(username.uppercased()) || password.uppercased().contains(firstName.uppercased()) || password.uppercased().contains(lastName.uppercased())) {
            exclusionsImg.image = UIImage(systemName: "xmark")
            exclusionsImg.tintColor = UIColor.red
            exclusionsLbl.font = UIFont.systemFont(ofSize: 14, weight: .light)
        } else {
            exclusionsImg.image = UIImage(systemName: "checkmark")
            exclusionsImg.tintColor = UIColor.green
            exclusionsLbl.font = UIFont.systemFont(ofSize: 14, weight: .ultraLight)
        }
       
        let passwordChars = Array(password)
        
        var numbers : Int = 0
        var lowercase : Int = 0
        var uppercase : Int = 0
        var special : Int = 0
        
        for c in passwordChars {
            if (c.isLetter) {
                if (c.isLowercase) {
                    lowercase += 1
                }
                if(c.isUppercase) {
                    uppercase += 1
                }
            } else if (c.isNumber) {
                numbers += 1
            } else if (c.isSymbol || c.isPunctuation){
                special += 1
            }
        }
        
        if (numbers == 0) {
            numberImg.image = UIImage(systemName: "xmark")
            numberImg.tintColor = UIColor.red
            numberLbl.font = UIFont.systemFont(ofSize: 14, weight: .light)
        } else {
            numberImg.image = UIImage(systemName: "checkmark")
            numberImg.tintColor = UIColor.green
            numberLbl.font = UIFont.systemFont(ofSize: 14, weight: .ultraLight)
        }
        
        if (uppercase == 0 || lowercase == 0) {
            letterImg.image = UIImage(systemName: "xmark")
            letterImg.tintColor = UIColor.red
            letterLbl.font = UIFont.systemFont(ofSize: 14, weight: .light)
        } else if (uppercase > 0 && lowercase > 0){
            letterImg.image = UIImage(systemName: "checkmark")
            letterImg.tintColor = UIColor.green
            letterLbl.font = UIFont.systemFont(ofSize: 14, weight: .ultraLight)
        }
        
        if (special == 0) {
            specialImg.image = UIImage(systemName: "xmark")
            specialImg.tintColor = UIColor.red
            specialLbl.font = UIFont.systemFont(ofSize: 14, weight: .light)
        } else {
            specialImg.image = UIImage(systemName: "checkmark")
            specialImg.tintColor = UIColor.green
            specialLbl.font = UIFont.systemFont(ofSize: 14, weight: .ultraLight)
        }
    }
    
    //MAKES PASSWORD REQUIREMENTS VISIBLE
    @IBAction func passwordEditingStart(_ sender: Any) {
        passwordReqStack.isHidden = false
    }
    
    //MAKES PASSWORD REQUIREMENTS HIDDEN
    @IBAction func passwordEditingEnd(_ sender: Any) {
        passwordReqStack.isHidden = true
    }
    
    //CONFIRMS SELECTED SECURITY QUESTION w/ BUTTON
    @IBAction func confirmQuestion(_ sender: Any) {
        questionTbl.isHidden = true
        questionBtn.isHidden = false
        confirmQuestionBtn.isHidden = true
    }
    
    //SETTING UP SECURITY QUESTION TABLE
    @IBAction func dropDown(_ sender: Any) {
        if questionTbl.isHidden {
            questionTbl.isHidden = false
            confirmQuestionBtn.isHidden = false
            questionBtn.isHidden = true
        } else {
            questionTbl.isHidden = true
            confirmQuestionBtn.isHidden = true
        }
    }
    
    //PICKER VIEW NUMBER OF COLUMNS
    @objc(numberOfComponentsInPickerView:) func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //PICKER VIEW NUMBER OF ROWS
    @objc func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return questions.count
    }
    
    //PICKER VIEW GET QUESTION
    @objc func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return questions[row]
    }
    
    //PICKERVIEW HEIGHT OF ROWS
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        40
    }
    
    //PICKERVIEW EDIT HOW EACH ROW LOOKS
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        pickerView.subviews[0].subviews.first?.subviews.last?.clipsToBounds = false
        
        let label = UILabel(frame: CGRect(x: 120, y: 0, width: self.view.frame.width-75, height: 90))
        
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = questions[row]
        
        return label;
    }
    
    //CALLED WHEN QUESTION SELECTED
    @objc func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        questionBtn.setTitle(questions[row], for: .normal)
        chosenQuestion = questions[row]
        choseQuestion = true
    }
    
    
    
}
