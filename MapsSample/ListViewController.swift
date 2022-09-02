//
//  ListViewController.swift
//  MapsSample
//
//  Created by Hasan Uysal on 2.09.2022.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var nameArr = [String]()
    var idArr = [UUID]()
    
    var sendName = ""
    var sendId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBtn))
        
        getDatas()
        
    }
    
    func getDatas(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            // if there is at least 1 data
            if results.count > 0 {
                
                nameArr.removeAll(keepingCapacity: false)
                idArr.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        nameArr.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        idArr.append(id)
                    }
                }
                
                tableView.reloadData()
            }
        } catch {
            print("error")
        }
        
    }
    
    @objc func addBtn(){
        sendName = ""
        performSegue(withIdentifier: "toMapVC", sender: nil)
        
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        sendName = nameArr[indexPath.row]
        sendId = idArr[indexPath.row]
        performSegue(withIdentifier: "toMapVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVC" {
            
            let destinationVC = segue.destination as! MapViewController
            destinationVC.receiveName = sendName
            destinationVC.recieveId = sendId
            
        }
    }


}
