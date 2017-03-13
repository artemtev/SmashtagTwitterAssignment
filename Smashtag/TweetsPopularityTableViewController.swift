//
//  TweetsPopularityTableViewController.swift
//  Smashtag
//
//  Created by Admin on 13.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreData

class TweetsPopularityTableViewController: CoreDataTableViewController {

    var searchText: String? {
        didSet {
            updateUI()
        }
    }
    var moc: NSManagedObjectContext? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let context = moc, let search = searchText, search.characters.count > 0 {
            let request: NSFetchRequest<Mension> = Mension.fetchRequest()
            request.predicate = NSPredicate(format:
                "term.term contains[c] %@ AND count > %@", searchText!, "1")
            request.sortDescriptors = [NSSortDescriptor(
                key: "type",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                ), NSSortDescriptor(
                    key: "count",
                    ascending: false
                ),NSSortDescriptor(
                    key: "keyword",
                    ascending: true,
                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )]
            let resultsController:NSFetchedResultsController<Mension>? =
                NSFetchedResultsController(
                    fetchRequest: request,
                    managedObjectContext: context,
                    sectionNameKeyPath: "type",
                    cacheName: nil
            )
            fetchedResultsController =
                resultsController as? NSFetchedResultsController<NSFetchRequestResult>
        } else {
            
            fetchedResultsController = nil
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.PopularMentionsCellIdentifier,
                                                 for: indexPath)
        var keyword: String?
        var count: String?
        if let mensionM = fetchedResultsController?.object(at: indexPath) as? Mension {
            mensionM.managedObjectContext?.performAndWait {
                keyword =  mensionM.keyword
                count =  String(mensionM.count)
            }
            cell.textLabel?.text = keyword
            cell.detailTextLabel?.text = "tweets.count: " + (count ?? "-")
        }
        return cell
    }
}
