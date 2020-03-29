//
//  ViewController.swift
//  Star Board
//
//  Created by Greg Wu on 11/13/19.
//  Copyright © 2019 Greg Wu. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    // Set up User Defaults and property observers to store data for variables
    let defaults = UserDefaults.standard
    
    var tokenArray = [Token]() {  // Create array of custom Token struct objects
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(tokenArray) {
                defaults.set(encoded, forKey: "TokenArray")
            }
        }
    }
    var numberTokensEarned: Int = 0 {
        didSet {
            defaults.set(numberTokensEarned, forKey: "NumberTokensEarned")
        }
    }
    var goal: String = "(Goal)" {  // Description of goal to work for, with default value
        didSet {
            defaults.set(goal, forKey: "Goal")
        }
    }
    var skill: String = "Star to earn" {  // Description of skill to earn star, with default value
        didSet {
            defaults.set(skill, forKey: "Skill")
        }
    }
    
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
        
        // Read User Defaults data for variables if it exists
        if let encoded = defaults.object(forKey: "TokenArray") as? Data {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Token].self, from: encoded) {
                tokenArray = decoded
            }
            numberTokensEarned = defaults.integer(forKey: "NumberTokensEarned")
            goal = defaults.object(forKey: "Goal") as? String ?? "(Goal)"
            skill = defaults.object(forKey: "Skill") as? String ?? "Star to earn"
            
            title = "I am working for: \(goal)"
        } else {
            setupGoal()
        }
    }
    
    // Actions to add token/star or to perform when + (add) bar button is pressed
    @objc func addToken() {
        let newToken = Token(earned: false)  // Create new Token object for list
        
        tokenArray.append(newToken)
                
        // Insert row at end of table view list and load new token
        let indexPath = IndexPath(row: tokenArray.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // Actions to clear list
    @objc func clearList() {
        let ac = UIAlertController(title: "Clear Board", message: "Are you sure?", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "Clear", style: .destructive) { (action) in
            self.tokenArray = []
            self.numberTokensEarned = 0
            self.goal = "(Goal)"
            self.skill = "Star to earn"
            
            self.title = "I am working for:"
            
            self.tableView.reloadData()
            self.setupGoal()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(clearAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
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
            }
            
            self?.title = "I am working for: \(self?.goal ?? "(Goal)")"
            
            self?.setupSkill()  // Call method to prompt user for skill to earn star
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    // Prompt user for skill to earn star
    func setupSkill() {
        // Create alert controller and Submit and Skip actions
        let ac = UIAlertController(title: "Skill to earn star:", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] (action) in
            guard let description = ac?.textFields?[0].text else { return }  // Safely unwrap optional text field
            if description != "" {  // If text field was not an empty string:
                self?.skill = description
            }
            
            self?.setupTokens()  // Call method to prompt user for number of tokens/stars to earn
        }
        let skipAction = UIAlertAction(title: "Skip", style: .cancel) { (action) in
            self.setupTokens()  // Call method to prompt user for number of tokens/stars to earn
        }
        
        ac.addAction(submitAction)
        ac.addAction(skipAction)
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
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Goal") as? GoalViewController {
                vc.goal = goal
                present(vc, animated: true, completion: nil)
            }
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
            cell.textLabel?.text = skill
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
        }
    }

}

