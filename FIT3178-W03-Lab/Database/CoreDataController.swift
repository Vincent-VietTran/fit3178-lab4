//
//  CoreDataController.swift
//  FIT3178-W03-Lab
//
//  Created by Viet Tran on 21/8/2025.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    // Properties
//    The “listeners” property holds all listeners added to the database inside of the
//    MulticastDelegate class
    var listeners = MulticastDelegate<DatabaseListener>()
    
//    persistentContainer property holds a reference to our persistent container and
//    within it, our managed object context. Any time we need to create, delete, retrieve, or save our database we need to do so via the managed object context.
    var persistentContainer: NSPersistentContainer
    
//    FetchedResultsController to monitor changes and tell all listeners when they occur
//    This controller will watch for changes to all heroes within the database. When a change
//    occurs, the Core Data controller will be notified and can let its listeners know.
    var allHeroesFetchedResultsController: NSFetchedResultsController<Superhero>?
    
    // FetchedResultsController to monitor changes in Teams and tell all listeners when they occur.
    var allTeamsFetchedResultsController: NSFetchedResultsController<Team>?
    
    
    // properties for to support mangaging heroes in a team
    let DEFAULT_TEAM_NAME = "Default Team"
    var teamHeroesFetchedResultsController: NSFetchedResultsController<Superhero>?
    
    // Constructor/Initializer
    override init() {
        // Define persistent storage container with specified name
        persistentContainer = NSPersistentContainer(name: "Week04-DataModel")
        // loads the Core Data stack, and provide a closure for error handling.
        persistentContainer.loadPersistentStores() { (description, error ) in
        if let error = error {
            fatalError("Failed to load Core Data Stack with error: \(error)")
        }
        }
        super.init()
        
//        attempt to fetch all the heroes from the database. If empty, create default heroes values as placeholder
        if fetchAllHeroes().count == 0 {
            createDefaultHeroes()
        }
        
        if fetchAllTeams().count == 0 {
            createDefaultTeams()
        }
    }
  
//    This method will check to see if there are changes to be saved inside of the view context and then save, as necessary.
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
                } catch {
                    fatalError("Failed to save changes to Core Data with error: \(error)")
                }
        }
    }
    
    func addListener(listener: any DatabaseListener) {
//      Firstly it adds the new database listener to the list of listeners
        listeners.addDelegate(listener)
        
//        it will provide the listener with initial immediate results depending on what type of listener it is.
        if listener.listenerType == .heroes || listener.listenerType == .all {
            listener.onAllHeroesChange(change: .update, heroes:
//      if the type is either heroes or all then the method will call the delegate method onAllHeroesChange and pass through all the heroes fetched from the database.
            fetchAllHeroes())
        }
          
        // If listener is for team, it will be notified when data in team changed in the database
//        ensures the listeners get a team of heroes when added to the Multicast Delegate
        // For team listeners only
            if let teamListener = listener as? TeamDatabaseListener {
                if let team = teamListener.currentTeam{
                    teamListener.onTeamChange(change: .update, team: team, teamHeroes: fetchTeamHeroes(for: team))
                }
            }
        
        // it will provide the listener with initial immediate results depending on what type of listener it is.
        if listener.listenerType == .teams || listener.listenerType == .all {
            listener.onAllTeamsChange(change: .update, teams: fetchAllTeams())
        }
              
    }
    
//    passes the specified listener to the multicast delegate class which then removes it from the set of saved listeners.
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // method is responsible for adding new superheroes to Core Data.
//    Superhero is a Core Data managed object stored within a specific managed object
//    context.
    func addSuperhero(name: String, abilities: String, universe: Universe) -> Superhero {
        //    Once a managed object has been created, all changes made to it are tracked. Note
        //    that any new object will not be saved to persistent memory until the save method has been called on its associated managed object context.
        let hero = Superhero(context: persistentContainer.viewContext)
        hero.name = name
        hero.abilities = abilities
        hero.heroUniverse = universe
        
        // When new data added to persistent container view context, need to save it so that data can persist when reload
        do {
               try persistentContainer.viewContext.save()
           } catch {
               print("Failed to save context when adding superhero: \(error)")
           }
        
        return hero
    }
    
//    this method takes in a Superhero to be deleted and removes it from the main managed object context.
    func deleteSuperhero(hero: Superhero) {
        // Deletion is not made permanent until managed context saved
        persistentContainer.viewContext.delete(hero)
        
        do {
                try persistentContainer.viewContext.save() // <--- CRITICAL for state change!
            } catch {
                print("Failed to save context after deleting hero: \(error)")
            }
    }
    
//    The fetchAllHeroes method is used to query Core Data to retrieve all hero entities
//    stored within persistent memory
    func fetchAllHeroes() -> [Superhero] {
//        var heroes = [Superhero]()
////        To query Core Data an NSFetchRequest is created
//        let request: NSFetchRequest<Superhero> = Superhero.fetchRequest()
//        do {
////            Once a fetch request is created it must be passed to the managed object context to execute
//            try heroes = persistentContainer.viewContext.fetch(request)
//            } catch {
//            print("Fetch Request failed with error: \(error)")
//            }
//            return heroes
        
        // If fetch result controller not instantiated
        if allHeroesFetchedResultsController == nil {
//            To instantiate allHeroesFetchedResultsController, we need to create a fetch request
            let request: NSFetchRequest<Superhero> = Superhero.fetchRequest()
//            specify a sort descriptor (required for a fetched results controller), ensuring the results have an order.
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            // Initialise Fetched Results Controller
            allHeroesFetchedResultsController =
            NSFetchedResultsController<Superhero>(fetchRequest: request,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil)
            
            // Set this class to be the results delegate
            allHeroesFetchedResultsController?.delegate = self
            
//            The last step is to perform the fetch request (which will begin the listening process).
            do {
                try allHeroesFetchedResultsController?.performFetch()
                } catch {
                    print("Fetch Request Failed: \(error)")
            }
            
        }
//        check if it contains fetched objects. If it does, we return the array.
        if let heroes = allHeroesFetchedResultsController?.fetchedObjects {
            return heroes
        }
        // else return empty array
        return [Superhero]()
    }
    
    
//    creates several superheroes that can be used for testing the application.
    func createDefaultHeroes() {
//        The "let _"  is needed to stop a compiler warning for not
//        using the value returned by calls to the addSuperhero method. The underscore
//        indicates that we don’t care about the returned value and don’t use it again.
        let _ = addSuperhero(name: "Bruce Wayne", abilities: "Money", universe:
        .dc)
        let _ = addSuperhero(name: "Superman", abilities: "Super Powered Alien", universe: .dc)
        let _ = addSuperhero(name: "Wonder Woman", abilities: "Goddess",
        universe: .dc)
        let _ = addSuperhero(name: "The Flash", abilities: "Speed", universe:
        .dc)
        let _ = addSuperhero(name: "Green Lantern", abilities: "Power Ring",
        universe: .dc)
        let _ = addSuperhero(name: "Cyborg", abilities: "Robot Beep Beep",
        universe: .dc)
        let _ = addSuperhero(name: "Aquaman", abilities: "Atlantian", universe:
        .dc)
        let _ = addSuperhero(name: "Captain Marvel", abilities: "Superhuman Strength", universe: .marvel)
        let _ = addSuperhero(name: "Spider-Man", abilities: "Spider Sense",
        universe: .marvel)
        cleanup()
    }
    
    //    creates several superheroes that can be used for testing the application.
        func createDefaultTeams() {
    //        The "let _"  is needed to stop a compiler warning for not
    //        using the value returned by calls to the addSuperhero method. The underscore
    //        indicates that we don’t care about the returned value and don’t use it again.
            let _ = addTeam(teamName: "Team Marvel")
            let _ = addTeam(teamName: "Team DC")
            let _ = addTeam(teamName: "Team Comics")
            let _ = addTeam(teamName: "Team Movies")
            cleanup()
        }
    
//  method is responsible for adding new team to Core Data.
    func addTeam(teamName: String) -> Team {
        let team = Team(context: persistentContainer.viewContext)
        team.name = teamName
        
        // When new data added to persistent container view context, need to save it so that data can persist when reload
        do {
               try persistentContainer.viewContext.save()
           } catch {
               print("Failed to save context when adding team: \(error)")
           }
        
        // Fetch and print all teams for debugging:
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        do {
            let teams = try persistentContainer.viewContext.fetch(fetchRequest)
            var teamNames: [String] = []
            for t in teams {
                teamNames.append(t.name ?? "undefined")
            }
            print("All Teams in Core Data: \(teamNames)")
        } catch {
            print("Failed to fetch teams: \(error)")
        }
        return team
    }
    
    //  method is responsible for deleting a team from Core Data.
    func deleteTeam(team: Team) {
        persistentContainer.viewContext.delete(team)
        
        do {
                try persistentContainer.viewContext.save() // <--- CRITICAL for delete!
            } catch {
                print("Failed to save context after deleting team: \(error)")
            }
    }
    
    func fetchAllTeams() -> [Team] {
        // If fetch result controller not instantiated
        if allTeamsFetchedResultsController == nil {
//            To instantiate allHeroesFetchedResultsController, we need to create a fetch request
            let request: NSFetchRequest<Team> = Team.fetchRequest()
//            specify a sort descriptor (required for a fetched results controller), ensuring the results have an order.
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            // Initialise Fetched Results Controller
            allTeamsFetchedResultsController =
            NSFetchedResultsController<Team>(fetchRequest: request,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil)
            
            // Set this class to be the results delegate
            allTeamsFetchedResultsController?.delegate = self
            
//            The last step is to perform the fetch request (which will begin the listening process).
            do {
                try allTeamsFetchedResultsController?.performFetch()
                } catch {
                    print("Fetch Request Failed: \(error)")
            }
            
        }
//        check if it contains fetched objects. If it does, we return the array.
        if let teams = allTeamsFetchedResultsController?.fetchedObjects {
            return teams
        }
        // else return empty array
        return [Team]()
    }
    
    
//    attempts to add a hero to a given team and will return a boolean to
//    indicate whether it was successful. It can fail if the team already has 6 or more heroes
//    or if the team already contains the hero
    func addHeroToTeam(hero: Superhero, team: Team) -> Bool {
        guard let heroes = team.heroes, heroes.contains(hero) == false,
        heroes.count < 6 else {
            return false
        }
        team.addToHeroes(hero)
        do {
                try persistentContainer.viewContext.save() // <--- CRITICAL for state change
            } catch {
                print("Failed to save context when adding hero to team: \(error)")
            }
        return true
    }
        
//    This method removes a hero from the team
    func removeHeroFromTeam(hero: Superhero, team: Team) {
        team.removeFromHeroes(hero)
        
        do {
                try persistentContainer.viewContext.save() // <--- CRITICAL for state change
            } catch {
                print("Failed to save context when deleting hero from team: \(error)")
            }
    }
    
//    not part of the DatabaseProtocol but is used internally by the
//    CoreDataController to define how to get the team results.
    
//    returns an array of superheroes which are part of a specified team, done
//    through a fetched results controller similar to fetchAllHeroes
    func fetchTeamHeroes(for currentTeam: Team) -> [Superhero] {
        if teamHeroesFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Superhero> = Superhero.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let predicate = NSPredicate(format: "ANY teams == %@", currentTeam)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            fetchRequest.predicate = predicate
            teamHeroesFetchedResultsController =
            NSFetchedResultsController<Superhero>(fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil)
            teamHeroesFetchedResultsController?.delegate = self
            do {
            try teamHeroesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        var heroes = [Superhero]()
        if teamHeroesFetchedResultsController?.fetchedObjects != nil {
            heroes = (teamHeroesFetchedResultsController?.fetchedObjects)!
        }
        return heroes
    }
    
    // MARK: - Fetched Results Controller Protocol methods
    func controllerDidChangeContent(_ controller:
//    This will be called whenever the FetchedResultsController detects a change to the result of its fetch
    NSFetchedResultsController<NSFetchRequestResult>) {
//        first check to see if the controller is our allHeroesFetchedResultsController.
        if controller == allHeroesFetchedResultsController {
            // Call MulticastDelegate invoke method, provide a closure that will be called for each listener
//    it checks if it is listening for changes to heroes. If it is, it calls the onAllHeroesChange method
            listeners.invoke() { listener in
                if listener.listenerType == .heroes
                || listener.listenerType == .all {
                    listener.onAllHeroesChange(change: .update,
                    heroes: fetchAllHeroes())
                }
            }
        }
        
        // check if listeners is for team, If it is, it calls the onAllHeroesChange method
        else if controller == teamHeroesFetchedResultsController {
             listeners.invoke { (listener) in
                 if let teamListener = listener as? TeamDatabaseListener {
                     if let team = teamListener.currentTeam{
                         teamListener.onTeamChange(change: .update, team: team, teamHeroes: fetchTeamHeroes(for: team))
                     }
                 }
             }
        }
        
        // check if listeners is for teams, If it is, it calls the onAllTeamsChange method
        else if controller == allTeamsFetchedResultsController {
             listeners.invoke { (listener) in
             if listener.listenerType == .teams || listener.listenerType == .all {
                 listener.onAllTeamsChange(change: .update, teams: fetchAllTeams())
                }
             }
        }
    }
    
    // MARK: - Lazy Initialisation of Default Team
    
//    a lazy property, it is not initialized when the rest of the class is initialized. Instead, it is initialised the first time  that its value is requested.
//    lazy var defaultTeam: Team = {
////        A fetch request is used here to find all instances of teams with the name "Default
////        Team". If none are found, we create one. This will be done on the first run of the
////        application. After this point, there should always be a Default Team.
//        var teams = [Team]()
//        let request: NSFetchRequest<Team> = Team.fetchRequest()
//        let predicate = NSPredicate(format: "name = %@", DEFAULT_TEAM_NAME)
//        request.predicate = predicate
//        do {
//        try teams = persistentContainer.viewContext.fetch(request)
//        } catch {
//            print("Fetch Request Failed: \(error)")
//        }
//        if let firstTeam = teams.first {
//            return firstTeam
//        }
//            return addTeam(teamName: DEFAULT_TEAM_NAME)
//    }()

}
