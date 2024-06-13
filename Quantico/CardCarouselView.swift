//
//  CardCarouselView.swift
//  Quantico
//
//  Created by Yaochen Liu on 2024/6/7.
//

import SwiftUI

struct CardCarouselView: View {
    @State var stories = [
        Story(id: 0, color: .red, offset: 0, title: "Card #1"),
        Story(id: 1, color: .blue, offset: 0, title: "Card #2"),
        Story(id: 2, color: .purple, offset: 0, title: "Card #3"),
        Story(id: 3, color: .yellow, offset: 0, title: "Card #4"),
        Story(id: 4, color: .pink, offset: 0, title: "Card #5"),
    ]
    
    @State var scrolled = 0

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "gear")
                            .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .renderingMode(.template)
                            .foregroundColor(.white)
                    }
                }.padding()
                
                HStack {
                    Text("Trending")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    
                    Button {
                        
                    }label: {
                        Image(systemName: "ellipsis")
                            .renderingMode(.template)
                            .foregroundColor(.white)
                    }
                }.padding()
                // Card View ...
                
                ZStack {
                    // Zstack will overlap views so last will become first ...
                    ForEach(stories.reversed()) { story in
                        HStack {
                            VStack{
                                Text(story.title)
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            // dynamic frame ...
                            // dynamic  height ...
                            .frame(width: calculateWidth(), height:
                                    (UIScreen.main.bounds.height / 1.8) - CGFloat(story.id  - scrolled * 50))
                            .background(story.color)
                            .cornerRadius(15)
                            // based on scrolled chaning view size ...
                            
                            .offset(x: story.id - scrolled <= 2 ? CGFloat(story.id - scrolled)
                                                               * 30 : 60)
                        }
                        .contentShape(Rectangle())
                        // addding gesture ...
                        .offset(x: story.offset)
                        .gesture(DragGesture().onChanged({ (value) in
                            withAnimation{
                                // disabling drag for last card ...
                                if value.translation.width < 0 && story.id != stories.last!.id{
                                    stories[story.id].offset = value.translation.width
                                }else {
                                    // restoring cards ...
                                    if story.id > 0 {
                                        stories[story.id - 1].offset = -(calculateWidth() + 60) + value.translation.width
                                    }
                                }
                            }
                        }).onEnded(({(value) in
                            withAnimation {
                                if value.translation.width < 0 {
                                    if value.translation.width < -180 && story.id != stories.last!.id{
                                        
                                        // moving view away
                                        stories[story.id].offset = -(calculateWidth() + 60)
                                        scrolled += 1
                                    }
                                    else {
                                        stories[story.id].offset = 0
                                    }
                                }else {
                                    // restoring card ...
                                    if story.id > 0 {
                                        if value.translation.width > 180 {
                                            stories[story.id - 1].offset = 0
                                            scrolled -= 1
                                        }else {
                                            stories[story.id - 1].offset = -(calculateWidth() + 60)
                                        }
                                    }
                                        
                                }
                            }
                        })))
                        Spacer(minLength: 0)
                    }
                }
                // max height ...
                .frame(height: UIScreen.main.bounds.height / 1.8)
                .padding(.horizontal, 25)
                
                Spacer()
            }
        }.background(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.black]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
        )
    }
    
    func calculateWidth() -> CGFloat {
        // horizontal padding 30
        let screen = UIScreen.main.bounds.width - 30
        
        
        // going to show first 3 cards
        // all other will be hidden
        
        // 2nd and 3rd will be moved x axis with 30 vals
        let width = screen - (2 * 30)
        return width
    }
}

// Sampled data

struct Story: Identifiable {
    var id: Int
    var color: Color
    var offset: CGFloat
    var title: String
}



#Preview {
    CardCarouselView()
}
