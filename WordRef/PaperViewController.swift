//
//  PaperViewController.swift
//  WordRef
//
//  Created by Darksair Sun on 4/23/15.
//  Copyright (c) 2015 MetroWind. All rights reserved.
//
// This file is part of WordRef.
//
// WordRef is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// WordRef is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with WordRef.  If not, see <http://www.gnu.org/licenses/>.

import Cocoa

let PapersLocation = "/Documents/Microsoft User Data/Sources.xml"

func dirName(f: String) -> String
    // `f' should not be a directory.
{
    let Comps = f.pathComponents
    var Dir = ""
    if Comps[0] == "/"
    {
        Dir = "/" + "/".join(Comps[1...count(Comps)-2])
    }
    else
    {
        Dir = "/".join(Comps[0...count(Comps)-2])
    }
    return Dir
}

func basename(f: String) -> String
{
    var Comps = f.pathComponents
    return Comps[count(Comps)-1]
}

func activateFile(f: String) -> Bool
    // `f' should not be a directory.
{
    if access((f as NSString).UTF8String, W_OK) != 0 || access((f as NSString).UTF8String, R_OK) != 0
    {
        var Filename = basename(f)
        
        var Desc = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 32))
        Desc.editable = false
        Desc.selectable = false
        Desc.bordered = false
        Desc.backgroundColor = NSColor(calibratedWhite: 0, alpha: 0)
        Desc.stringValue = "Choose \"\(Filename)\" in the file list and press \"Open\".\nThis (annoying) extra step is due to Mac's sandboxing mechanism :-("
        Desc.font = NSFont.labelFontOfSize(16)

        Desc.sizeToFit()

        println("Cannot access \(f)")
        var Panel = NSOpenPanel()
        Panel.directoryURL = NSURL(fileURLWithPath: dirName(f), isDirectory: true)
        Panel.nameFieldStringValue = Filename
        Panel.title = "Permission needed to open \"\(Filename)\""
        // Panel.prompt = "Choose \"Sources.xml\""
        Panel.extensionHidden = false
        Panel.allowedFileTypes = ["xml"]
        Panel.accessoryView = Desc
        Panel.runModal()
        return true
    }
    println("Can access \(f)")
    return true
}

func loadPapersFromDefaultLocation() -> ([Paper], Bool)
{
    var Path = NSHomeDirectory() + PapersLocation
    if (NSFileManager.defaultManager().fileExistsAtPath(Path))
    {
        if(activateFile(Path))
        {
            return (xml2Papers(Path), false)
        }
    }
    else
    {
        // Test purpose
        Path = NSHomeDirectory() + "/Desktop/Sources.xml"
        if (NSFileManager.defaultManager().fileExistsAtPath(Path))
        {
            if(activateFile(Path))
            {
                return (xml2Papers(Path), true)
            }
        }
    }
    return ([], true)
}

class PaperViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    var Papers: [Paper] = []
    var IsDemo = false
    @IBOutlet var tableView: NSTableView!

    // View
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = true
        tableView.registerForDraggedTypes([NSFilenamesPboardType])
        
        let nib = NSNib(nibNamed: "PaperCellView", bundle: NSBundle.mainBundle())
        tableView.registerNib(nib!, forIdentifier: "PaperCell")
        
        (Papers, IsDemo) = loadPapersFromDefaultLocation()

        tableView.setDelegate(self)
        tableView.setDataSource(self)
    }
    
    func addBib(file: String)
    {
        for paper in bib2Papers(String(contentsOfFile: file, encoding: NSUTF8StringEncoding, error: nil)!)
        {
            if paper != nil
            {
                if !contains(Papers, paper!)
                {
                    Papers.append(paper!)
                }
            }
        }
        tableView.reloadData()
    }
    
    func deletePapers(indices: [Int])
    {
        if count(indices) == 0
        {
            return
        }

        var Indices = sorted(indices)
        for i in 0...(count(indices)-1)
        {
            Papers.removeAtIndex(Indices[i] - i)
        }
        tableView.reloadData()
    }
    
    func save()
    {
        if !IsDemo
        {
            papers2Xml(Papers).writeToFile(NSHomeDirectory() + PapersLocation, atomically: false)
        }
    }

    // Data source and delegate
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        return count(Papers)
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return 48
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let cell = tableView.makeViewWithIdentifier("PaperCell", owner: self) as! PaperCellView
        let ThisPaper: Paper = Papers[row]
        
        cell.Title.stringValue = ThisPaper.Title
        cell.Desc.stringValue = " | ".join(ThisPaper.Authors.map{$0.description})
        
        return cell
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool
    {
        let Files = info.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as! [String]
        for f in Files
        {
            if f.pathExtension.lowercaseString == "bib"
            {
                addBib(f)
            }
        }
        // Scroll to the end to see our newly added paper~~
        tableView.scrollRowToVisible(count(Papers) - 1)
        return true
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation
    {
        // tableView.setDropRow(count(Papers)-1, dropOperation: dropOperation)
        let Board = info.draggingPasteboard()
        if contains(Board.types as! [String], NSFilenamesPboardType)
        { // We are indeed dragging some files
            let Files: [String]? = Board.propertyListForType(NSFilenamesPboardType) as? [String]
            if Files != nil
            {
                // We need to test if any of these files is a bib file.
                for f in Files!
                {
                    if f.pathExtension.lowercaseString == "bib"
                    {
                        // Found a bib file!  The dragging can be dropped.
                        return .Copy
                    }
                }
            }
        }
        return .None
    }
}