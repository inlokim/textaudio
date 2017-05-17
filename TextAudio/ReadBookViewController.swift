//
//  ReadBookViewController.swift
//  TextAudio
//
//  Created by 김인로 on 2017. 4. 20..
//  Copyright © 2017년 highwill. All rights reserved.
//

import UIKit
import AVFoundation

class ReadBookViewController: UITableViewController, XMLParserDelegate, AVAudioPlayerDelegate
{
    var book = Book()
    
    var currentRow :Int = 0

    //Plist
    var bookIndexInfo = NSMutableDictionary()
    var pathOfContentPlist = String()
    
    var contentInfo = NSMutableArray()
    
    var parser = XMLParser()
    var texts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    
    var start = String()
    var desc = String()
    
    var player: AVAudioPlayer = AVAudioPlayer()
    var timer: Timer = Timer()
    var endTime:Float = Float()
    //var currentRow:Int = Int()
    
    var contentsIndex = IndexPath()
    var contents = NSMutableArray()
    var contentKey = String()
    
    var firstTry = true
    
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var prevButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    override func viewDidLoad()
    {
        print("viewDidLoad")
        
        super.viewDidLoad()
        
        let content:NSMutableDictionary = contents.object(at: contentsIndex.row) as! NSMutableDictionary
        
        self.title = content.object(forKey: "title") as! String?
        
        contentKey = content.object(forKey: "key") as! String
        
        //XML
        
        texts = []
        
        let xml = "\(book.homeDir)/audios/\(contentKey).xml"
        
        print("xml :" + xml)
        
        parser = XMLParser(contentsOf:URL(fileURLWithPath: xml))!
        parser.delegate = self
        parser.parse()
        
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 500

        
        //Audio
        
        loadAudio()
        
        //Navigation

        naviButtonHandler()
        
        //Plist
        
        getPlist()
        
        print("currentRow =\(currentRow)")
        
        tableView.reloadData()
        
        let indexPath = IndexPath(row: currentRow, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
        
    }

    
    func naviButtonHandler()
    {
        
        if (contentsIndex.row > 0) { self.prevButton.isEnabled = true }
        else { prevButton.isEnabled = false}
        
        if (contentsIndex.row < (contents.count - 1)) { self.nextButton.isEnabled = true}
        else { self.nextButton.isEnabled = false}
    }
    
    
    //Plist
    
    func getPlist()
    {
        //Book Index
        pathOfContentPlist = "\(book.homeDir)/\(contentKey).plist"
        
        print(pathOfContentPlist)
        
        if NSMutableDictionary(contentsOfFile: pathOfContentPlist) == nil
        {
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
        
        if self.tableView.indexPathForSelectedRow != nil
        {
            let currentIndexPath = self.tableView.indexPathForSelectedRow
            currentRow = (currentIndexPath?.row)!
        }
        
        print("current row : \(currentRow)")
        
        bookIndexInfo.setObject(String(currentRow), forKey: "currentRow" as NSCopying)
        bookIndexInfo.write(toFile: pathOfContentPlist, atomically: true)
        
    }
    
    func saveContentPlist(_ indexKey:Int)
    {
        let pathPlist = "\(book.homeDir)/\(book.bookId).plist"
        let indexInfo = NSMutableDictionary(contentsOfFile: pathPlist)
        
        indexInfo?.setObject(String(indexKey), forKey: "currentRow" as NSCopying)
        indexInfo?.write(toFile: pathPlist, atomically: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        print("viewwillappear")
        
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        print("viewWillDisappear")
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        
        if (player.isPlaying) {player.stop()}
        savePlist()
    }

    
    //MARK: - Navigation Methods
    @IBAction func prevButton(_ sender: Any)
    {
        buttonHander(contentsIndex.row - 1)
    }
    
    
    @IBAction func nextButton(_ sender: Any)
    {
        buttonHander(contentsIndex.row + 1)
    }
    
    func buttonHander(_ indexKey:Int)
    {
        self.playButton.title = "Play"
        contentsIndex = IndexPath(row: indexKey, section: 0)
        
        
        print("contentsIndex.row = \(contentsIndex.row)")
        
        savePlist()
        saveContentPlist(indexKey)
        
        //tableView.reloadData()
        
        viewDidLoad()
        viewWillAppear(false)
 
    }
    
    
    func reNew(){
        //reload application data (renew root view )
        UIApplication.shared.keyWindow?.rootViewController = storyboard!.instantiateViewController(withIdentifier: "Read_View")
    }
    
    //MARK: - XMLParser Methods

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        element = elementName as NSString
        if (elementName as NSString).isEqual(to: "SYNC")
        {
            elements = NSMutableDictionary()
            elements = [:]
            desc = String()
            desc = ""
            
            start = attributeDict["START"]! as String
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if (elementName as NSString).isEqual(to: "SYNC") {
            if !start.isEqual(nil) {
                elements.setObject(start, forKey: "start" as NSCopying)
            }
            if !desc.isEqual(nil) {
                elements.setObject(desc, forKey: "desc" as NSCopying)
            }
            texts.add(elements)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if element.isEqual(to: "START") {
            start.append(data)
        } else if element.isEqual(to: "DESC") {
            desc.append(data)
        }
    }
 
    
    //MARK: - Tableview Methods
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //print("texts.count : \(texts.count)")
        return texts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MyCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MyBooksCell
        
        //print("indexPath.row : \(indexPath.row)")
        
        let content:NSMutableDictionary = texts.object(at: indexPath.row) as! NSMutableDictionary
        
        cell.textLabel?.text = content.object(forKey: "desc") as! String?
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        setPlayerCurrentTime()
        currentRow = (indexPath.row)
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
 //MARK: - AudioPlayer
    
    @IBAction func playSoundAction(_ sender: Any)
    {
        if player.isPlaying {
            playButton.title = "Play"
            
            //nextButton.isEnabled = true
            //prevButton.isEnabled = true
            
            naviButtonHandler()
            
            player.stop()
            
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.slide)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
            if timer.isValid {
                timer.invalidate()
            }
            
        }
        else
        {
            playButton.title = "Stop"
            
            nextButton.isEnabled = false
            prevButton.isEnabled = false
            
            // In this case, this should find a selected row.
            //if firstTry
            // {
            setPlayerCurrentTime()
            
            //if currentRow is the first row, select the row
            
            let indexPath = IndexPath(row: currentRow, section: 0)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.top)
            
            
            //  firstTry = false
            // }
            
            player.play()
            
            UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.slide)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateCurrentTime) , userInfo: nil, repeats: true)
            
            
            //sleep mode on
            UIApplication.shared.isIdleTimerDisabled = true
            
        }
    }
    
    
    func setPlayerCurrentTime()
    {
        let indexPath = self.tableView.indexPathForSelectedRow
        
        if (indexPath==nil) { currentRow = 0}
        else {currentRow = (indexPath?.row)!}
        
        let content:NSMutableDictionary = texts.object(at: (currentRow)) as! NSMutableDictionary
        
        //print("start : "+((content.object(forKey: "start")) as! String))
        
        let intVal : Float = Float(content.object(forKey: "start") as! String)! / 1000
        
        //print("intVal : \(intVal)")
        
        player.currentTime = TimeInterval(intVal)
    }
    
    func updateCurrentTime()
    {
        //print("updateCurrentTime")
        
        let endTime = player.currentTime
        
        //Last row
        if currentRow == (texts.count-1)
        {
            //There is no more to play sound.
            if (!player.isPlaying)
            {
                timer.invalidate()
                
                playButton.title = "Play"
            }
            
            //sleep mode on
            UIApplication.shared.isIdleTimerDisabled = false
        }
        else
        {
            let content:NSMutableDictionary = texts.object(at: currentRow + 1) as! NSMutableDictionary
            let thisEndTime =  TimeInterval((content.object(forKey: "start") as! NSString).floatValue) / 1000
            
            //print("endTime : \(endTime)  thisEndTime : \(thisEndTime)")
            
            if endTime > thisEndTime
            {
                // if the height of a setence is longer than device's screen.
                
                let indexPath = IndexPath.init(row: currentRow+1, section: 0)
               /* let cell = self.tableView.cellForRow(at: indexPath)
                let cellHeight:Int = Int((cell?.contentView.frame.size.height)!)
                
                let bounds = UIScreen.main.bounds
                let boundsHeight:Int = Int(bounds.size.height)
                
                print ("cellHeight : \(cellHeight)    boundsHeight /2 \(boundsHeight / 2)")
                
                if (cellHeight > (boundsHeight / 2))
                {
                    self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.top)
                }
                else
                {
                    self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                }*/
                
                
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.top)
                currentRow = currentRow + 1
            }
        }
    }
    
    func loadAudio()
    {
        let path = "\(book.homeDir)/audios/\(contentKey).mp3"
        let url = NSURL.fileURL(withPath: path)
        do{
            try player = AVAudioPlayer(contentsOf: url)
            
            player.delegate = self
            player.prepareToPlay()
        }catch{
            print("Error ==> \(error)")
        }
    }
    
    //MARK: - Get and Save Plist

    
    
}
