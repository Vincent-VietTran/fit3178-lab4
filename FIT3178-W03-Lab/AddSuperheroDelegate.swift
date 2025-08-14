//
//  AddSuperheroDelegate.swift
//  FIT3178-W03-Lab
//
//  Created by Viet Tran on 13/8/2025.
//

protocol AddSuperheroDelegate: AnyObject {
    // Notify if adding of hero is successfult or not
    func addSuperhero(_ newHero: Superhero) -> Bool
}
