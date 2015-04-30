//
//  WindowController.swift
//  WordRef
//
//  Created by Darksair Sun on 4/26/15.
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

class WindowController: NSWindowController {

    @IBOutlet weak var BtnAdd: NSToolbarItem!
    @IBOutlet weak var BtnDelete: NSToolbarItem!
    @IBOutlet weak var BtnSave: NSToolbarItem!
    
    var PaperController: PaperViewController!
    
    @IBAction func onClickAdd(sender: AnyObject)
    {
        var Panel = NSOpenPanel()
        Panel.canChooseDirectories = false
        Panel.allowsMultipleSelection = true
        Panel.message = "Import bib file"
        Panel.resolvesAliases = true
        Panel.allowedFileTypes = ["bib"]

        Panel.beginSheetModalForWindow(window!, completionHandler: { (handler: Int) -> Void in
            if handler == NSFileHandlingPanelOKButton
            {
                for url in Panel.URLs
                {
                    self.PaperController.addBib((url as! NSURL).path!)
                }
            }
        })
    }
    @IBAction func onClickSave(sender: AnyObject)
    {
        PaperController.save()
    }
    @IBAction func onClickDelete(sender: AnyObject)
    {
        var Indices: [Int] = []
        PaperController.tableView.selectedRowIndexes.enumerateIndexesUsingBlock({ (index:Int, _) in
            Indices.append(index)})
        PaperController.deletePapers(Indices)
    }
    override func windowDidLoad() {
        super.windowDidLoad()
    
        window?.titleVisibility = .Hidden
        let PaperView: NSTableView = window!.contentView.viewWithTag(1) as! NSTableView
        PaperController = PaperView.delegate() as! PaperViewController
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
}
