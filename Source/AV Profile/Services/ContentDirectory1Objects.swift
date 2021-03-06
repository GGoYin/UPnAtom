//
//  ContentDirectory1Object.swift
//
//  Copyright (c) 2015 David Robles
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import Ono

// MARK: ContentDirectory1Object

@objc public class ContentDirectory1Object {
    public let objectID: String
    public let parentID: String
    public let title: String
    public let rawType: String
    public let albumArtURL: NSURL?
    
    init?(xmlElement: ONOXMLElement) {
        if let objectID = xmlElement.valueForAttribute("id") as? String,
            parentID = xmlElement.valueForAttribute("parentID") as? String,
            title = xmlElement.firstChildWithTag("title").stringValue(),
            rawType = xmlElement.firstChildWithTag("class").stringValue() {
                self.objectID = objectID
                self.parentID = parentID
                self.title = title
                self.rawType = rawType
                
                if let albumArtURLString = xmlElement.firstChildWithTag("albumArtURI")?.stringValue() {
                    self.albumArtURL = NSURL(string: albumArtURLString)
                }
                else { albumArtURL = nil }
        }
        else {
            /// TODO: Remove default initializations to simply return nil, see Github issue #11
            objectID = ""
            parentID = ""
            title = ""
            rawType = ""
            albumArtURL = nil
            return nil
        }
    }
}

extension ContentDirectory1Object: ExtendedPrintable {
    public var className: String { return "ContentDirectory1Object" }
    public var description: String {
        var properties = PropertyPrinter()
        properties.add("id", property: objectID)
        properties.add("parentID", property: parentID)
        properties.add("title", property: title)
        properties.add("class", property: rawType)
        properties.add("albumArtURI", property: albumArtURL?.absoluteString)
        return properties.description
    }
}

// MARK: - ContentDirectory1Container

public class ContentDirectory1Container: ContentDirectory1Object {
    public let childCount: Int?
    
    override init?(xmlElement: ONOXMLElement) {
        self.childCount = (xmlElement.valueForAttribute("childCount") as? String)?.toInt() ?? nil
        
        super.init(xmlElement: xmlElement)
    }
}

/// for objective-c type checking
extension ContentDirectory1Object {
    public func isContentDirectory1Container() -> Bool {
        return self is ContentDirectory1Container
    }
}

extension ContentDirectory1Container: ExtendedPrintable {
    override public var className: String { return "ContentDirectory1Container" }
    override public var description: String {
        var properties = PropertyPrinter()
        properties.add(super.className, property: super.description)
        properties.add("childCount", property: "\(childCount)")
        return properties.description
    }
}

// MARK: - ContentDirectory1Item

public class ContentDirectory1Item: ContentDirectory1Object {
    public let resourceURL: NSURL!
    
    override init?(xmlElement: ONOXMLElement) {
        /// TODO: Return nil immediately instead of waiting, see Github issue #11
        if let resourceURLString = xmlElement.firstChildWithTag("res").stringValue() {
            resourceURL = NSURL(string: resourceURLString)
        }
        else { resourceURL = nil }
        
        super.init(xmlElement: xmlElement)
        
        if resourceURL == nil {
            return nil
        }
    }
}

/// for objective-c type checking
extension ContentDirectory1Object {
    public func isContentDirectory1Item() -> Bool {
        return self is ContentDirectory1Item
    }
}

extension ContentDirectory1Item: ExtendedPrintable {
    override public var className: String { return "ContentDirectory1Item" }
    override public var description: String {
        var properties = PropertyPrinter()
        properties.add(super.className, property: super.description)
        properties.add("resourceURL", property: resourceURL?.absoluteString)
        return properties.description
    }
}

// MARK: - ContentDirectory1VideoItem

public class ContentDirectory1VideoItem: ContentDirectory1Item {
    public let bitrate: Int?
    public let duration: NSTimeInterval?
    public let audioChannelCount: Int?
    public let protocolInfo: String?
    public let resolution: CGSize?
    public let sampleFrequency: Int?
    public let size: Int?
    
    override init?(xmlElement: ONOXMLElement) {
        bitrate = (xmlElement.firstChildWithTag("res").valueForAttribute("bitrate") as? String)?.toInt()
        
        if let durationString = xmlElement.firstChildWithTag("res").valueForAttribute("duration") as? String {
            let durationComponents = durationString.componentsSeparatedByString(":")
            var count: Double = 0
            var duration: Double = 0
            for durationComponent in durationComponents.reverse() {
                duration += (durationComponent as NSString).doubleValue * pow(60, count)
                count++
            }
            
            self.duration = NSTimeInterval(duration)
        }
        else { self.duration = nil }
        
        audioChannelCount = (xmlElement.firstChildWithTag("res").valueForAttribute("nrAudioChannels") as? String)?.toInt()
        
        protocolInfo = xmlElement.firstChildWithTag("res").valueForAttribute("protocolInfo") as? String
        
        if let resolutionComponents = (xmlElement.firstChildWithTag("res").valueForAttribute("resolution") as? String)?.componentsSeparatedByString("x") where count(resolutionComponents) == 2 {
            resolution = CGSize(width: resolutionComponents[0].toInt()!, height: resolutionComponents[1].toInt()!)
        }
        else { resolution = nil }
        
        sampleFrequency = (xmlElement.firstChildWithTag("res").valueForAttribute("sampleFrequency") as? String)?.toInt()
        
        size = (xmlElement.firstChildWithTag("res").valueForAttribute("size") as? String)?.toInt()
        
        super.init(xmlElement: xmlElement)
    }
}

/// for objective-c type checking
extension ContentDirectory1Object {
    public func isContentDirectory1VideoItem() -> Bool {
        return self is ContentDirectory1VideoItem
    }
}

extension ContentDirectory1VideoItem: ExtendedPrintable {
    override public var className: String { return "ContentDirectory1VideoItem" }
    override public var description: String {
        var properties = PropertyPrinter()
        properties.add(super.className, property: super.description)
        properties.add("bitrate", property: "\(bitrate)")
        properties.add("duration", property: "\(duration)")
        properties.add("audioChannelCount", property: "\(audioChannelCount)")
        properties.add("protocolInfo", property: protocolInfo)
        properties.add("resolution", property: "\(resolution?.width)x\(resolution?.height)")
        properties.add("sampleFrequency", property: "\(sampleFrequency)")
        properties.add("size", property: "\(size)")
        return properties.description
    }
}
