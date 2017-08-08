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

    var photos = [PhotoRecord]()
    let pendingOperations = PendingOperations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Classic Photos"
        fetchPhotoDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchPhotoDetails() {
        
        let request = URLRequest(url: dataSourceURL!)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let session: URLSession = URLSession.shared
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            
            var datasourceDictionary: Dictionary <String, String>?
            
            do {
                datasourceDictionary = try PropertyListSerialization.propertyList(from: data!, options: PropertyListSerialization.MutabilityOptions(), format: nil) as? Dictionary
            } catch {
                print("Something went wrong!")
            }
            
            for(key, value) in datasourceDictionary! {
                
                let name = key
                let url = URL(string: value )
                
                print("\(name) ==> \(String(describing: url?.description))")
                if url != nil {
                    let photoRecord = PhotoRecord(name: name, url: url!)
                    self.photos.append(photoRecord)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        task.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            cell.accessoryView = indicator
        }
        
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        
        let photoDetails = photos[indexPath.row]
        
        cell.textLabel?.text = photoDetails.name
        cell.imageView?.image = photoDetails.image
        
        switch photoDetails.state {
        case .filtered:
            indicator.stopAnimating()
        case .failed:
            indicator.stopAnimating()
            cell.textLabel?.text = "Failed to load"
        case .new, .downloaded:
            indicator.startAnimating()
            self.startOperationsForPhotoRecord(photoDetails: photoDetails, indexPath: indexPath)
        }
        
        return cell
    }

    func startOperationsForPhotoRecord(photoDetails: PhotoRecord, indexPath: IndexPath){
        switch photoDetails.state {
        case .new:
            startDownloadForRecord(photoDetails, indexPath: indexPath)
        case .downloaded:
            startFiltrationForRecord(photoDetails, indexPath: indexPath)
        default:
            NSLog("do nothing")
        }
    }
    
    func startDownloadForRecord(_ photoDetails: PhotoRecord, indexPath: IndexPath) {
        if let _ = pendingOperations.downloadsInProgress[indexPath] {
            return
        }
        
        let downloader = ImageDownloader(photoRecord: photoDetails)
        
        downloader.completionBlock = {
            if downloader.isCancelled { return }
            
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func startFiltrationForRecord(_ photoDetails: PhotoRecord, indexPath: IndexPath) {
        if let _ = pendingOperations.filtrationsInProgress[indexPath]{
            return
        }
        
        let filterer = ImageFiltration(photoRecord: photoDetails)
        filterer.completionBlock = {
            if filterer.isCancelled { return }
            
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        pendingOperations.filtrationsInProgress[indexPath] = filterer
        pendingOperations.filtrationQueue.addOperation(filterer)
    }
    
}
