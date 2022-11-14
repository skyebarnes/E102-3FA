//
//  QuizOverViewController.swift
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

class QuizOverViewController: UIViewController {

    //score variables
    var score = 0
    var questions = 0
    
    //UI variables
    @IBOutlet var resultLbl: UILabel!
    @IBOutlet var percentLbl: UILabel!
    @IBOutlet var textLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Do any additional setup after loading the view.
        //set up labels
        resultLbl.text = "\(score)/\(questions)"
        percentLbl.text = "\(Int(Double(score)/Double(questions) * 100))%"
        if(score == questions) {
            textLbl.text = "WOW! Perfect score. You know how to be secure!"
        } else if (score > (questions/2)) {
            textLbl.text = "Pretty good effort. Good idea to review the info."
        } else {
            textLbl.text = "Go back and review the modules and try again."
        }
    }
    
    //DISMISS QUIZ AND QUIZ OVER CONTROLLERS
    @IBAction func exitBtn(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    

}
