//
//  PhotoOperations.swift
//  ClassicPhotosClone
//
//  Created by mainul on 8/8/17.
//  Copyright © 2017 mainul. All rights reserved.
//
import UIKit

enum PhotoRecordState {
    case new, filtered, failed, downloaded
}

class PhotoRecord {
    let name: String
    let url: URL
    var state = PhotoRecordState.new
    var image = UIImage(named: "Placeholder")
    
    required init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}