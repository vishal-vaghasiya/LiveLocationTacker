//
//  CircleTVCell.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 07/08/25.
//

import UIKit

class CircleTVCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMember: UILabel!
    
    var clickEditEvent: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var data: CircleInfo! {
        didSet {
            lblName.text = data.name
            lblMember.text = "\(data.members.count) " + (data.members.count == 1 ? L10n.member : L10n.members)
        }
    }
    
    @IBAction func clickEdit(_ sender: UIButton) {
        self.clickEditEvent?()
    }
}
