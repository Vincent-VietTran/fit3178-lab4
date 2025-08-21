//
//  AllHeroesTableViewController.swift
//  FIT3178-W03-Lab
//
//  Created by Viet Tran on 13/8/2025.
//

import UIKit

class AllHeroesTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    
    // Properties
    let SECTION_HERO = 0
    let SECTION_INFO = 1
    let NUM_SECTIONS = 2
    
    let CELL_HERO = "heroCell"
    let CELL_INFO = "totalCell"
    
    var allHeroes: [Superhero] = []
    var filteredHeroes: [Superhero] = []
    
    var listenerType = ListenerType.heroes
    weak var databaseController: DatabaseProtocol?
    
//    We can define our own search functionality via the UISearchResultsUpdating protocol provided by UIKit.
    // Will be called every time a change is detected in the search bar.
    func updateSearchResults(for searchController: UISearchController) {
        // Make sure search text is not emty before proceed with filtering
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
//        Apply a filter if there is value in search text, otherwise we will set the filteredHeroes to allHeroes.
        if searchText.count > 0{
//            The filter method of the array class allows us to set custom filtering using a closure
            filteredHeroes = allHeroes.filter({(hero: Superhero) -> Bool in
                return (hero.name?.lowercased().contains(searchText) ?? false)
            })
        } else{
            filteredHeroes = allHeroes
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        filteredHeroes = allHeroes
        
//        create the UISeachController and assign it to the View Controller
//        initializing a UISearchController. At this stage we do not give a
//       specialised view controller for displaying search results (will do in future week)
        let searchController = UISearchController(searchResultsController: nil)
//        setting the searchResultsUpdater (delegate), which will update based
//       on the search to current view (also why this view has to conform UISearchResultsUpdating protocol)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All Heroes"
        
//      Also tell our navigationItem that its search controller is the one we just created.
        navigationItem.searchController = searchController
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        
        // getting access to the AppDelegate and then storing a reference to the databaseController from there.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return NUM_SECTIONS
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
            case SECTION_HERO:
                return filteredHeroes.count
            case SECTION_INFO:
                return 1
            default:
                return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_HERO {
            // Configure and return a hero cell
//            Warning: If a forced cast fails the app will immediately crash. This should only be done when
//            you know with 100% certainty that the cell (or other type) you are casting is a particular type.
            let heroCell = tableView.dequeueReusableCell(withIdentifier: CELL_HERO, for: indexPath)
            var content = heroCell.defaultContentConfiguration()
            let hero = filteredHeroes[indexPath.row]
            content.text = hero.name
            content.secondaryText = hero.abilities
            heroCell.contentConfiguration = content
            return heroCell
        } else {
            // Configure and return an info cell instead
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath) as! HeroCountTableViewCell
            
            infoCell.totalLabel?.text = "\(filteredHeroes.count) heroes in the database"
            return infoCell
        }
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Specify that hero cell can be edited but info cells cannot
        if indexPath.section == SECTION_HERO{
            return true
        }
        return false
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_HERO {
            
            // Delete hero from database instead of made-up database (Allheroes represented as an array)
            let hero = filteredHeroes[indexPath.row]
            databaseController?.deleteSuperhero(hero: hero)
            
            // Delete the row from the data source if it belongs to hero section
//            tableView.performBatchUpdates({
//                // Make sure when a hero delelted,it is removed in both filtered and all heroes list
//                if let index = self.allHeroes.firstIndex(of: filteredHeroes[indexPath.row]) {
//                self.allHeroes.remove(at: index)
//                }
//                // Remove Hero from the list of filtered heroes
//                filteredHeroes.remove(at: indexPath.row)
//                // Delete row from table view
//                tableView.deleteRows(at: [indexPath], with: .fade)
//                // Update the info section (decrement hero count)
//                self.tableView.reloadSections([SECTION_INFO], with: .automatic)
//                
//            }, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath:
    IndexPath) {
        // Modify when row being selected, add selected hero to heroes properties of Teams entity table
        let hero = filteredHeroes[indexPath.row]
        let heroAdded = databaseController?.addHeroToTeam(hero: hero, team:
        databaseController!.defaultTeam) ?? false
        // if hero added successfully, do noting
        if heroAdded {
            navigationController?.popViewController(animated: false)
            return
        }
        // If fail to add hero to team, display error message
        displayMessage(title: "Party Full", message: "Unable to add more members to party")
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Not using superHeroDelegate anymore, so removed
//        if let superHeroDelegate = superHeroDelegate {
//            if superHeroDelegate.addSuperhero(filteredHeroes[indexPath.row]){
//                navigationController?.popViewController(animated: false)
//                return
//            } else{
//                displayMessage(title: "party Full", message: "Unable to add more members to party")
//            }
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
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
//        if segue.identifier == "createHeroSegue" {
//            let destination = segue.destination as! CreateHeroViewController
//            destination.superHeroDelegate = self
//        }
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
        allHeroes = heroes
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero]) {
        // Do nothing as All heroes doesn need to care about changes in data of team
    }
    

}
