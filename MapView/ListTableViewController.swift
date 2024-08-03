//
//  ListTableViewController.swift
//  MapView - miniproject
//
//  Created by Ruslan Yelguldinov on 27.07.2024.
//

import UIKit

class ListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    var posterImageArray = [UIImage.resort1, UIImage.resort2, UIImage.resort3, UIImage.resort4, UIImage.resort5]
    var titleArray = ["Resort #1 name, Colambia", "Resort #2 name, Turkey", "Resort #3 name, Hawaii", "Resort #4 name, Thailand", "Resort #5 name, Shri-Lanka"]
    var priceArray = ["$ 2 400 at night", "$ 3 000 at day", "$ 700 at night", "$ 5 000 at whole day", "$ 4 600 at day"]
    
    lazy var resortsArray:[Resort] = [resort1, resort2, resort3, resort4, resort5]
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        
        let posterImageView = cell.viewWithTag(101) as? UIImageView
        posterImageView?.image = posterImageArray[indexPath.row]
        
        let titleLabel = cell.viewWithTag(102) as! UILabel
        titleLabel.text = titleArray[indexPath.row]
        
        let priceLabel = cell.viewWithTag(103) as! UILabel
        priceLabel.text = priceArray[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 380
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? UIViewController else {
//            return print("NO VC here!")
//        }
//        
//        navigationController?.show(vc, sender: self)
        
        guard let mapViewVC = storyboard?.instantiateViewController(withIdentifier: "MapViewVC") as? MapViewViewController else {
                return
            }
        
        performSegue(withIdentifier: "showDetailSegue", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedResort = resortsArray[indexPath.row]
                let detailVC = segue.destination as! DetailViewController
                detailVC.resort = selectedResort
                
            }
        }
    }
    
    
    
}
