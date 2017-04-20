//
//  ReadBookViewController.swift
//  TextAudio
//
//  Created by 김인로 on 2017. 4. 20..
//  Copyright © 2017년 highwill. All rights reserved.
//

import UIKit


class ReadBookViewController: UITableViewController, XMLParserDelegate {
    
    var book = Book()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = book.title
    }

}
