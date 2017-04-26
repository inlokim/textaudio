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
    var badgeCount:Int = 0
    
    var books:[Book] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        print(Util.cacheDir)
        
        //booksInfo = reverseMyBooksList(booksInfo)
        
        getPlist()
        
        //Download
        NotificationCenter.default.addObserver(
            self,
            selector: NSSelectorFromString("downloadFinishedNotification:"),
            name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String),
            object: nil)
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        badgeCount = 0
        tabBarController?.tabBar.items?[0].badgeValue = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        badgeCount = 0
        tabBarController?.tabBar.items?[0].badgeValue = nil
    }
    
    func getPlist()
    {
        //Plist
        
        pathOfMyBooksPlist = Util.cacheDir+"/myBooks.plist"
        
        if NSMutableArray(contentsOfFile: pathOfMyBooksPlist) != nil {
            booksInfo = NSMutableArray(contentsOfFile: pathOfMyBooksPlist)!
        }
        else { booksInfo = NSMutableArray() }
    }
    
    
    //list desc sort
    
    func reverseMyBooksList(_ nsarr : NSMutableArray) -> NSMutableArray
    {
            return NSMutableArray(array: nsarr.reverseObjectEnumerator().allObjects).mutableCopy() as! NSMutableArray
    }
    
    
    // MARK: - NSNotification Methods -
    
    func downloadFinishedNotification(_ notification : Notification)
    {

        let book = notification.object as! Book
        
        print("book title : \(book.title)")
        print("book type : \(book.downloadUrl)")
        
        print(book)
        
        let tempStr:NSString  = book.downloadUrl as NSString
        let fileName = "\(Util.cacheDir)/\(tempStr.lastPathComponent)"
        
        unzipFile(fileName)
        deleteFile(fileName)
        
        //Plist
        
        //booksInfo = reverseMyBooksList(booksInfo)
        updateBooksInfo(book)
        //booksInfo = reverseMyBooksList(booksInfo)
        
        badgeCount += 1
        updateBadge()
        
        //getPlist()
        
        //tableView.reloadData()
        
        self.viewDidLoad()
        self.viewWillAppear(true)
    }
        
    func updateBadge()
    {
        tabBarController?.tabBar.items?[0].badgeValue = String(badgeCount)
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
        if (book.downloadUrl.range(of:"preview") != nil)
        {
            book.bookType = "0"
        }
        else if (book.downloadUrl.range(of: "full") != nil)
        {
            //preview  -> full
        
            book.bookType = "1"
   
            for object in booksInfo
            {
                let str : String = object as! String
                var strArr = str.characters.split{$0 == ":"}.map(String.init)
                let bookId = strArr[0]
                if (bookId == book.bookId) {
                    booksInfo.remove(object)
                    
                    let fileName = "\(Util.cacheDir)/\(book.bookId)_preview"
                    print("fileName : \(fileName)")
                    
                    deleteFile(fileName)
                }
            }
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
        
        let homeDir = "\(Util.cacheDir)/\(bookId)_\(bookType)"
        
        cell?.bookCover?.image = UIImage(contentsOfFile: "\(homeDir)/images/iPhoneBack.png")
        cell?.bookCover = Util.imageViewBorder((cell?.bookCover)!)

        
        let book = Book()
        book.bookId = bookId
        book.title = (cell?.titleLabel.text)!
        book.author = (cell?.authorLabel.text)!
        book.bookCoverView = (cell?.bookCover)!
        book.homeDir = homeDir
        
        //print("book homDir : \(book.homeDir)")
        
        books.append(book)
        
        
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

    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "show" {
            
            let nav = segue.destination as! UINavigationController
            if let bookCoverViewController = nav.topViewController as? BookCoverViewController {
                
                let indexPath = self.tableView.indexPathForSelectedRow
                let book = self.books[(indexPath?.row)!]
                
                print("book id : \(book.bookId)")
                print("book title : \(book.title)")
                
                bookCoverViewController.book = book
            }
        }
    }
    
    
}



