//
//  PaperCellView.swift
//  WordRef
//
//  Created by Darksair Sun on 4/24/15.
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

class PaperCellView: NSView, NSDraggingDestination
{

    @IBOutlet weak var Title: NSTextField!
    @IBOutlet weak var Desc: NSTextField!
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
//    override init(frame frameRect: NSRect)
//    {
//        super.init(frame: frameRect)
//        self.registerForDraggedTypes([NSFilenamesPboardType])
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }    
}
