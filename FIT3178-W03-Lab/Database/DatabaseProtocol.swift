//
//  DatabaseProtocol.swift
//  FIT3178-W03-Lab
//
//  Created by Viet Tran on 21/8/2025.
//

// DatabaseProtocol
// This protocol defines all the core behaviour of a database
// Define  what functionality a database will have
// Define the behaviour of its listeners, and define the types of listeners that a database can have
// Work for both an offline database such as Core Data AND online databases such as Firebase!

enum DatabaseChange {
    case add
    case remove
    case update
}

// Listeners/Delegate can listen for team, heroes or both, will be used when the database has any changes (add, remove, update)
enum ListenerType {
case team
case heroes
case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onTeamChange(change: DatabaseChange, teamHeroes: [SuperHero])
    func onAllHeroesChange(change: DatabaseChange, heroes: [SuperHero])
}
