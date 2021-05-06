//
//  RecordedSoundCell.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 05/05/21.
//

import UIKit

class RecordedSoundCell: UITableViewCell {

    static let identifier = "RecordedSoundCell"
    
    var recorder = AKAudioRecorder.shared

    @IBOutlet weak var lblFIleName: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- Run Time Loop for slider
     func playSlider(){
        if recorder.isPlaying{
            self.btnPlay.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            self.btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
     }

}
