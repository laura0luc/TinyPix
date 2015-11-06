//
//  MasterViewController.swift
//  TinyPix
//
//  Created by LAURA LUCRECIA SANCHEZ PADILLA on 16/10/15.
//  Copyright © 2015 LAURA LUCRECIA SANCHEZ PADILLA. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    @IBOutlet var colorControl : UISegmentedControl!
    private var documentFileNames : [String] = []
    private var chosenDocument: TinyPixDocument?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "insertNewObject")
        navigationItem.rightBarButtonItem = addButton
        
        let prefs = NSUserDefaults.standardUserDefaults()
        let selectedColorIndex = prefs.integerForKey("selectedColorIndex")
        setTintColorForIndex(selectedColorIndex)
        colorControl.selectedSegmentIndex = selectedColorIndex
        
        reloadFiles()
    }
    
    private func urlForFileName(fileName: NSString) -> NSURL{
        let fm = NSFileManager.defaultManager()
        let urls = fm.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask) as [NSURL]
        let directoryURL = urls[0]
        let fileURL = directoryURL.URLByAppendingPathComponent(fileName as String)
        return fileURL
    }
    
    private func reloadFiles(){
        let paths =  NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as [String]
        let path = paths[0] as NSString
        let fm = NSFileManager.defaultManager()
        do{
            let files = try fm.contentsOfDirectoryAtPath(path as String)
            let sortedFileNames = files.sort() {  fileName1, fileName2 in
                do{
                    let file1Path = path.stringByAppendingPathComponent(fileName1)
                    let file2Path = path.stringByAppendingPathComponent(fileName2)
                    let attr1 = try fm.attributesOfItemAtPath(file1Path)
                    let attr2 = try fm.attributesOfItemAtPath(file2Path)
                    let file1Date = attr1[NSFileCreationDate] as! NSDate
                    let file2Date = attr2[NSFileCreationDate] as! NSDate
                    let result = file1Date.compare(file2Date)
                    return result == NSComparisonResult.OrderedAscending
                }catch let innerError as NSError{
                    print("An error occurred while hetting attributes of item \(innerError.localizedDescription)")
                }
                return false
                
            }
            documentFileNames = sortedFileNames
            tableView.reloadData()
        }catch let error as NSError{
            print("An error occurred while hetting attributes of item \(error.localizedDescription)")
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentFileNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileCell")
        let path = documentFileNames[indexPath.row] as NSString
        cell?.textLabel?.text = path.lastPathComponent
        return cell!
    }
    
    private func setTintColorForIndex(colorIndex : Int){
        colorControl.tintColor = TinyPixUtils.getTintColorForIndex(colorIndex)
    }
    
    func insertNewObject(){
        let alert = UIAlertController(title: "Choose File Name", message: "Enter a name for your new TinyPix document", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let createAction = UIAlertAction(title: "Create", style: .Default) { action in
            let textField = alert.textFields![0] as UITextField
            self.createFileNamed(textField.text!)
        };
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func createFileNamed(fileName: String){
        let trimmedFileName = fileName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if !trimmedFileName.isEmpty{
            let targetName = trimmedFileName + ".tinypix"
            let saveUrl = urlForFileName(targetName)
            chosenDocument = TinyPixDocument(fileURL: saveUrl)
            chosenDocument?.saveToURL(saveUrl, forSaveOperation: UIDocumentSaveOperation.ForCreating, completionHandler: {success in
                if success{
                    print("Save ok")
                    self.reloadFiles()
                    self.performSegueWithIdentifier("masterToDetail", sender: self)
                }else{
                    print("Failed to save")
                }
                }
            )
        }
    }
    
    @IBAction func chooseColor(sender : UISegmentedControl){
        let selectedColorIndex = sender.selectedSegmentIndex
        setTintColorForIndex(selectedColorIndex)
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setInteger(selectedColorIndex, forKey: "selectedColorIndex")
        prefs.synchronize()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! UINavigationController
        let detailVC = destination.topViewController as! DetailViewController
        
        if sender === self{
            detailVC.detailItem = chosenDocument
        }else{
            let indexPath = tableView.indexPathForSelectedRow
            let fileName = documentFileNames[indexPath!.row]
            let docURL = urlForFileName(fileName)
            chosenDocument = TinyPixDocument(fileURL: docURL)
            chosenDocument?.openWithCompletionHandler() { success in
                if success{
                    print("Load OK")
                    detailVC.detailItem = self.chosenDocument
                }else{
                    print("Failed to load")
                }
            }
        }
    }
}

