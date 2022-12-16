//
//  ContentView.swift
//  Wikipedia
//
//  Created by Henry Lunger (student LM) on 12/14/22.
//

import SwiftUI
import WikipediaKit

extension String {
    
    func load() -> UIImage {
        do {
            guard let url = URL(string: self) else {
                return UIImage()
            }
            
            let data: Data = try
                Data(contentsOf: url, options: .uncached)
            return UIImage(data: data) ?? UIImage()
            
        } catch {
            
        }
        return UIImage()
    }
}

struct ContentView: View {
    
    @State private var articleDisplayText = ""
    @State var refresh: Bool = false

    func update() {
       refresh.toggle()
    }
    
    func randomArticle() -> String {
        
        return articleDisplayText
    }
    
    func fetchDailyWiki() {
        
        let language = WikipediaLanguage("en")
        let dayBeforeYesterday = Date(timeIntervalSinceNow: -60 * 60 * 48)
        
        Wikipedia.shared.requestFeaturedArticles(language: language, date: dayBeforeYesterday) {result in
            switch result {
                case .success(let article):
                    isLoadingArticle = false
                    aoftdTitle.append(article.articleOfTheDay?.title ?? "Unable to Load Article of the Day")
                    aoftdShort.append(article.articleOfTheDay?.description ?? "")
                aoftdDescription.append(article.articleOfTheDay?.displayText ?? "Failed to Load")
                case .failure(let error):
                    print(error)
                
              }
        }
    }
    
    //variables
    @State private var isLoadingArticle = true
    
    @State private var wikiImage = ""
    @State private var wikiSearch = ""
    @State private var wikiText = ""
    @State private var wikiTitle = ""
    
    @State private var showWiki = false
    
    @State private var navTitle = "Wikipedia"
    
    @State private var aoftdTitle = ""
    @State private var aoftdDescription = ""
    @State private var aoftdImage = ""
    @State private var aoftdShort = ""
    
    
    @Environment(\.defaultMinListRowHeight) var minRowHeight


    var body: some View {
        
        NavigationView {
            ScrollView {
                ZStack {
                    Rectangle()
                        .foregroundColor(Color("SearchBar"))
                        TextField("Search...", text: $wikiSearch)
                            .foregroundColor(Color.gray)
                            .padding(.leading, 13)
                }
                
                .frame(height:40)
                .cornerRadius(13)
                .padding()
                
                Text("").onAppear {
                    
                    if (articleDisplayText == "") {
                        Wikipedia.shared.requestSingleRandomArticle(language: WikipediaLanguage("en"), maxCount: 8, imageWidth: 640) {
                            (article, language, error) in

                            guard let article = article else { return }
                            
                            articleDisplayText = article.displayTitle
                            print(articleDisplayText)
                        }
                    }
                }
                .onDisappear() {
                    articleDisplayText = ""
                }
                
                if (isLoadingArticle) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.gray))
                }
                
                else {
                    VStack {
                        VStack {
                            Text("Article of the Day:")
                                .font(.system(size: 20, weight: .heavy, design: .default))
                                .frame(alignment: .center)
                                .padding()
                            
                            Text(aoftdTitle)
                                .font(.system(size: 20, weight: .semibold, design: .default))
                                .padding(.bottom, 5)
                            Text(aoftdShort)
                                .font(.caption)
                                .foregroundColor(Color.gray)
                            
                            Text(aoftdDescription)
                                .padding()
                                .frame(width: 300, height: 200, alignment: .center)
                                .truncationMode(.tail)
                            
                            NavigationLink {
                                PageView(term: aoftdTitle)
                            } label: {
                                Text("Read More...")
                                    .frame(width: 130, height: 30, alignment: .center)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding()
                        }
                        .background(RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("DailyArticleBG"))
                            .padding([.leading, .trailing], -28)
                        )
                        
                        VStack {
                            Text("Top Articles")
                                .font(.system(size: 20, weight: .heavy, design: .default))
                                .frame(alignment: .center)
                                .padding()
                            Text("These are the top five articles trending on Wikipedia currently.")
                                .multilineTextAlignment(.center)
                                .padding()
                            MostReadArticles()
                                .frame(width:300, height:300, alignment: .center)
                        }
                        .background(RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("DailyArticleBG"))
                            .frame(width:355)
                            .padding([.leading, .trailing], -28)
                        )
                        VStack {
                            Text("Visit a random article:")
                                .padding(.top, 20)
                            NavigationLink {
                                PageView(term:randomArticle())
                            } label: {
                                Text("Random Article")
                                    .frame(width: 130, height: 30, alignment: .center)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.bottom, 20)
                        }
                        .background(RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("DailyArticleBG"))
                            .frame(width:355)
                            .padding([.leading, .trailing], -28)
                        )
                    }
                }
                
            }
            
            .navigationTitle("Wikipedia")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        PageView(term: wikiSearch)
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
        }
        .onAppear() {
            self.fetchDailyWiki()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
