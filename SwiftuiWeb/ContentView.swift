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
   
    @State var textHtml: String = ""
    var body: some View {
        VStack {
            Cbess(
                frameEditor: CGRect(x: 0, y: 40, width: 0, height: 400), frameToolbar: CGRect(x: 0, y: 0, width: 0, height: 40)
            )
        }
    }

  

}


struct Cbess : UIViewRepresentable{

    let frameEditor : CGRect
    let frameToolbar : CGRect
    
    func makeUIView(context: Context) -> UIView {
        
        let toolbar = RichEditorToolbar(frame: frameToolbar)
        let editorview = RichEditorView(frame: frameEditor)

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
        ContentView(textHtml: "<h1>Hello</h1>")
    }
}
