//
//  EmotionsResultView.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 02/05/21.
//

import UIKit

class SpeechResultView: UIView {

    @IBOutlet weak var txtView: UITextView!

    func setText(speechText: String){
        self.txtView.text = speechText
    }

}
