//
//  RepTableCell.swift
//  Squat Counter
//
//  Created by sam hastings on 25/07/2023.
//

import UIKit

class RepTableCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var CellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellView.layer.cornerRadius = cellView.frame.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
