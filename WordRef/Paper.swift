//
//  Paper.swift
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

import Foundation

//: ## Bib file processing

//: First, some utility functions.  Really if I'm using python, all these do is s[a:b]...
func subString(s: String, start: Int, end: Int) -> String
    // Basically this just does s[start:end]...
{
    let ResultRange = Range(start: advance(s.startIndex, start),
        end: advance(s.startIndex, end))
    return s.substringWithRange(ResultRange)
}

func subString(s: String, r: NSRange?) -> String
    // Basically this just does s[start:end]...
{
    if r == nil
    {
        return ""
    }
    let Start: Int = r!.location
    let End: Int = r!.location + r!.length
    return subString(s, Start, End)
}

//: Remove curly brackets from a string, except `\{` and `\}`.
func removeBrackets(s: String) -> String
{
    var Str = NSMutableString()
    Str.setString(s)
    var Ptn = NSRegularExpression(pattern: "([^\\\\])\\{+", options: nil, error: nil)!
    Ptn.replaceMatchesInString(Str , options: nil, range: NSMakeRange(0, Str.length), withTemplate: "$1")
    Ptn = NSRegularExpression(pattern: "^\\{", options: nil, error: nil)!
    Ptn.replaceMatchesInString(Str , options: nil, range: NSMakeRange(0, Str.length), withTemplate: "")
    Ptn = NSRegularExpression(pattern: "([^\\\\])\\}+", options: nil, error: nil)!
    Ptn.replaceMatchesInString(Str , options: nil, range: NSMakeRange(0, Str.length), withTemplate: "$1")
    
    return Str as String
}

//: Split the bib file into seperate entries.
func bibSplit(s: String) -> [String]
{
    var First = true
    var Entries: [String] = []
    var StartPos: Int = 0
    let Ptn = NSRegularExpression(pattern: "^\\S*@.+\\S*\\{.*$", options:
        NSRegularExpressionOptions.AnchorsMatchLines, error: nil)!
    //: Becareful about unicodes! `count(s)` and `count(s.utf16)` may be different. It seems `NSRegularExpression` deals with `NSString` internally, so `s` is converted to `NSString` first.  And `NSStrin`g counts number of characters, not bytes.
    Ptn.enumerateMatchesInString(s, options: NSMatchingOptions(0), range: NSMakeRange(0, count(s.utf16)), usingBlock:
        {
            (Result, _, _) in
            if First
            {
                First = false
                StartPos = Result.range.location
            }
            else
            {
                let EndPos = Result.range.location
                Entries.append(((s as NSString).substringWithRange(NSMakeRange(StartPos, EndPos - StartPos))) as String)
                // println("\(StartPos), \(EndPos)")
                StartPos = EndPos
            }
    })
    Entries.append(((s as NSString).substringWithRange(NSMakeRange(StartPos, count(s.utf16) - StartPos))) as String)
    return Entries
}

//: Converted an bib entry into a dictionary.
func bibEntry2Dict(entry: String) -> [String: String]
{
    var Error: NSError?
    // let Entry: NSString = entry as NSString
    var Content = Dictionary<String, String>()
    //: First, find the tag
    let HeadPtn = NSRegularExpression(pattern: "^@(\\S+)\\s*\\{\\s*(\\S+)\\s*,\\s*$", options:
        NSRegularExpressionOptions.AnchorsMatchLines, error: &Error)!
    let HeadResult = HeadPtn.firstMatchInString(entry, options: nil, range: NSMakeRange(0, count(entry.utf16)))
    Content["kind"] = subString(entry, HeadResult?.rangeAtIndex(1))
    Content["tag"] = subString(entry, HeadResult?.rangeAtIndex(2))
    
    //: Then other metadata.
    var Lines = split(entry) {$0 == "\n"}
    // The ",?" doesn't seem to do anything...
    let Ptn = NSRegularExpression(pattern: "^(\\S+)\\s*=\\s*(.+),?$", options:
        NSRegularExpressionOptions.AnchorsMatchLines, error: &Error)!
    for line in Lines
    {
        let Line: String = line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        Ptn.enumerateMatchesInString(Line, options: NSMatchingOptions(0), range: NSMakeRange(0, count(Line)), usingBlock:
            {
                (Result, _, _) in
                let Key = subString(Line, Result.rangeAtIndex(1))
                let ValueWithComma = removeBrackets(subString(Line, Result.rangeAtIndex(2)))
                // Remove trailing ","
                let Value = ValueWithComma.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ","))
                Content[Key] = Value
        })
    }
    return Content
}

//: A class to store names.  Didn't expect it to be so long...
class Name: Printable
{
    var First: String = ""
    var Last: String = ""
    class func fromStr(s: String) -> Name
    {
        var n = Name()
        if(s == "")
        {
            return n
        }
        
        if s.rangeOfString(",") == nil
        {
            // First Last
            var Sep = s.rangeOfString(" ", options:NSStringCompareOptions.BackwardsSearch)!
            let LastRange = Range(start: advance(Sep.startIndex,1),
                end: s.endIndex)
            n.Last = s.substringWithRange(LastRange)
            let FirstRange = Range(start: s.startIndex,
                end: Sep.startIndex)
            n.First = s.substringWithRange(FirstRange)
        }
        else
        {
            // Last, First
            var Sep = s.rangeOfString(",", options:NSStringCompareOptions.BackwardsSearch)!
            let LastRange = Range(start: advance(Sep.startIndex,1),
                end: s.endIndex)
            n.First = s.substringWithRange(LastRange).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let FirstRange = Range(start: s.startIndex,
                end: Sep.startIndex)
            n.Last = s.substringWithRange(FirstRange)
        }
        return n
    }
    
    var description: String
        {
            return "\(First) \(Last)"
    }
    
    func toXmlNode() -> NSXMLNode
    {
        var NodeLast: NSXMLNode = NSXMLNode.elementWithName("b:Last", stringValue: Last)! as! NSXMLNode
        var NodeFirst: NSXMLNode = NSXMLNode.elementWithName("b:First", stringValue: First) as! NSXMLNode
        return NSXMLNode.elementWithName("b:Person", children: [NodeLast, NodeFirst], attributes: nil) as! NSXMLNode
    }
}

//: Convert a string to a list of names.
func str2Names(s: String) -> [Name]
{
    let Entries = s.componentsSeparatedByString(" and ")
    var Names: [Name] = []
    for entry in Entries
    {
        var Entry = entry.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        Names.append(Name.fromStr(Entry))
    }
    return Names
}

func xmlNode2Names(node: NSXMLNode) -> [Name]
{
    var Names: [Name] = []
    if node.localName! == "Person"
    {
        var CurrentName = Name()
        for Kid in node.children!
        {
            switch Kid.localName!!
            {
            case "First":
                CurrentName.First = Kid.stringValue
            case "Last":
                CurrentName.Last = Kid.stringValue
            default:
                break
            }
        }
        Names.append(CurrentName)
    }
    else if node.childCount == 0
    {
        return Names
    }
    else
    {
        for Kid in node.children!
        {
            Names += xmlNode2Names(Kid as! NSXMLNode)
        }
    }
    return Names
}

//: Class that store info of a paper.
class Paper: Printable, Equatable
{
    var Tag: String = ""
    var Volume: String? = ""
    var Url: String? = ""
    var Doi: String? = ""
    var Abstract: String? = ""
    var Number: String? = ""
    var Page: String? = ""
    var Date: String = ""
    var Authors: [Name] = []
    var Journal: String? = ""
    var Title: String = ""
    var Kind: String = ""
    var Issue: String? = ""
    var UUID: String? = ""
    
    class func fromBibStr(str: String) -> Paper?
    {
        var ThisPaper: Paper = Paper()
        let Data = bibEntry2Dict(str)
        ThisPaper.Volume = Data["volume"]
        ThisPaper.Url = Data["url"]
        ThisPaper.Doi = Data["doi"]
        ThisPaper.Abstract = Data["abstract"]
        ThisPaper.Number = Data["number"]
        ThisPaper.Page = Data["pages"]
        ThisPaper.Journal = Data["journal"]
        if Data["author"] == nil
        {
            return nil
        }
        ThisPaper.Authors = str2Names(Data["author"]!)
        if Data["title"] == nil
        {
            return nil
        }
        ThisPaper.Title = Data["title"]!
        if Data["year"] == nil
        {
            return nil
        }
        ThisPaper.Date = Data["year"]!
        if Data["tag"] == nil
        {
            return nil
        }
        ThisPaper.Tag = Data["tag"]!
        if Data["kind"] == nil
        {
            return nil
        }
        ThisPaper.Kind = Data["kind"]!
        return ThisPaper
    }
    
    class func fromXmlNode(node: NSXMLNode) -> Paper
    {
        var ThisPaper: Paper = Paper()
        for Kid in node.children!
        {
            let Value:String = Kid.stringValue
            switch Kid.localName!!
            {
            case "Tag":
                ThisPaper.Tag = Value
            case "SourceType":
                ThisPaper.Kind = Value
            case "JournalName":
                ThisPaper.Journal = Value
            case "Title":
                ThisPaper.Title = Value
            case "Volume":
                ThisPaper.Volume = Value
            case "Issue":
                ThisPaper.Issue = Value
            case "Year":
                ThisPaper.Date = Value
            case "Pages":
                ThisPaper.Page = Value
            case "Guid":
                ThisPaper.UUID = removeBrackets(Value)
            case "Author":
                ThisPaper.Authors = xmlNode2Names(Kid as! NSXMLNode)
            default:
                break
            }
        }
        return ThisPaper
    }
    
    func toXmlNode() -> NSXMLNode
    {
        var Kids: [NSXMLNode] = []
        
        var ThisKid = NSXMLNode.elementWithName("b:Tag") as! NSXMLNode
        ThisKid.setStringValue(Tag, resolvingEntities: false)
        Kids.append(ThisKid)
        
        ThisKid = NSXMLNode.elementWithName("b:Title") as! NSXMLNode
        ThisKid.setStringValue(Title, resolvingEntities: false)
        Kids.append(ThisKid)
        
        if((Journal) != nil && Journal != "")
        {
            ThisKid = NSXMLNode.elementWithName("b:JournalName") as! NSXMLNode
            ThisKid.setStringValue(Journal!, resolvingEntities: false)
            Kids.append(ThisKid)
        }
        
        ThisKid = NSXMLNode.elementWithName("b:Year") as! NSXMLNode
        ThisKid.setStringValue(Date, resolvingEntities: false)
        Kids.append(ThisKid)
        
        if((Volume) != nil && Volume != "")
        {
            ThisKid = NSXMLNode.elementWithName("b:Volume") as! NSXMLNode
            ThisKid.setStringValue(Volume!, resolvingEntities: false)
            Kids.append(ThisKid)
        }
        
        if((Issue) != nil && Issue != "")
        {
            ThisKid = NSXMLNode.elementWithName("b:Issue") as! NSXMLNode
            ThisKid.setStringValue(Issue!, resolvingEntities: false)
            Kids.append(ThisKid)
        }
        
        //: I'm assuming issue is the same thing as number.
        if((Number) != nil && Number != "")
        {
            ThisKid = NSXMLNode.elementWithName("b:Issue") as! NSXMLNode
            ThisKid.setStringValue(Number!, resolvingEntities: false)
            Kids.append(ThisKid)
        }
        
        if((Page) != nil && Page != "")
        {
            ThisKid = NSXMLNode.elementWithName("b:Pages") as! NSXMLNode
            ThisKid.setStringValue(Page!, resolvingEntities: false)
            Kids.append(ThisKid)
        }
        
        ThisKid = NSXMLNode.elementWithName("b:Guid") as! NSXMLNode
        if(UUID == nil || UUID == "")
        {
            UUID = NSUUID().UUIDString
        }
        ThisKid.setStringValue("{" + UUID! + "}", resolvingEntities: false)
        Kids.append(ThisKid)
        
        ThisKid = NSXMLNode.elementWithName("b:SourceType") as! NSXMLNode
        if Kind == "article"
        {
            var WordKind = "JournalArticle"
            ThisKid.setStringValue(WordKind, resolvingEntities: false)
        }
        Kids.append(ThisKid)
        
        //: Now deal with authors.  The xml structure is like Author -> Author -> NameList -> [Person, ...].
        let NameListNode = NSXMLNode.elementWithName("b:NameList", children: Authors.map({$0.toXmlNode()}), attributes: nil) as! NSXMLNode
        let AuthorNode1 = NSXMLNode.elementWithName("b:Author", children: [NameListNode], attributes: nil) as! NSXMLNode
        let AuthorNode2 = NSXMLNode.elementWithName("b:Author", children: [AuthorNode1], attributes: nil) as! NSXMLNode
        Kids.append(AuthorNode2)
        
        var Node: NSXMLNode = NSXMLNode.elementWithName("b:Source", children: Kids, attributes: nil) as! NSXMLNode
        
        return Node
    }
    
    var description: String
    {
        return Title
    }
}

func ==(lhs: Paper, rhs: Paper) -> Bool
{
    return (lhs.Date == rhs.Date && lhs.Title == rhs.Title)
}

//: And finally, convert a bib file (as a string) to papers!!
func bib2Papers(s: String) -> [Paper?]
{
    return bibSplit(s).map(Paper.fromBibStr)
}

func xml2Papers(url: NSURL) -> [Paper]
{
    var Papers: [Paper] = []
    var Error: NSError?
    var Xml: NSXMLDocument? = NSXMLDocument(contentsOfURL: url, options: 0, error: &Error)
    if Xml == nil
    {
        println("Could not open \(url)")
        return Papers
    }
    var Root: NSXMLElement = Xml!.rootElement()!
    
    for Source in Root.children!
    {
        if Source.localName == "Source"
        {
            Papers.append(Paper.fromXmlNode(Source as! NSXMLNode))
        }
    }
    println("Found \(count(Papers)) papers")
    return Papers
}

func xml2Papers(filename: String) -> [Paper]
{
    let f: NSURL = NSURL(fileURLWithPath: filename)!
    return xml2Papers(f)
}

func papers2Xml(papers: [Paper]) -> NSData
{
    let Kids: [NSXMLNode] = papers.map({$0.toXmlNode()})
    var Root = NSXMLElement(name: "b:Sources")
    let RootAttr1 = NSXMLNode.attributeWithName("SelectedStyle", stringValue: "") as! NSXMLNode
    let RootAttr2 = NSXMLNode.attributeWithName("xmlns:b", stringValue: "http://schemas.openxmlformats.org/officeDocument/2006/bibliography") as! NSXMLNode
    let RootAttr3 = NSXMLNode.attributeWithName("xmlns", stringValue: "http://schemas.openxmlformats.org/officeDocument/2006/bibliography") as! NSXMLNode
    Root.setChildren(Kids)
    Root.attributes = [RootAttr1, RootAttr2, RootAttr3]
    var Doc = NSXMLDocument(rootElement: Root)
    Doc.version = "1.0"
    return Doc.XMLData
}