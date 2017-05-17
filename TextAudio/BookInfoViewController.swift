//
//  DetailViewController.swift
//  TextAudio
//
//  Created by 김인로 on 2017. 4. 15..
//  Copyright © 2017년 highwill. All rights reserved.
//
import UIKit
import SDWebImage
import StoreKit

class BookInfoViewController: UIViewController {

    //Book
    var book:Book = Book()
    var pathOfMyBooksPlist = String()
    var booksInfo:NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var getSampleButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    var products = [SKProduct]()
    var product: SKProduct = SKProduct()
    
    var mzDownloadingViewObj    : MZDownloadManagerViewController?
    
    let myDownloadPath = Util.cacheDir
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print("mydownload path : \(Util.cacheDir)")
        
        authorLabel.text = book.author
        titleLabel.text = book.title
        
        print("book price : \(book.price)")
        
        if (book.price.isEmpty) {
            purchaseButton.isHidden = true
            restoreButton.isHidden = true
        }
        else
        {
            purchaseButton.setTitle(book.price, for: .normal)
        }
        
        let coverUrl :String = "http://inlokim.com/textAudioBooks/images/s_\(book.bookId).png"
        imageView.sd_setImage(with: URL(string: coverUrl))
        imageView = Util.imageViewBorder(imageView)
        imageView = Util.imageViewShadow(imageView)
        
        sizeLabel.text = "Size : \(book.size)"
        timeLabel.text = "Running Time : \(book.time)"
        contentLabel.text = book.content
        
        
        //Util.priceFormatter.locale = product.priceLocale
        //purchaseButton.titleLabel?.text = Util.priceFormatter.string(from: product.price)
        
        
        
        self.setUpDownloadingViewController()
        
        
        //Plist
        
        //If Already downloaded and then set buttons hidden
        
        pathOfMyBooksPlist = Util.cacheDir+"/myBooks.plist"
        
        if NSMutableArray(contentsOfFile: pathOfMyBooksPlist) != nil {
            booksInfo = NSMutableArray(contentsOfFile: pathOfMyBooksPlist)!
        }
        else { booksInfo = NSMutableArray() }
        
        for object in booksInfo
        {
            let str : String = object as! String
            var strArr = str.characters.split{$0 == ":"}.map(String.init)
            
            let bookId = strArr[0]
            if (bookId == book.bookId) {
                
                if (strArr[3] == "0")//preview 
                {
                    getSampleButton.isHidden = true
                }
                else if (strArr[3] == "1")//full
                {
                    getSampleButton.isHidden = true
                    purchaseButton.isHidden = true
                    restoreButton.isHidden = true
                }
            }
        }
        
        //SKProduct
        
        products = []
        
        // tableView.reloadData()
        
        //TextAudioProducts.ProductId = "kr.co.highwill.TextAudioBooks.\(book.bookId)"
        
       /* TextAudioProducts.store.requestProducts{success, products in
 
            if success
            {
                self.products = products!
                self.product = products![0]
                
                Util.priceFormatter.locale = self.product.priceLocale
                self.purchaseButton.titleLabel?.text = Util.priceFormatter.string(from: self.product.price)
            }
        }
        */
        
        NotificationCenter.default.addObserver(self, selector: #selector(BookInfoViewController.handlePurchaseNotification(_:)),
                                               name:  NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
        
      
    }
    
    
    override func viewDidLayoutSubviews() {
        contentLabel.sizeToFit()
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: contentLabel.frame.height + 340)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setUpDownloadingViewController()
    {
        let tabBarTabs : NSArray? = self.tabBarController?.viewControllers as NSArray?
        let mzDownloadingNav : UINavigationController = tabBarTabs?.object(at: 2) as! UINavigationController
        
        mzDownloadingViewObj = mzDownloadingNav.viewControllers[0] as? MZDownloadManagerViewController
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getSampleAction(_ sender: Any)
    {
        //print("getSampleAction")
        downloadFile(book.preview)
        getSampleButton.isEnabled = false
    }

    @IBAction func purchaseAction(_ sender: Any) {
        
        print("purchaseAction")
        
        if IAPHelper.canMakePayments()
        {
            TextAudioProducts.store.buyProduct(product)
        }
      
      /*
        downloadFile(book.full)
        purchaseButton.isEnabled = false
        getSampleButton.isEnabled = false
      */
    }
    
    @IBAction func restoreAction(_ sender: Any) {
        
        if IAPHelper.canMakePayments()
        {
            TextAudioProducts.store.restorePurchases()
        }
    }
    
    func handlePurchaseNotification(_ notification: Notification) {
       guard let productID = notification.object as? String else { return }
        
       print("product.productIdentifier : \(product.productIdentifier)")
        
      /* for (_, product) in products.enumerated() {
        
        print("dd")
        guard product.productIdentifier == productID else { continue }
            
            downloadFile(book.full)
            purchaseButton.isEnabled = false
            getSampleButton.isEnabled = false
            restoreButton.isEnabled = false
        }*/
        
        if (productID == product.productIdentifier)
        {
            downloadFile(book.full)
            purchaseButton.isEnabled = false
            getSampleButton.isEnabled = false
            restoreButton.isEnabled = false
        }
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
