//
//  Expression.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 01/05/21.
//

import Foundation

class Expression {
    var lookOut:Float = 0.0
    var smiling:Float = 0.0
    var excited:Float = 0.0
    var neutral:Float = 0.0
    var timeSpeaking:Float = 0.0
    var speechText = ""
    
    func timeSpeakingString() -> String {
        return String(format: "%.2f", timeSpeaking)
    }
    
    func feedbackAnalyze() -> String {
        var result = "You are very good, keep it up!"

        if lookOut > (timeSpeaking / 2) {
            result = "Too much looking out, stay focused!! More eye contact!!"
        }
        
        if timeSpeaking < 5 {
            result = "I can't analyze your speech because it was too short :("
        }
        
        return result
    }
}
