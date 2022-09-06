//
//  Cocktail.swift
//  Margaritas PDFKit
//
//  Created by Marc Daou on 9/1/22.
//

import Foundation

class Menu: Codable {
    var drinks: [Cocktail]?

    init(drinks: [Cocktail]?) {
        self.drinks = drinks
    }
}

class Cocktail: Codable {
    var idDrink, strDrink: String?
    var strCategory, strAlcoholic: String?
    var strGlass, strInstructions: String?
    var strIngredient1, strIngredient2, strIngredient3, strIngredient4: String?
    var strMeasure1, strMeasure2, strMeasure3, strMeasure4: String?

    init(idDrink: String?, strDrink: String?, strCategory: String?, strAlcoholic: String?, strGlass: String?, strInstructions: String?, strIngredient1: String?, strIngredient2: String?, strIngredient3: String?, strIngredient4: String?, strMeasure1: String?, strMeasure2: String?, strMeasure3: String?, strMeasure4: String?) {
        self.idDrink = idDrink
        self.strDrink = strDrink
        self.strCategory = strCategory
        self.strAlcoholic = strAlcoholic
        self.strGlass = strGlass
        self.strInstructions = strInstructions
        self.strIngredient1 = strIngredient1
        self.strIngredient2 = strIngredient2
        self.strIngredient3 = strIngredient3
        self.strIngredient4 = strIngredient4
        self.strMeasure1 = strMeasure1
        self.strMeasure2 = strMeasure2
        self.strMeasure3 = strMeasure3
        self.strMeasure4 = strMeasure4
    }
}
