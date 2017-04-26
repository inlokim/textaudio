//
//  BookCoverViewController.swift
//  TextAudio
//
//  Created by 김인로 on 2017. 4. 20..
//  Copyright © 2017년 highwill. All rights reserved.
//

import UIKit

class BookCoverViewController :  UIViewController {
    
    var book:Book = Book()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentsButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = book.bookCoverView.image
        
        imageView = Util.imageViewBorder(imageView)
        imageView = Util.imageViewShadow(imageView)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "show" {
            //let nav = segue.destination as! UINavigationController
            if let contentsViewController = segue.destination as? ContentsViewController {
                
                print("book cover book id : \(book.bookId)")
                
                contentsViewController.book = self.book
                
                //print("book homDir : \(book.homeDir)")
            }
        }
    }
    
    
}
