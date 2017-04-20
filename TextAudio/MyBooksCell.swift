//
//  MyBooksCell.swift
//  TextAudio
//
//  Created by 김인로 on 2017. 4. 17..
//  Copyright © 2017년 highwill. All rights reserved.
//

import UIKit

class MyBooksCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var SampleImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
