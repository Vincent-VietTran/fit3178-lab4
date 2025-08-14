//
//  CreateHeroViewController.swift
//  FIT3178-W03-Lab
//
//  Created by Viet Tran on 14/8/2025.
//

import UIKit

class CreateHeroViewController: UIViewController {
    weak var superHeroDelegate: AddSuperheroDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var abilitiesTextField: UITextField!
    
    @IBOutlet weak var universeSegmentedControl: UISegmentedControl!
    
    
    @IBAction func createHero(_ sender: Any) {
        // Do nothing if if any of the field is nil
        guard let name = nameTextField.text, let abilities = abilitiesTextField.text, let universe =
        Universe(rawValue: universeSegmentedControl.selectedSegmentIndex) else {
        return
        }
        // CHeck if any of the field is empty
        if name.isEmpty || abilities.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if name.isEmpty {
                errorMsg += "- Must provide a name\n"
            }
            if abilities.isEmpty {
                errorMsg += "- Must provide abilities"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        
        // Create hero based on value of text fields and segmented control
        let hero = Superhero(name: name, abilities: abilities, universe: universe)
        // Notify delegate/listener about the new hero created
        let _ = superHeroDelegate?.addSuperhero(hero)
        // Dislay pop up
        navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
