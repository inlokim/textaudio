//
//  MyBooksViewController.swift
//  TextAudio
//
//  Created by 김인로 on 2017. 4. 17..
//  Copyright © 2017년 highwill. All rights reserved.
//

import UIKit
import SSZipArchive

//let alertControllerViewTag: Int = 500

class MyBooksViewController: UITableViewController {
    
    var pathOfMyBooksPlist = String()
    var booksInfo:NSMutableArray = NSMutableArray()
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        print(Util.cacheDir)
        
        
        //Plist
        
        pathOfMyBooksPlist = Util.cacheDir+"/myBooks.plist"
        
        if NSMutableArray(contentsOfFile: pathOfMyBooksPlist) != nil {
            booksInfo = NSMutableArray(contentsOfFile: pathOfMyBooksPlist)!
        }
        else { booksInfo = NSMutableArray() }
        
        
        booksInfo = reverseMyBooksList(booksInfo)
        
        //Download
        NotificationCenter.default.addObserver(
            self,
            selector: NSSelectorFromString("downloadFinishedNotification:"),
            name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String),
            object: nil)
       
     }
    
    func reverseMyBooksList(_ nsarr : NSMutableArray) -> NSMutableArray
    {
            return NSMutableArray(array: nsarr.reverseObjectEnumerator().allObjects).mutableCopy() as! NSMutableArray
    }
    
    
    // MARK: - NSNotification Methods -
    
    func downloadFinishedNotification(_ notification : Notification)
    {
        
        let book = notification.object as! Book
        
        print("book title : \(book.title)")
        print("book preview : \(book.downloadUrl)")
        
        print(book)
        
        let tempStr:NSString  = book.downloadUrl as NSString
        let fileName = "\(Util.cacheDir)/\(tempStr.lastPathComponent)"
        //let fileName =  "\(Util.cacheDir)/\(book.bookId).zip"
        
        unzipFile(fileName)
        deleteFile(fileName)
        updateBooksInfo(book)
        booksInfo = reverseMyBooksList(booksInfo)
        tableView.reloadData()
    }
    
    
    func unzipFile(_ fileName : String)
    {
        //print("downloadFinishedNotification")
        //let filePath = "\(Util.cacheDir)/\(fileName as String)"
        
        print("fileName:\(fileName)")
        
        SSZipArchive.unzipFile(atPath: fileName, toDestination: Util.cacheDir)
    }
    
    func deleteFile(_ fileName : String)
    {
        let fileManager = FileManager.default

        do {
            try fileManager.removeItem(atPath: fileName)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    func updateBooksInfo(_ book:Book)
    {
        if book.downloadUrl.range(of:"preview") != nil{
            book.bookType = "0"
        }
        else {
            book.bookType = "1"
        }

        let delimString = "\(book.bookId):\(book.title):\(book.author):\(book.bookType)"
        
        booksInfo.add(delimString)
        
        booksInfo.write(toFile: pathOfMyBooksPlist, atomically: true)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
// MARK: UITableViewDatasource Handler Extension
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {

       return booksInfo.count
       // return downloadManager.downloadingArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MyBooksCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MyBooksCell
        
        //let str:String = booksInfo[indexPath.row] as! String
        let str : String = booksInfo.object(at: indexPath.row) as! String
        var strArr = str.characters.split{$0 == ":"}.map(String.init)
        
        //show/hide
        cell?.progressView.isHidden = true
        cell?.progressLabel.isHidden = true
        
        //Title/author
        cell?.titleLabel.text = strArr[1]
        cell?.authorLabel.text = strArr[2]

        //full/preview
        
        var bookType :String
        
        if (strArr[3] == "0") {
            cell?.SampleImageView.isHidden = false
            bookType = "preview"
        }
        else {
            cell?.SampleImageView.isHidden = true
            bookType = "full"
        }
        
        //imageView
        let bookId = strArr[0]
        
        //print(Util.cacheDir+"/\(bookId)_\(bookType)/images/iPhoneBack.png")
        
        cell?.bookCover?.image = UIImage(contentsOfFile: Util.cacheDir+"/\(bookId)_\(bookType)/images/iPhoneBack.png")
        cell?.bookCover = Util.imageViewBorder(imageView: (cell?.bookCover)!)
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath.row % 2) == 0 {
            cell.backgroundColor = UIColor(colorLiteralRed: 0.99, green: 0.99, blue: 0.99, alpha: 1)
        }
        else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //let str:String = booksInfo[indexPath.row] as! String
        let str : String = booksInfo.object(at: indexPath.row) as! String
        var strArr = str.characters.split{$0 == ":"}.map(String.init)
        
        //full/preview
        
        var bookType :String
        
        if (strArr[3] == "0") { bookType = "preview" }
        else { bookType = "full"}
        
        //imageView
        let bookId = strArr[0]
        
        let fileName = "\(Util.cacheDir)/\(bookId)_\(bookType)"
        
        deleteFile(fileName)
        booksInfo.removeObject(at: (indexPath as NSIndexPath).row)
        booksInfo.write(toFile: pathOfMyBooksPlist, atomically: true)
        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)

    }

}



