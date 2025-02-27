//
//  ViewLogViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 15/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import ProgressHUD
import Nuke

class ViewLogViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fnet.clean()
        if NetworkChecker.isConnectedToInternet {
           ProgressHUD.show("Loading log times...")
            fb.loadLogTimes { (result) in
                attendList = result
                self.tableView.delegate = self
                self.tableView.dataSource = self
                ProgressHUD.dismiss()
            }
        }
        else {
            showDialog(message: "You have not connected to internet.")
        }

    }
    

}
extension ViewLogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        attendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") as! LogTableViewCell
        if let url = URL(string: attendList[indexPath.row].imageURL) {
            cell.imgView.loadImage(with: url)
        }
        cell.nameLabel.text = attendList[indexPath.row].name
        cell.timeLabel.text = attendList[indexPath.row].time
        cell.confidenceLabel.text = "" //attendList[indexPath.row].confidence
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

extension UIImageView {
    @discardableResult
    public func loadImage(
        with request: ImageRequestConvertible?,
        options: ImageLoadingOptions = ImageLoadingOptions.shared,
        progress: ((_ response: ImageResponse?, _ completed: Int64, _ total: Int64) -> Void)? = nil,
        completion: ((_ result: Result<ImageResponse, ImagePipeline.Error>) -> Void)? = nil
    ) -> ImageTask? {
        return Nuke.loadImage(with: request, options: options, into: self, progress: progress, completion: completion)
    }
}
