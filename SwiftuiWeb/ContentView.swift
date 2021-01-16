//
//  ContentView.swift
//  SwiftuiWeb
//
//  Created by Son, Nguyen Hoang on 1/8/21.
//

import SwiftUI
import CoreData
import WebKit
import UIKit
struct ContentView: View {
   
    @State var textHtml: String
    var body: some View {
        VStack {
            Cbess(
                frameEditor: CGRect(x: 0, y: 40, width: 300, height: 400), frameToolbar: CGRect(x: 0, y: 0, width: 0, height: 40), textHTML: $textHtml
            )
            Text("Data: \(textHtml)")
        }
    }

  

}


struct Cbess : UIViewRepresentable{

    let frameEditor : CGRect
    let frameToolbar : CGRect
    
    @Binding var textHTML : String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, RichEditorDelegate {
            
            var parent: Cbess
            
            init(_ parent: Cbess) {
                self.parent = parent
            }
            
            // Use delegate here
            func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
                self.parent.textHTML = content
                print(content)
            }
        }
    
    func makeUIView(context: Context) -> UIView {
        
        let toolbar = RichEditorToolbar(frame: frameToolbar)
        let editorview = RichEditorView(frame: frameEditor)
        editorview.html = textHTML
        editorview.delegate = context.coordinator
        toolbar.options = RichEditorDefaultOption.all
        toolbar.editor = editorview // Previously instantiated RichEditorView
        
        let uiView : UIView = UIView()
        uiView.addSubview(editorview)
        uiView.addSubview(toolbar)
        
        return uiView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(textHtml: "Plsceholder <b>asdas</b>")
    }
}
