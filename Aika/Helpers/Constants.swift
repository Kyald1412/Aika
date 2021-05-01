//
//  Constants.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 01/05/21.
//

import Foundation

struct Constants {
    static let analyzeTime = 5.0
}

enum CurrentMode: Int{
    case groundZero = -1
    case initial = 0
    case taskOption = 1
    case taskBegin = 2
    case taskProcess = 3
    case taskDone = 4
    case taskAnalyze = 5
    case showResult = 6
}
