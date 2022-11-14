//
//  QuizViewController.swift
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

class QuizViewController: UIViewController {

    //UI variables
    @IBOutlet var answer1Btn: UIButton!
    @IBOutlet var answer2Btn: UIButton!
    @IBOutlet var answer3Btn: UIButton!
    @IBOutlet var answer4Btn: UIButton!
    @IBOutlet var questionLbl: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    
    //quiz variables
    var category = ""
    var currentQuestionNum = -1
    var numQuestions = 9
    var numQuestionsDone = 0
    var score = 0
    var currentQuestion = Trivia(q: "", correct: "", incorrect: ["", "", ""])
    
    //list of questions, could be in text file in the future
    var questionList = [Trivia(q: "A secure password will be:", correct: "At least 13 characters long", incorrect: ["At least 5 characters long", "At least 8 characters long", "At least 20 characters long"]), Trivia(q: "Select the true statements regarding passwords:", correct: "It is important to change your passwords frequently.", incorrect: ["It’s ok to reuse passwords, as long as they aren’t for important websites.","A secure password can be a common word with some letters replaced with symbols.","Your password should consist of just letters."]),Trivia(q: "True or false: if your password is secure enough, you don’t need to take additional security measures with your account.", correct: "False", incorrect: ["True","Extra answer","Extra answer"]),Trivia(q: "Which of the following is a proper use of two-factor authentication?", correct: "Denying a login attempt from your coworker even though you think it was authentic because you didn’t watch them login.", incorrect: ["Using your internet-famous childhood pet as a security question.","Denying a login attempt from your coworker’s account after watching them login.","Using your dog Spot as an answer to a security question."]),Trivia(q: "True or false: you should never ever use unsecured wifi.", correct: "False: it is ok as long as you don’t visit important sites or send out sensitive information and you use a VPN.", incorrect: ["True: it is never safe to use unsecured wifi as your information can be visible to others.","True: unsecured wifi means there are always hackers on it.","False: unsecure wifi is perfectly safe."]),Trivia(q: "Which website is secure?", correct: "https://yahoo.com", incorrect: ["http://google.com","https://facebooook.com","http://securemail.com"]),Trivia(q: "You get an email from your friend Sally whom you haven’t heard from since high school. She says she lost her job and is desperate for help and is wondering if you could loan her some money.", correct: "This sounds like a scam and you should report the email.", incorrect: ["This is probably actually Sally.","You should always trust emails that say they are from old friends.","There are no spelling errors in this email, so it must not be a scam."]),Trivia(q: "You receive a call from your mom asking for her Amazon login. She promises to buy you a gift if you remember it.", correct: "This is probably actually your mom.", incorrect: ["This sounds like a scam.","You do not want the free present so you do not help your mom.","You should hang up the phone immediately."]),Trivia(q: "You receive a call from Verizon saying your account is eligible for a discount. The caller needs your login information to confirm your account and the discount will applied.", correct: "This sounds like a scam.", incorrect: ["You should give them your information.","This seems trustworthy.","This is probably actually Verizon."])]
    
    //timer for delay between questions
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //make buttons rounded
        answer1Btn.layer.cornerRadius = 20
        answer2Btn.layer.cornerRadius = 20
        answer3Btn.layer.cornerRadius = 20
        answer4Btn.layer.cornerRadius = 20
        
        //make text fit in button
        questionLbl.adjustsFontSizeToFitWidth = true
        answer1Btn.titleLabel?.adjustsFontSizeToFitWidth = true
        answer2Btn.titleLabel?.adjustsFontSizeToFitWidth = true
        answer3Btn.titleLabel?.adjustsFontSizeToFitWidth = true
        answer4Btn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //make text not limited to specific number of lines
        answer1Btn.titleLabel?.numberOfLines = 0
        answer2Btn.titleLabel?.numberOfLines = 0
        answer3Btn.titleLabel?.numberOfLines = 0
        answer4Btn.titleLabel?.numberOfLines = 0
        
        //display first questions
        newQuestion()
        
    }
    
    //UPDATE DISPLAY WHEN ANSWER CHOSEN
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        //change colors
        //chosen answer correct
        if(sender.title(for: .normal) == currentQuestion.getCorrect()) {
            UIView.animate(withDuration: 2, animations: {
                sender.backgroundColor = UIColor.systemGreen
            })
            score += 1
            
        //chosen answer wrong
        } else {
            UIView.animate(withDuration: 2, animations: {
                sender.backgroundColor = UIColor.systemRed
            })
            
            //find right answer and make that one visible
            if(answer1Btn.title(for: .normal) == currentQuestion.getCorrect()) {
                UIView.animate(withDuration: 2, animations: {
                    self.answer1Btn.backgroundColor = UIColor.systemGreen
                })
            } else if (answer2Btn.title(for: .normal) == currentQuestion.getCorrect()) {
                UIView.animate(withDuration: 2, animations: {
                    self.answer2Btn.backgroundColor = UIColor.systemGreen
                })
            } else if(answer3Btn.title(for: .normal) == currentQuestion.getCorrect()) {
                UIView.animate(withDuration: 2, animations: {
                    self.answer3Btn.backgroundColor = UIColor.systemGreen
                })
            } else {
                UIView.animate(withDuration: 2, animations: {
                    self.answer4Btn.backgroundColor = UIColor.systemGreen
                })
            }
        }
        
        //disable buttons so user cant use them during delay
        answer1Btn.isEnabled = false
        answer2Btn.isEnabled = false
        answer3Btn.isEnabled = false
        answer4Btn.isEnabled = false
        
        numQuestionsDone += 1
        
        //update progress bar
        progressBar.setProgress(Float(Double(numQuestionsDone)/Double(numQuestions)), animated: true)
        
        //check if there are more questions
        if(numQuestions - numQuestionsDone > 0) {
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(newQuestion), userInfo: nil, repeats: false)
        } else {
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(changeView), userInfo: nil, repeats: false)
            
        }
        
    }
    
    //UPDATE VIEW FOR NEW QUESTION
    @objc func newQuestion() {
        timer.invalidate()
        
        //reset colors
        self.answer1Btn.backgroundColor = UIColor.gray
        self.answer2Btn.backgroundColor = UIColor.gray
        self.answer3Btn.backgroundColor = UIColor.gray
        self.answer4Btn.backgroundColor = UIColor.gray
        
        //enable buttons
        answer1Btn.isEnabled = true
        answer2Btn.isEnabled = true
        answer3Btn.isEnabled = true
        answer4Btn.isEnabled = true
        
        //set new question
        currentQuestionNum += 1
        currentQuestion = questionList[currentQuestionNum]
        let answers = currentQuestion.getRandomAnswers()
        
        questionLbl.text = currentQuestion.getQuestion()
        
        //set random answers for each button
        answer1Btn.setTitle(answers[0], for: .normal)
        answer2Btn.setTitle(answers[1], for: .normal)
        answer3Btn.setTitle(answers[2], for: .normal)
        answer4Btn.setTitle(answers[3], for: .normal)
    }
    
    //PREPARE FOR QUIZ OVER VIEW
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let endView = segue.destination as! QuizOverViewController
        endView.score = score
        endView.questions = numQuestions
        
    }
    
    //CHANGE TO QUIZ OVER VIEW
    @objc func changeView() {
        performSegue(withIdentifier: "QuizOver", sender: nil)
    }

}

