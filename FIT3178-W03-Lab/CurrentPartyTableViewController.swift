//
//  CurrentPartyTableViewController.swift
//  FIT3178-W03-Lab
//
//  Created by Viet Tran on 13/8/2025.
//

import UIKit

class CurrentPartyTableViewController: UITableViewController, DatabaseListener {
//    Table View Controllers have the concept of sections. Each section can
//    have its own type of cell and number of cells. For this app, we have two sections: one
//    for heroes in our party and one for displaying the current number of heroes in our party
    
    // Define hero as the first section and info as second section
    let SECTION_HERO = 0
    let SECTION_INFO = 1
    let NUM_SECTIONS = 2
    
    // Good practice to define identifier used as constant
    let CELL_HERO = "heroCell"
    let CELL_INFO = "partySizeCell"
    
    // property to store party of heroes
    var currentParty: [Superhero] = []
    
    // Properties to handle managing data for Teams
    var listenerType: ListenerType = .team
    weak var databaseController: DatabaseProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // getting access to the AppDelegate and then storing a reference to the databaseController from there.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }

    // MARK: - Table view data source
    
    // Return number of section exists in the table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return NUM_SECTIONS
    }

    // Return number of Rows in specified Section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
            // Info section always has 1 row displaying the size of the party
            case SECTION_INFO:
                return 1
            // Hero section will shows number of rows depending on the size of the party
            case SECTION_HERO:
                return currentParty.count
            default:
                return 0
        }
    }

    // Create and Return a cell to be displayed to user
    
    // Naming convention of function params
        // externalLabel internalLabel: labelType
        // _ internalLabel: means omits the external label
        // external label: used when function is called
        // internal label: used inside the function
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Indentifier must match with the one defined in storyboard
        // The indexPath specify the section and row in a multi-section list such as TableView (e.g. IndexPath(row: 7, section: 0)
        // Section tells which type of cell to generate
        // Row tells which type of object its info displayed in cell
        if indexPath.section == SECTION_HERO {
            // Configure and return a hero cell
            let heroCell = tableView.dequeueReusableCell(withIdentifier: CELL_HERO, for: indexPath)
            var content = heroCell.defaultContentConfiguration()
            let hero = currentParty[indexPath.row]
            content.text = hero.name
            content.secondaryText = hero.abilities
            heroCell.contentConfiguration = content
            return heroCell
        } else {
            // Configure and return an info cell instead
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            
            var content = infoCell.defaultContentConfiguration()
            
            if currentParty.isEmpty{
                content.text = "No Heroes in Party. Tap + to add some"
            } else{
                content.text = "\(currentParty.count)/6 Heroes in Party"
            }
            
            infoCell.contentConfiguration = content
            return infoCell
        }
    }
    

    // Override to support conditional editing of the table view.
    // allows us to specify whether a certain row can be edited at all by the user
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Specify that hero cell can be edited but info cells cannot
        if indexPath.section == SECTION_HERO{
            return true
        }
        return false
    }
    

    
    // Override to support editing the table view.
//    Determining whether any given row can be edited is one method. Handling the editing is done by another.
//   Handle deletion or insertion (editing style) of rows into our table view
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_HERO {
            // Remove hero from team when user perform row deletion
            self.databaseController?.removeHeroFromTeam(hero:
            currentParty[indexPath.row], team: databaseController!.defaultTeam)
            
            
            // Delete the row from the data source if it belongs to hero section
//            tableView.performBatchUpdates({
//                // Remove Hero from the Current Party
//                currentParty.remove(at: indexPath.row)
//                // Delete row from table view
//                tableView.deleteRows(at: [indexPath], with: .fade)
//                // Update the info section (decrement party count)
//                self.tableView.reloadSections([SECTION_INFO], with: .automatic)
//                
//            }, completion: nil)
        }
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
        
    }
    
    //    This method is called before the view appears on
    //    screen. In this method, we need to add ourselves to the database listeners.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    databaseController?.removeListener(listener: self)
    }
    
    // Conforms DatabaseListener stubs
    func onAllHeroesChange(change: DatabaseChange, heroes: [Superhero]) {
        // Do nothing as All heroes doesn need to care about changes in data of All heroes
    }
    
    func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero]) {
        currentParty = teamHeroes
        tableView.reloadData()
    }
    
    
    // Add super hero to team
    func addSuperhero(_ newHero: Superhero) -> Bool {
        return databaseController?.addHeroToTeam(hero: newHero,
        team: databaseController!.defaultTeam) ?? false
    }

}
