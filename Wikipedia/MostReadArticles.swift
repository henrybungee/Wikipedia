//
//  MostReadArticles.swift
//  Wikipedia
//
//  Created by Henry Lunger (student LM) on 12/15/22.
//

import SwiftUI
import WikipediaKit

struct ViewDidLoadModifier: ViewModifier {

    @State private var didLoad = false
    private let action: (() -> Void)?

    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }

}

extension View {

    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }

}

struct MostReadArticles: View {

    @State private var articles = []
    
    func loadWikiData() {
        
        let language = WikipediaLanguage("en")
        let dayBeforeYesterday = Date(timeIntervalSinceNow: -60 * 60 * 48)
        
        let _ = Wikipedia.shared.requestFeaturedArticles(language: language, date: dayBeforeYesterday) { result in
            switch result {
                case .success(let featuredCollection):
                    
                    var p = 0
                
                    for a in featuredCollection.mostReadArticles {
                        p += 1
                        articles.append(a.displayTitle)
                        if (p >= 5) {
                            break
                        }
                    }
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    var body: some View {
        
        VStack {
            
            List {
                ForEach(articles as! [String], id: \.self) { article in
                    NavigationLink {
                        PageView(term: article)
                    } label: {
                        Text(article)
                    }
                }
            }
            .onDisappear() {
            }
            .background(Color.clear)
        }
        .onLoad {
            self.loadWikiData()
        }
    }
}

struct MostReadArticles_Previews: PreviewProvider {
    static var previews: some View {
        MostReadArticles()
    }
}
