//
//  ViewController.swift
//  Margaritas PDFKit
//
//  Created by Marc Daou on 8/31/22.
//

import UIKit
import PDFKit

class ViewController: UIViewController {

    @IBOutlet weak var queryField: UITextField!
    var pdfData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func generatePDF(_ sender: Any) {
        NetworkManager.shared.getCocktails(searchQuery: queryField.text ?? "") { menu in
            DispatchQueue.main.async {
                let pdfData = self.generatePdfData(drinks: menu.drinks ?? [])
                self.pdfData = pdfData
                self.performSegue(withIdentifier: "toPDFPreview", sender: self)
            }
        } failure: { error in
            print("Oops", error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PdfPreviewVC {
            vc.documentData = pdfData
        }
    }
    
    func generatePdfData(drinks: [Cocktail]) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "thecocktaildb",
            kCGPDFContextAuthor: "Marc Daou",
            kCGPDFContextTitle: "Cocktails Menu"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 10, y: 10, width: 595.2, height: 841.8)
        let graphicsRenderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = graphicsRenderer.pdfData { (context) in
            context.beginPage()
            
            let initialCursor: CGFloat = 32
            
            var cursor = context.addCenteredText(fontSize: 32, weight: .bold, text: "Cocktail Menu 🍹", cursor: initialCursor, pdfSize: pageRect.size)
            
            cursor+=42 // Add white space after the Title
            
            for drink in drinks {
                cursor = generateDrinkText(drink: drink, context: context, cursorY: cursor, pdfSize: pageRect.size)
            }
        }
        return data
    }
    
    func addDrinkIngredients(drink: Cocktail, context: UIGraphicsPDFRendererContext, cursorY: CGFloat, pdfSize: CGSize) -> CGFloat {
        let ingredients = [drink.strIngredient1, drink.strIngredient2, drink.strIngredient3, drink.strIngredient4]
        let measures = [drink.strMeasure1, drink.strMeasure2, drink.strMeasure3, drink.strMeasure4]
        var cursor = cursorY
        let leftMargin: CGFloat = 74
        
        for i in 0..<ingredients.count {
            if let ingredient = ingredients[i], let measure = measures[i] {
                cursor = context.addSingleLineText(fontSize: 12, weight: .thin, text: " • \(ingredient) (\(measure))", indent: leftMargin, cursor: cursor, pdfSize: pdfSize, annotation: nil, annotationColor: nil)
                cursor+=2
            }
        }
        
        cursor+=8
        
        return cursor

    }
    
    func generateDrinkText(drink: Cocktail, context: UIGraphicsPDFRendererContext, cursorY: CGFloat, pdfSize: CGSize) -> CGFloat {
        var cursor = cursorY
        let leftMargin: CGFloat = 74
        
        
        if let drinkName = drink.strDrink {
            cursor = context.addSingleLineText(fontSize: 14, weight: .bold, text:  drinkName, indent: leftMargin, cursor: cursor, pdfSize: pdfSize, annotation: .underline, annotationColor: .black)
            cursor+=6
            
            cursor = context.addSingleLineText(fontSize: 12, weight: .thin, text: "\(drink.strCategory ?? "Cocktail") | \(drink.strAlcoholic ?? "Might Contain Alcohol")", indent: leftMargin, cursor: cursor, pdfSize: pdfSize, annotation: nil, annotationColor: nil)
            cursor+=2
            
            cursor = addDrinkIngredients(drink: drink, context: context, cursorY: cursor, pdfSize: pdfSize)

            if let instructions = drink.strInstructions {
                cursor = context.addMultiLineText(fontSize: 9, weight: .regular, text: instructions, indent: leftMargin, cursor: cursor, pdfSize: pdfSize)
                cursor+=8
            }
            
            cursor+=8
        }
        
        return cursor
    }
}


extension UIGraphicsPDFRendererContext {
    
    func addCenteredText(fontSize: CGFloat,
                         weight: UIFont.Weight,
                         text: String,
                         cursor: CGFloat,
                         pdfSize: CGSize) -> CGFloat {
        
        let textFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
        let pdfText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: textFont])
        
        let rect = CGRect(x: pdfSize.width/2 - pdfText.size().width/2, y: cursor, width: pdfText.size().width, height: pdfText.size().height)
        pdfText.draw(in: rect)
        
        return self.checkContext(cursor: rect.origin.y + rect.size.height, pdfSize: pdfSize)
    }
    
    func addSingleLineText(fontSize: CGFloat,
                           weight: UIFont.Weight,
                           text: String,
                           indent: CGFloat,
                           cursor: CGFloat,
                           pdfSize: CGSize,
                           annotation: PDFAnnotationSubtype?,
                           annotationColor: UIColor?) -> CGFloat {
        
        let textFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
        let pdfText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: textFont])
        
        let rect = CGRect(x: indent, y: cursor, width: pdfSize.width - 2*indent, height: pdfText.size().height)
        pdfText.draw(in: rect)
        
        if let annotation = annotation {
            let annotation = PDFAnnotation(
                bounds: CGRect.init(x: indent, y: rect.origin.y + rect.size.height, width: pdfText.size().width, height: 10),
                forType: annotation,
                withProperties: nil)
            annotation.color = annotationColor ?? .black
            annotation.draw(with: PDFDisplayBox.artBox, in: self.cgContext)
        }
        
        return self.checkContext(cursor: rect.origin.y + rect.size.height, pdfSize: pdfSize)
    }
    
    func addMultiLineText(fontSize: CGFloat,
                          weight: UIFont.Weight,
                          text: String,
                          indent: CGFloat,
                          cursor: CGFloat,
                          pdfSize: CGSize) -> CGFloat {
        
        let textFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping

        let pdfText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: textFont])
        let pdfTextHeight = pdfText.height(withConstrainedWidth: pdfSize.width - 2*indent)
        
        let rect = CGRect(x: indent, y: cursor, width: pdfSize.width - 2*indent, height: pdfTextHeight)
        pdfText.draw(in: rect)

        return self.checkContext(cursor: rect.origin.y + rect.size.height, pdfSize: pdfSize)
    }
    
    func checkContext(cursor: CGFloat, pdfSize: CGSize) -> CGFloat {
        if cursor > pdfSize.height - 100 {
            self.beginPage()
            return 40
        }
        return cursor
    }
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
    
        return ceil(boundingBox.height)
    }
}
