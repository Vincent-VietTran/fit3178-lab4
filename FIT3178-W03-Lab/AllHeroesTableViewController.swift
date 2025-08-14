//
//  AllHeroesTableViewController.swift
//  FIT3178-W03-Lab
//
//  Created by Viet Tran on 13/8/2025.
//

import UIKit

class AllHeroesTableViewController: UITableViewController, UISearchResultsUpdating, AddSuperheroDelegate {
    let SECTION_HERO = 0
    let SECTION_INFO = 1
    let NUM_SECTIONS = 2
    
    let CELL_HERO = "heroCell"
    let CELL_INFO = "totalCell"
    
    var allHeroes: [Superhero] = []
    var filteredHeroes: [Superhero] = []
    weak var superHeroDelegate: AddSuperheroDelegate?
    
    //  made are conforming to the AddSuperheroDelegate
    func addSuperhero(_ newHero: Superhero) -> Bool {
        tableView.performBatchUpdates({
        // TODO: Adding validation for extension task
            
        // Safe because search can't be active when Add button is tapped.
        // Add newly added hero to both all heroes and filtered heroes array
        allHeroes.append(newHero)
        filteredHeroes.append(newHero)
        // Insert the new record into the table view in hero section
        tableView.insertRows(at: [IndexPath(row: filteredHeroes.count - 1, section:
        SECTION_HERO)],
        with: .automatic)
        // Reload section info to reflect the change
        tableView.reloadSections([SECTION_INFO], with: .automatic)
        }, completion: nil)
        // Notify that the action is successful
        return true
    }
    
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
        createDefaultHeroes()
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
            // Delete the row from the data source if it belongs to hero section
            tableView.performBatchUpdates({
                // Make sure when a hero delelted,it is removed in both filtered and all heroes list
                if let index = self.allHeroes.firstIndex(of: filteredHeroes[indexPath.row]) {
                self.allHeroes.remove(at: index)
                }
                // Remove Hero from the list of filtered heroes
                filteredHeroes.remove(at: indexPath.row)
                // Delete row from table view
                tableView.deleteRows(at: [indexPath], with: .fade)
                // Update the info section (decrement hero count)
                self.tableView.reloadSections([SECTION_INFO], with: .automatic)
                
            }, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath:
    IndexPath) {
        if let superHeroDelegate = superHeroDelegate {
            if superHeroDelegate.addSuperhero(filteredHeroes[indexPath.row]){
                navigationController?.popViewController(animated: false)
                return
            } else{
                displayMessage(title: "party Full", message: "Unable to add more members to party")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func createDefaultHeroes(){
        allHeroes.append(Superhero(name: "Bruce Wayne", abilities: "Money", universe: .dc))
        allHeroes.append(Superhero(name: "Superman", abilities: "Super Powered Alien", universe:
        .dc))
        allHeroes.append(Superhero(name: "Wonder Woman", abilities: "Goddess", universe: .dc))
        allHeroes.append(Superhero(name: "The Flash", abilities: "Speed", universe: .dc))
        allHeroes.append(Superhero(name: "Green Lantern", abilities: "Power Ring", universe: .dc))
        allHeroes.append(Superhero(name: "Cyborg", abilities: "Robot Beep Beep", universe: .dc))
        allHeroes.append(Superhero(name: "Aquaman", abilities: "Atlantian", universe: .dc))
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
        if segue.identifier == "createHeroSegue" {
            let destination = segue.destination as! CreateHeroViewController
            destination.superHeroDelegate = self        }
    }
    

}
