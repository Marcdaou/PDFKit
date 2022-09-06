//
//  PdfPreviewVC.swift
//  Margaritas PDFKit
//
//  Created by Marc Daou on 9/6/22.
//

import UIKit
import PDFKit

class PdfPreviewVC: UIViewController {
    
    public var documentData: Data?
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var shareButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = documentData {
            pdfView.translatesAutoresizingMaskIntoConstraints = false
            pdfView.autoScales = true
            pdfView.pageBreakMargins = UIEdgeInsets.init(top: 20, left: 8, bottom: 32, right: 8)
            pdfView.document = PDFDocument(data: data)
            
        }
    }
    
    @IBAction func share(_ sender: Any) {
        if let dt = documentData {
            let vc = UIActivityViewController(
              activityItems: [dt],
              applicationActivities: []
            )
            if UIDevice.current.userInterfaceIdiom == .pad {
                vc.popoverPresentationController?.barButtonItem = shareButton
            }
            self.present(vc, animated: true, completion: nil)
        }
    }

}
