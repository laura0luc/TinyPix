//
//  TinyPixDocument.swift
//  TinyPix
//
//  Created by LAURA LUCRECIA SANCHEZ PADILLA on 16/10/15.
//  Copyright © 2015 LAURA LUCRECIA SANCHEZ PADILLA. All rights reserved.
//

import UIKit

class TinyPixDocument: UIDocument {
    private var bitmap: [UInt8]!
    
    override init(fileURL url: NSURL) {
        bitmap = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80]
        super.init(fileURL: url)
    }
    
    override func contentsForType(typeName: String) throws -> AnyObject {
        print("Saving document to URL \(fileURL)")
        let bitmapData = NSData(bytes: bitmap, length: bitmap.count)
        return bitmapData
    }
    
    override func loadFromContents(contents: AnyObject, ofType typeName: String?) throws {
        print("Loding document from URL \(fileURL)")
        let bitmapData = contents as! NSData
        bitmapData.getBytes(UnsafeMutablePointer<UInt8>(bitmap), length: bitmap.count)
    }
    
    func stateAt(row: Int, column: Int) -> Bool{
        let rowByte = bitmap[row]
        let result = UInt8(1 << column) & rowByte
        return result != 0
    }
    
    func setState(state : Bool, atRow row : Int, column: Int) {
        var rowByte = bitmap[row]
        if state{
            rowByte |= UInt8(1 << column)
        }else{
            rowByte &= ~UInt8(1 << column)
        }
        bitmap[row] = rowByte
    }
    
    func toggleStateAt(row: Int, column: Int){
        let state = stateAt(row, column: column)
        setState(!state, atRow: row, column: column)
    }
    
    
}
