//
//  PDFDrawViewController.swift
//  PaintPDFApp
//
//  Created by Le Xuan Quynh on 27/03/2023.
//

import UIKit
import PDFKit

class PDFDrawViewController: UIViewController, EditorColorPickerViewControllerDelegate {
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var thumbnailView: PDFThumbnailView!
    @IBOutlet weak var thumbnailViewContainer: UIView!
    
    private var shouldUpdatePDFScrollPosition = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupPDFView()
    }
    
    private func setupUI() {
        sizeSlider.minimumValue = 10
        sizeSlider.maximumValue = 100
        sizeLabel.text = "\(Int(sizeSlider.value))"
    }
    
    private func setupPDFView() {
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
        pdfView.backgroundColor = view.backgroundColor!
        
        thumbnailView.pdfView = pdfView
        thumbnailView.thumbnailSize = CGSize(width: 100, height: 100)
        thumbnailView.layoutMode = .vertical
        thumbnailView.backgroundColor = thumbnailViewContainer.backgroundColor
    }
    
    @IBAction func changeDrawingTool(sender: UIBarButtonItem) {
        print("sender tag = \(sender.tag)")
    }
    
    @IBAction func onSizeChanged(_ sender: UISlider) {
        sizeLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func onColorSelected(_ sender: UIButton) {
        // show EditorColorPickerViewController
        let editorColorPickerViewController = EditorColorPickerViewController()
        editorColorPickerViewController.modalPresentationStyle = .overCurrentContext
        editorColorPickerViewController.modalTransitionStyle = .crossDissolve
        editorColorPickerViewController.delegate = self
        self.present(editorColorPickerViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func onChangeTopTool(_ sender: UIBarButtonItem) {       
        // convert tag to TopTool
        guard let topTool = TopTool(rawValue: sender.tag) else { return }
        switch topTool {
        case .importPDF:
            self.importPDF()
        case .exportPDF:
            self.exportPDF()
        }
    }
    
    enum TopTool: Int {
        case importPDF = 1
        case exportPDF = 2
    }

    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldUpdatePDFScrollPosition {
            fixPDFViewScrollPosition()
        }
        
    }
    
    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    private func fixPDFViewScrollPosition() {
        if let page = pdfView.document?.page(at: 0) {
            pdfView.go(to: PDFDestination(page: page, at: CGPoint(x: 0, y: page.bounds(for: pdfView.displayBox).size.height)))
        }
    }
    
    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldUpdatePDFScrollPosition = false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        pdfView.autoScales = true // This call is required to fix PDF document scale, seems to be bug inside PDFKit
    }
    
    private func importPDF() {
        // show document picker
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }

    private func exportPDF() {
        // show document picker
//        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .exportToService)
//        documentPicker.delegate = self
//        self.present(documentPicker, animated: true, completion: nil)
    }
}

// EditorColorPickerViewControllerDelegate
extension PDFDrawViewController {
    func onColorSelected(color: UIColor) {
        // set color for colorButton
        colorButton.backgroundColor = color
    }
}

// UIDocumentPickerDelegate
extension PDFDrawViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        // load pdf from url
        let document = PDFDocument(url: url)
        pdfView.document = document
        
    }
}
