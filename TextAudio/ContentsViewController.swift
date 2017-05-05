//
//  ContentsViewController.swift
//  TextAudio
//
//  Created by 김인로 on 2017. 4. 20..
//  Copyright © 2017년 highwill. All rights reserved.
//

import UIKit


class ContentsViewController: UITableViewController, XMLParserDelegate
{
    var book = Book()
    
    var parser = XMLParser()
    var contents = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    
    var contentTitle = String()
    var contentKey = String()
   
    //Plist
    var bookIndexInfo = NSMutableDictionary()
    var pathOfContentPlist = String()
    
    var currentRow :Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       
        contents = []
        
        let xml = "\(book.homeDir)/audios/list.xml"
        
        print("xml :" + xml)
        
        parser = XMLParser(contentsOf:URL(fileURLWithPath: xml))!
        
        parser.delegate = self
        parser.parse()
        

    }

    //Plist
    
    func getPlist()
    {
        pathOfContentPlist = "\(book.homeDir)/\(book.bookId).plist"
        
        print(pathOfContentPlist)
        
        if NSMutableDictionary(contentsOfFile: pathOfContentPlist) == nil {
            
            bookIndexInfo = NSMutableDictionary()
        }
        else
        {
            bookIndexInfo = NSMutableDictionary(contentsOfFile: pathOfContentPlist)!
            currentRow = Int(bookIndexInfo.object(forKey: "currentRow") as! String )!
        }
    }
    
    func savePlist()
    {
        print("savePlist")
        
        let currentIndexPath:IndexPath = self.tableView.indexPathForSelectedRow!
        
        bookIndexInfo.setObject(String(currentIndexPath.row), forKey: "currentRow" as NSCopying)
        bookIndexInfo.write(toFile: pathOfContentPlist, atomically: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
        getPlist()
        
        print("currentRow =\(currentRow)")
        
        let indexPath = IndexPath(row: currentRow, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.top)
   }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        savePlist()
    }
    
    
    //XMLParser Methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        element = elementName as NSString
        if (elementName as NSString).isEqual(to: "item")
        {
            elements = NSMutableDictionary()
            elements = [:]
            contentTitle = String()
            contentTitle = ""
            
            
            contentKey = attributeDict["key"]! as String
           
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if (elementName as NSString).isEqual(to: "item") {
            if !contentTitle.isEqual(nil) {
                elements.setObject(contentTitle, forKey: "title" as NSCopying)
            }
            if !contentKey.isEqual(nil) {
                elements.setObject(contentKey, forKey: "key" as NSCopying)
            }
            contents.add(elements)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        if element.isEqual(to: "title") {
            contentTitle.append(string)
        } else if element.isEqual(to: "key") {
            contentKey.append(string)
        }
    }
    
    //Tableview Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return contents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MyCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let content:NSMutableDictionary = contents.object(at: indexPath.row) as! NSMutableDictionary
        
        cell.textLabel?.text = content.object(forKey: "title") as! String?
        
       // print("key : \(content.object(forKey: "key"))")
            
        //cell?.authorLabel.text = book.author
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath.row % 2) == 0 {
            cell.backgroundColor = UIColor(colorLiteralRed: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        }
        else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "show" {
            if let readBookViewController = segue.destination as? ReadBookViewController {
                
                let indexPath = self.tableView.indexPathForSelectedRow
                //print(" indexPath  "+self.books[(indexPath?.row)!].bookId)
                
                //let content:NSMutableDictionary = contents.object(at: indexPath!.row) as! NSMutableDictionary

                readBookViewController.book = book
                readBookViewController.contentsIndex = indexPath!
                readBookViewController.contents = contents
            }
        }
    }
    
    
}
