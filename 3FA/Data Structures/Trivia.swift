//
//  Trivia.swift
//  3FA
//
//  Created for E102 Final Project in the 2022 Fall Semester
//
//  Team members:
//  Ellie Baker
//  Skye Barnes
//  Shayla Battle
//  Griffin Tomaszewski

import Foundation


struct Trivia {
    var question : String
    var correct : String
    var incorrect : [String]
    
    init(q : String, correct : String, incorrect : [String]) {
        question = q
        self.correct = correct
        self.incorrect = incorrect
    }
    
    //GET QUESTION
    func getQuestion() -> String {
        return question
    }
    
    //GET CORRECT ANSWER
    func getCorrect() -> String {
        return correct
    }
    
    //RANDOMIZES QUESTION ORDER
    func getRandomAnswers() -> [String] {
        var allAnswers : [String] = ["", "", "", ""]
        var index : [Int] = [1, 1, 1, 1]

        for answer in incorrect {
            var rand = Int.random(in: 0...3)
            while(index[rand] < 1) {
                rand = Int.random(in: 0...3)
            }
            allAnswers[rand] = answer
            index[rand] = -1
        }
        for num in 0...3 {
            if (index[num] > 0) {
                allAnswers[num] = correct
            }
        }
        
        
        return allAnswers
    }
    
}

