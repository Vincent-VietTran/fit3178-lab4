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
    
//    FetchedResultsController to monitor changes and tell all listeners when
//    they occur.
//    This controller will watch for changes to all heroes within the database. When a change
//    occurs, the Core Data controller will be notified and can let its listeners know.
    var allHeroesFetchedResultsController: NSFetchedResultsController<Superhero>?
    
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
        return hero
    }
    
//    this method takes in a Superhero to be deleted and removes it from the main managed object context.
    func deleteSuperhero(hero: Superhero) {
        // Deletion is not made permanent until managed context saved
        persistentContainer.viewContext.delete(hero)
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
    }

}
