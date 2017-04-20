//
//  AlbumViewController.swift
//  TeamTalkSwift
//
//  Created by tom555cat on 2017/3/28.
//  Copyright © 2017年 Hello World Corporation. All rights reserved.
//

import UIKit
import Photos

class AlbumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var albumsArray: [PHAssetCollection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tableView = UITableView.init(frame: self.view.frame, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        // 读取相册的内容并tableView reload 
        self.getAlbumsArray()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAlbumsArray() {
        // 胶卷相册
        let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil).lastObject!
        self.albumsArray.append(smartAlbum)
        
        // 剩余相册
        let restAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        restAlbums.enumerateObjects({ (album: PHAssetCollection, index: Int, ptr: UnsafeMutablePointer<ObjCBool>) in
            self.albumsArray.append(album)
        })
    }
    
    //MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albumsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "DDAlbumsCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: identifier)
        }
        let name = self.albumsArray[indexPath.row].localizedLocationNames[0]
        
        weak var weakCell = cell
        let assets = PHAsset.fetchAssets(in: self.albumsArray[indexPath.row], options: nil)
        if assets.count > 0 {
            let poster = assets[0]
            PHImageManager.default().requestImage(for: assets[0], targetSize: CGSize.init(width: poster.pixelWidth, height: poster.pixelHeight), contentMode: .default, options: nil, resultHandler: { (result: UIImage?, info: [AnyHashable : Any]?) in
                weakCell?.imageView?.image = result
            })
        }
        
        cell?.textLabel?.text = String.init(format: "%@ ( %ld )", name, self.albumsArray[indexPath.row].estimatedAssetCount)
        cell?.textLabel?.textColor = RGB(145, 145, 145)
        cell?.textLabel?.highlightedTextColor = UIColor.white
        cell?.accessoryType = .disclosureIndicator
        let view = UIView.init(frame: (cell?.frame)!)
        view.backgroundColor = RGB(246, 93, 137)
        cell?.selectedBackgroundView = view
        
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 需要detail.............
    }
}
