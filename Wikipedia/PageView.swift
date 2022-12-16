//
//  PageView.swift
//  Wikipedia
//
//  Created by Henry Lunger (student LM) on 12/14/22.
//

import SwiftUI
import WikipediaKit

struct PageView: View {
    
    // This variable will dismiss the view
    @Environment(\.presentationMode) var presentationMode
    
    //what youre searching for
    @State var term: String
    
    //lots of variables
    @State private var wikiImage = ""
    @State private var wikiSearch = ""
    @State private var wikiText = ""
    @State private var wikiTitle = ""
    @State private var wikiURL = ""
    
    //variable for sharing the URL
    @State var shareText: ShareText?
    
    //bools
    @State private var showingAlert = false
    @State private var _isLoading: Bool = true
    
    func fetchWikiData() {
        Wikipedia.shared.requestOptimizedSearchResults(language: WikipediaLanguage("en"), term: term)
        {(searchResults, error) in
            guard error == nil else {
                _isLoading = false
                showingAlert = true
                return
            }
            guard let searchResults = searchResults else {return}
            for articlePreview in searchResults.items {
                if let image = articlePreview.imageURL {
                    wikiImage.append("\(image)")
                }
                wikiText.append(articlePreview.displayText)
                wikiURL.append(articlePreview.url!)
                wikiTitle.append(articlePreview.title)
                _isLoading = false
                break
            }
            
        }
    }
    
    var body: some View {
        
        if (_isLoading) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.gray))
        }
        
        else {
            ScrollView {
                Image(uiImage: wikiImage.load())
                    .resizable()
                    .frame(width: 200, height: 200, alignment: .center)
                    .navigationTitle(wikiTitle)
                Text(wikiTitle)
                    .font(.largeTitle)
                Text(wikiText)
                    .padding()
                    .navigationTitle(wikiTitle)
                    .alert(isPresented: $showingAlert) {
                        print("hello")
                        return Alert(title: Text("Critical Error"), message: Text("Search query: '" + term + "' does not exist!"),
                              
                            dismissButton: .default(Text("OK"), action: {
                                presentationMode.wrappedValue.dismiss()
                        }))
                    }
            }
        }
        Text("")
            .onAppear { self.fetchWikiData() }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        shareText = ShareText(text:wikiURL)
                    } label: {
                        Image(systemName: "paperplane")
                    }
                    .disabled(_isLoading)
                    .sheet(item: $shareText) { shareText in
                        ActivityView(text: shareText.text)
                    }
                }
            }
    }
}

struct ShareText: Identifiable {
    let id = UUID()
    let text: String
}

struct ActivityView: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
