//
//  Employee.swift
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

struct Employee : Codable, Equatable {
    var ID, firstName, lastName : String
    
    init (ID: String, first: String, last: String) {
        self.ID = ID
        firstName = first
        lastName = last
    }
    
    static func ==(e1: Employee, e2: Employee) -> Bool {
        return e1.firstName.isEqual(e2.firstName) && e1.lastName.isEqual(e2.lastName) &&
            e1.ID.isEqual(e2.ID)
    }
}
