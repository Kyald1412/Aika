//
//  EmotionsResultView.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 02/05/21.
//

import UIKit

class EmotionsResultView: UIView {

    @IBOutlet weak var lblSmiling: UILabel!
    @IBOutlet weak var lblLookOut: UILabel!
    @IBOutlet weak var lblNeutral: UILabel!
    @IBOutlet weak var lblExcited: UILabel!
    
    @IBOutlet weak var lblFeedback: UILabel!
  
    func setText(expression: Expression){
        self.lblSmiling.text = "Smiling: \(expression.smiling.formatted())s"
        self.lblNeutral.text = "Neutral: \(expression.neutral.formatted())s"
        self.lblExcited.text = "Excited: \(expression.focused.formatted())s"
        self.lblLookOut.text = "Look Out: \(expression.lookOut.formatted())s"
        
        self.lblFeedback.text = feedbackAnalyze(expression: expression)
    }
    
    func feedbackAnalyze(expression: Expression) -> String {
        var result = ""
        result = "You are very good, keep it up!"
        return result
    }

}
