//
//  ContentView.swift
//  SwiftuiWeb
//
//  Created by Son, Nguyen Hoang on 1/8/21.
//

import SwiftUI
import CoreData
import WebKit

struct ContentView: View {
   
    @State var textHtml: String = ""
    var body: some View {
        VStack {
//            Text("Hello")
            WebView(text: $textHtml)
            Text(textHtml)
        }
    }

  

}

struct WebView: UIViewRepresentable {
  @Binding var text: String
   
  func makeUIView(context: Context) -> RichTextEditor {
    return RichTextEditor()
  }
   
  func updateUIView(_ editor: RichTextEditor, context: Context) {
    text = editor.bodyContent
  }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(textHtml: "<h1>Hello</h1>")
    }
}
