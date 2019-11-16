//
//  ViewController.swift
//  Star Board
//
//  Created by Greg Wu on 11/13/19.
//  Copyright © 2019 Greg Wu. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var tokenArray = [Token]()  // Create array of custom Token class objects
    var numberTokensEarned: Int = 0
    var goal: String = ""  // Description of goal to work for
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up navigation bar
        title = "I am working for:"
        
        // Create toolbar item objects
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)  // flexible spacer "spring"
        let clear = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearList))
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToken))
        
        toolbarItems = [clear, spacer, add]  // Set toolbar items array property
        navigationController?.isToolbarHidden = false  // Show toolbar
        
        setupGoal()
    }
    
    // Actions to add token/star or to perform when + (add) bar button is pressed
    @objc func addToken() {
        let newToken = Token()  // Create new Token object for list
        
        tokenArray.append(newToken)
                
        // Insert row at end of table view list and load new token
        let indexPath = IndexPath(row: tokenArray.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // Actions to clear list or to perform when Clear bar button is pressed
    @objc func clearList() {
        tokenArray = []
        numberTokensEarned = 0
        
        title = "I am working for:"
        
        tableView.reloadData()
        setupGoal()
    }
    
    // Prompt user for goal to work for, and show in toolbar
    func setupGoal() {
        // Create alert controller and Submit action
        let ac = UIAlertController(title: "I am working for:", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] (action) in
            guard let description = ac?.textFields?[0].text else { return }  // Safely unwrap optional text field
            if description != "" {  // If text field was not an empty string:
                self?.goal = description
            } else {
                self?.goal = "(Goal)"
            }
            
            self?.title = "I am working for: \(self?.goal ?? "")"
            
            self?.setupTokens()  // Call method to prompt user for number of tokens/stars to earn
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    // Prompt user for number of tokens/stars to earn
    func setupTokens() {
        // Create alert controller and actions
        let ac = UIAlertController(title: "Number of stars to earn:", message: nil, preferredStyle: .alert)
        
        let select5 = UIAlertAction(title: "5", style: .default) { (alert) in
            for _ in 1...5 { self.addToken() }
        }
        let select6 = UIAlertAction(title: "6", style: .default) { (alert) in
            for _ in 1...6 { self.addToken() }
        }
        let select10 = UIAlertAction(title: "10", style: .default) { (alert) in
            for _ in 1...10 { self.addToken() }
        }
        let select12 = UIAlertAction(title: "12", style: .default) { (alert) in
            for _ in 1...12 { self.addToken() }
        }
        
        ac.addAction(select5)
        ac.addAction(select6)
        ac.addAction(select10)
        ac.addAction(select12)
        present(ac, animated: true)
    }
    
    // Check if all tokens/stars have been earned, and provide option to clear list
    func checkAllTokensEarned() {
        if numberTokensEarned == tokenArray.count {
            let ac = UIAlertController(title: "Good job!", message: "You earned: \(goal)", preferredStyle: .alert)
            let clearAction = UIAlertAction(title: "Clear", style: .default) { (action) in
                self.clearList()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(clearAction)
            ac.addAction(cancelAction)
            present(ac, animated: true)
        }
    }
    
    // Table view delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokenArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Token", for: indexPath)
        if tokenArray[indexPath.row].earned {  // Adjust star image, text, and checkmark accessory of cell depending on Token.earned property
            cell.imageView?.image = UIImage(named: "Star - Fill.png")
            cell.textLabel?.text = "Earned!"
            cell.accessoryType = .checkmark
        } else {
            cell.imageView?.image = UIImage(named: "Star - No Fill.png")
            cell.textLabel?.text = "Star to earn"
            cell.accessoryType = .none
        }
        return cell
    }
    
    // Toggle Token.earned property and list text and checkmark when row is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tokenArray[indexPath.row].earned = !tokenArray[indexPath.row].earned
        if tokenArray[indexPath.row].earned {
            numberTokensEarned += 1
        } else {
            numberTokensEarned -= 1
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        checkAllTokensEarned()
    }
    
    // Make table rows swipable, and define delete action (code snippet from HackingWithSwift.com)
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if tokenArray[indexPath.row].earned { numberTokensEarned -= 1 }
            tokenArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

