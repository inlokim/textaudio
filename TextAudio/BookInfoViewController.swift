//
//  DetailViewController.swift
//  TextAudio
//
//  Created by 김인로 on 2017. 4. 15..
//  Copyright © 2017년 highwill. All rights reserved.
//
import UIKit
import SDWebImage


class BookInfoViewController: UIViewController {

    //Book
    var book:Book = Book()
    
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var getSampleButton: UIButton!
    
    
    var mzDownloadingViewObj    : MZDownloadManagerViewController?
    
    let myDownloadPath = Util.cacheDir
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print("mydownload path : \(Util.cacheDir)")
        
        authorLabel.text = book.author
        titleLabel.text = book.title

        let coverUrl :String = "http://inlokim.com/textAudioBooks/images/s_\(book.bookId).png"
        imageView.sd_setImage(with: URL(string: coverUrl))
        
        sizeLabel.text = "Size : \(book.size)"
        timeLabel.text = "Running Time : \(book.time)"
        contentLabel.text = book.content
        
        
        self.setUpDownloadingViewController()
        
    }

    func setUpDownloadingViewController() {
        let tabBarTabs : NSArray? = self.tabBarController?.viewControllers as NSArray?
        let mzDownloadingNav : UINavigationController = tabBarTabs?.object(at: 2) as! UINavigationController
        
        mzDownloadingViewObj = mzDownloadingNav.viewControllers[0] as? MZDownloadManagerViewController
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func getSampleAction(_ sender: Any) {
        
        print("getSampleAction")
        downloadFile(book.preview)

    }
    
    
    @IBAction func parchaseAction(_ sender: Any) {
        downloadFile(book.full)
    }
    
    func downloadFile(_ bookurl:String)
    {
        let fileURL  : NSString = bookurl as NSString
        book.downloadUrl = fileURL as String
        
        var fileName : NSString = fileURL.lastPathComponent as NSString
        fileName = MZUtility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(fileName as String) as NSString)
        
        print("fileURL = \(fileURL)")
        
        //Use it download at default path i.e document directory
        mzDownloadingViewObj?.downloadManager.addDownloadTask(fileName as String, fileURL: fileURL.addingPercentEscapes(using: String.Encoding.utf8.rawValue)!, destinationPath: myDownloadPath, book:book)
    }
}
