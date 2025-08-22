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
case teams
case all
}

//This protocol defines the delegate we will use for receiving messages from the
//database. It has three things that any implementation must take care of.
// ● The implementation must always specify the listener’s type
// ● An onTeamChange method for when a change to heroes in a team has occurred.
// ● An onAllHeroesChange method for when a change to any of the heroes has
//occurred.
//e DatabaseListener is kept database agnostic (used by any database defined for the app)

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onAllHeroesChange(change: DatabaseChange, heroes: [Superhero])
    func onAllTeamsChange(change: DatabaseChange, teams: [Team])
}

protocol TeamDatabaseListener: DatabaseListener{
    var currentTeam: Team? {get}
    func onTeamChange(change: DatabaseChange, team: Team, teamHeroes: [Superhero])
}


//defines all the behaviour that a database must have
protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    // Support add and remove of listeners
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    
    // Suporting adding, deleting and saving of Superhero in all heroes view controller
    func addSuperhero(name: String, abilities: String, universe: Universe)
    -> Superhero?
    func deleteSuperhero(hero: Superhero)
    
    // Support add and delete of team in all teams view controller
//    var defaultTeam: Team {get}
    func addTeam(teamName: String) -> Team
    func deleteTeam(team: Team)
    
    // Supporting adding, deleting and saving of Superhero in current party view controller
    // Support adding and removing hero from a team
    // Assume only single team of Superhero for the app
    func addHeroToTeam(hero: Superhero, team: Team) -> Bool
    func removeHeroFromTeam(hero: Superhero, team: Team)
}
