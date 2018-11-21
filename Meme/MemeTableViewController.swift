//
//  MemeTableViewController.swift
//  Meme
//
//  Created by Malik Basalamah on 13/03/1440 AH.
//  Copyright © 1440 Malik Basalamah. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController:UITableViewController{
    
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    let Cellidentifier:String  = "TableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        tableView.reloadData()
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    
    }
    
    
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cellidentifier, for: indexPath) as! MemeTableViewCell
        let meme = self.memes[(indexPath as NSIndexPath).row]        
        cell.tableLabel.text = meme.getText(top: meme.topTextField!, bottom: meme.bottomTextField!)
        cell.tableImageView.image = meme.memedImage
        return cell
    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! MemeDetailViewController
        
        let meme = memes[(indexPath as NSIndexPath).row]
        
        nextVC.memes = meme
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    

    
}
