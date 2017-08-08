//
//  ListViewController.swift
//  ClassicPhotosClone
//
//  Created by mainul on 8/8/17.
//  Copyright © 2017 mainul. All rights reserved.
//

import UIKit
import CoreImage

let dataSourceURL = URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")

class ListViewController: UITableViewController {

    lazy var photos = NSDictionary(contentsOf: dataSourceURL!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Classic Photos"
        print(photos!.description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos!.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        let rowKey = photos?.allKeys[indexPath.row] as! String
        
        var image: UIImage?
        if let imageURL = URL(string: photos?.value(forKey: rowKey) as! String),
            let imageData = NSData(contentsOf: imageURL) {
            
            let unfilteredImage = UIImage(data: imageData as Data)
            image = self.applySepiaFilter(image: unfilteredImage!)
        }
        
        // Configure the cell...
        cell.textLabel?.text = rowKey
        if image != nil {
            cell.imageView?.image = image!
        }
        
        return cell
    }

    func applySepiaFilter(image: UIImage) -> UIImage? {
        let inputImage = CIImage(data: UIImagePNGRepresentation(image)!)
        let context = CIContext(options: nil)
        let filter = CIFilter(name: "CISepiaTone")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(0.8, forKey: kCIInputIntensityKey)
        if let outputImage = filter?.outputImage {
            let outImage = context.createCGImage(outputImage, from: outputImage.extent)
            return UIImage(cgImage: outImage!)
        }
        return nil
    }

}
