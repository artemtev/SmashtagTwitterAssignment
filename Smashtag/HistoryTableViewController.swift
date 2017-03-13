//
//  HistoryTableViewController.swift
//  Smashtag
//
//  Created by Admin on 13.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {

    
    var historySearches: [String] {
        return HistoryDefaults.searches
    }
    
    
    var container: NSPersistentContainer! =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var moc: NSManagedObjectContext {
        return container.viewContext
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historySearches.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.HistoryCellIdentifier, for: indexPath)

        cell.textLabel?.text = historySearches[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let term = historySearches[indexPath.row]
            moc.perform({
                let request: NSFetchRequest<SearchTerm> = SearchTerm.fetchRequest()
                request.predicate = NSPredicate(format: "term = %@", term)
                if let results = try? self.moc.fetch(request),
                    let searchTerm = results.first {
                    self.moc.delete(searchTerm)
                    do {
                        try self.moc.save()
                        HistoryDefaults.removeAt(index: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    } catch {
                        fatalError("Saving error main managed object context \(error)")
                    }
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier , identifier == Identifiers.TweetsSegueIdentifier,
            let cell = sender as? UITableViewCell,
            let ttvc = segue.destination as? TweetsTableViewController
        {
            ttvc.searchText = cell.textLabel?.text
            
        } else  if let identifier = segue.identifier ,
            identifier == Identifiers.PopularSegueIdentifier,
            let cell = sender as? UITableViewCell,
            let tpvc = segue.destination as? TweetsPopularityTableViewController
        {
            tpvc.searchText = cell.textLabel?.text
            tpvc.moc = moc
            tpvc.title = "Popularity for " + (cell.textLabel?.text ?? "")
        }
    }


}
