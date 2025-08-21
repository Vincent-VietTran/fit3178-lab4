//
//  AllTeamsTableViewController.swift
//  FIT3178-W03-Lab
//
//  Created by Viet Tran on 21/8/2025.
//

import UIKit

//class AllTeamsTableViewController: UITableViewController, DatabaseListener{
class AllTeamsTableViewController: UITableViewController {
    
    // Database listener conformance
//    func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero]) {
//        allTeams = teamHeroes
//        tableView.reloadData()
//    }
    
//    func onAllHeroesChange(change: DatabaseChange, heroes: [Superhero]) {
        // Do nothing
//    }
    
    // Properties
    let SECTION_TEAM = 0
    let SECTION_INFO = 1
    let NUM_SECTIONS = 2
    
    let CELL_TEAM = "teamCell"
    let CELL_INFO = "totalCell"
    
    let MAX_TEAM_COUNT = 10
    
    var allTeams: [Team] = []
    var listenerType = ListenerType.team
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTeamTapped)
        )
        
        // getting access to the AppDelegate and then storing a reference to the databaseController from there.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    @objc func addTeamTapped() {
        // Create an alert when add team button clicked
        let alert = UIAlertController(title: "New Team", message: "Enter team name", preferredStyle: .alert)
        
        // Add a text field to enter team name
        alert.addTextField { textField in
            textField.placeholder = "Team name"
        }
        
        // If ok option was clicked
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Validating name fields (no empty string)
            guard let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces),
                  !name.isEmpty else { return }
            
            // Check if max team count exceeded
            if self.allTeams.count < self.MAX_TEAM_COUNT {
                // If max count not exceeded, proceed with adding team to database
                let _ = self.databaseController?.addTeam(teamName: name)
                // Dislay pop up
                self.navigationController?.popViewController(animated: true)
            } else {
                self.displayMessage(title: "Team Count exceeded", message: "You can only have up to \(self.MAX_TEAM_COUNT) teams.")
            }
        }
        
        // If cancel action was clicked
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return NUM_SECTIONS
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch(section){
        case SECTION_TEAM:
            return allTeams.count
        case SECTION_INFO:
            return 1
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_TEAM {
            let teamCell = tableView.dequeueReusableCell(withIdentifier: CELL_TEAM, for: indexPath)
            var content = teamCell.defaultContentConfiguration()
            let team = allTeams[indexPath.row]
            content.text = team.name
            teamCell.contentConfiguration = content
            return teamCell
        } else {
            // Configure and return an info cell instead
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            
            var content = infoCell.defaultContentConfiguration()
            
            if allTeams.isEmpty{
                content.text = "No Teams exist. Tap + to add some"
            } else{
                content.text = "\(allTeams.count)/\(MAX_TEAM_COUNT) total number of Teams"
            }
            
            infoCell.contentConfiguration = content
            return infoCell
        }
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Specify that team cell can be edited but info cells cannot
        if indexPath.section == SECTION_TEAM{
            return true
        }
        return false
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_TEAM {
            
            // Delete team from database
            let team = allTeams[indexPath.row]
            databaseController?.deleteTeam(team: team)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        let team = allTeams[indexPath.row]
        performSegue(withIdentifier: "showCurrentTeamParty", sender: team)
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        if segue.identifier == "showCurrentParty" {
           let destination = segue.destination as? CurrentPartyTableViewController
       }
     }
        
}
