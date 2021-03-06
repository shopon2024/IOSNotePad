//
//  ViewController.swift
//  NotePad
//
//  Created by Kurs on 27/07/2020.
//  Copyright © 2020 Kurs. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UITableViewController {

    let crudService = CRUDService()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var notes = [Note]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        searchBar.delegate = self
        notes = crudService.loadNotesFromSearch()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: Constants.notesCell)
        cell.textLabel?.text = notes[indexPath.row].title
        cell.detailTextLabel?.text = dateFormatter(with: notes[indexPath.row].creationDate!)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.noteDetailsSegue, sender: self)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow, let detailsVC = segue.destination as? DetailsViewController {
            detailsVC.note = notes[indexPath.row]
        }
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.noteSaveSegue, sender: self)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            crudService.deleteNote(note: notes[indexPath.row])
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func dateFormatter(with date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "d MMM y, HH:mm"
        return formatter.string(from: date)
    }
}

extension NotesViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            notes = crudService.loadNotesFromSearch()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        notes = crudService.loadNotesFromSearch(predicate: predicate)
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = ""
        searchBar.showsCancelButton = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
