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

class PendingOperations {
    lazy var downloadsInProgress = [IndexPath: Operation]()
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var filtrationsInProgress = [IndexPath: Operation]()
    lazy var filtrationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

class ImageDownloader: Operation {
    let photoRecord: PhotoRecord
    
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }

    override func main() {
        if self.isCancelled {
            return
        }

        let imageData = NSData(contentsOf: self.photoRecord.url)

        if self.isCancelled {
            return
        }

        if imageData != nil {
            self.photoRecord.image = UIImage(data: imageData! as Data)
            self.photoRecord.state = .downloaded
        }
        else
        {
            self.photoRecord.state = .failed
            self.photoRecord.image = UIImage(named: "Failed")
        }
    }
}

class ImageFiltration: Operation {
    let photoRecord: PhotoRecord
    
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main () {
        if self.isCancelled {
            return
        }
        
        if self.photoRecord.state != .downloaded {
            return
        }
        
        if let filteredImage = self.applySepiaFilter(self.photoRecord.image!) {
            self.photoRecord.image = filteredImage
            self.photoRecord.state = .filtered
        }
    }
    
    func applySepiaFilter(_ imageToFilter: UIImage) -> UIImage? {
        let inputImage = CIImage(data: UIImagePNGRepresentation(imageToFilter)!)
        
        if self.isCancelled { return nil }
        
        let context = CIContext(options: nil)
        let filter = CIFilter(name: "CISepiaTone")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(0.8, forKey: kCIInputIntensityKey)
        
        let outputImage = filter?.outputImage
        
        if self.isCancelled { return nil }

        
        let outImage = context.createCGImage(outputImage!, from: (outputImage?.extent)!)
        return UIImage(cgImage: outImage!)

    }
}
