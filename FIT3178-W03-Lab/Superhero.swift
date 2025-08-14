//
//  Superhero.swift
//  FIT3178-W03-Lab
//
//  Created by Viet Tran on 13/8/2025.
//

import UIKit

// Universe enum
enum Universe: Int {
case marvel = 0
case dc = 1
}

class Superhero: NSObject {
    // Why optional, research on persistent data
    var name: String?
    var abilities: String?
    var universe: Universe?
    
    init(name: String, abilities: String, universe: Universe){
        self.name = name;
        self.abilities = abilities
        self.universe = universe
    }
    
}
