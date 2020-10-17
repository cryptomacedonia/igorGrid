//
//  ContentView.swift
//  igorGrid
//
//  Created by Igor Jovcevski on 10/13/20.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab: Int = 0
    @State var data: [RowData] = [

        RowData(id: "1", active: false, itemArray: [Item(id: "1-2", fullScreen: false, name: "two", imageUrl: "1"), Item(id: "1-3", fullScreen: false, name: "three", imageUrl: "2"), Item(id: "1-4", fullScreen: false, name: "five", imageUrl: "3"), Item(id: "1-5", fullScreen: false, name: "six", imageUrl: "4"), Item(id: "1-6", fullScreen: false, name: "seven", imageUrl: "5")]),
        RowData(id: "1", active: false, itemArray: [Item(id: "1-2", fullScreen: false, name: "five", imageUrl: "6"), Item(id: "1-3", fullScreen: false, name: "three", imageUrl: "7"), Item(id: "1-4", fullScreen: false, name: "five", imageUrl: "8"), Item(id: "1-5", fullScreen: false, name: "six", imageUrl: "9"), Item(id: "1-6", fullScreen: false, name: "seven", imageUrl: "10")]),
        RowData(id: "1", active: false, itemArray: [Item(id: "1-2", fullScreen: false, name: "one", imageUrl: "11"), Item(id: "1-3", fullScreen: false, name: "three", imageUrl: "12"), Item(id: "1-4", fullScreen: false, name: "five", imageUrl: "13"), Item(id: "1-5", fullScreen: false, name: "six", imageUrl: "14"), Item(id: "1-6", fullScreen: false, name: "seven", imageUrl: "15")])

    ]

    var body: some View {

        MatrixView(matrixData: $data).padding(.top, 0).background(Color.white)


    }
}

struct MatrixView: View {
    @Binding var matrixData: [RowData]
    @State var selectedTab: Int = 0
    @Namespace var animationNamespace
    @State var goingBack: Bool = false
    var body: some View {
        ZStack {
            ScrollView (.vertical) {
                VStack {

                    ForEach(matrixData.indices, id: \.self) { index in

                        return rowView(animationNamespace: animationNamespace, matrixData: $matrixData, rowData: $matrixData[index], rowIndex: index, selectedTab: $selectedTab, goingBack: $goingBack)

                    }

                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).zIndex(1)

            }

            ForEach(matrixData.indices, id: \.self) { index in

                ForEach(matrixData[index].itemArray.indices, id: \.self) { subIndex in
                    return matrixData[index].itemArray[subIndex].fullScreen ?
                    VStack {
                        Image(matrixData[index].itemArray[subIndex].imageUrl).resizable() .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .matchedGeometryEffect(id: "\(index)-\(subIndex)", in: animationNamespace, properties: .frame).zIndex(100)

                    }: nil

                }

            }.zIndex(100)


            ForEach(matrixData.indices, id: \.self) { index in


                matrixData[index].active ? self.createTabViews(index: index

) : nil




            }.zIndex(101)



        }
    }

    func createTabViews(index: Int) -> some View {


        print ("create tab subviews...")


        return matrixData[index].active ? TabView (selection: $selectedTab) {


            ForEach(matrixData[index].itemArray.indices, id: \.self) { subIndex in
                VStack {
                    Image(matrixData[index].itemArray[subIndex].imageUrl).resizable().frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)

                }

                    .tabItem {

                        VStack {
                            Text("one")

                        }
                    }.tag(subIndex
                    )
            }


        }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)).background(Color.white)
            .tabViewStyle(PageTabViewStyle()).onAppear(perform: {
                let currentSelectedTab = matrixData[index].itemArray.indices.filter { matrixData[index].itemArray[$0].active == true }
                selectedTab = currentSelectedTab.first ?? 0


            }).onTapGesture(count: 1, perform: {






                for (itemIndex, _) in matrixData[index].itemArray.enumerated() {
                    matrixData[index].itemArray[itemIndex].fullScreen = itemIndex
                        == selectedTab
                    matrixData[index].itemArray[itemIndex].active = itemIndex
                        == selectedTab
                }


                //           DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                //
                //           }
                goingBack = true
                matrixData[index].wasActiveRecently = true
                withAnimation(.spring())
                {

                    matrixData[index].active = false
                    matrixData[index].itemArray[selectedTab].fullScreen = false

                }


                //            }


            }): nil

    }

}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct rowView: View {
    var animationNamespace: Namespace.ID
    @Binding var matrixData: [RowData]
    @Binding var rowData: RowData
    var rowIndex: Int
    @Binding var selectedTab: Int
    @Binding var goingBack: Bool
    var body: some View {

        ScrollView (.horizontal) {
            ScrollViewReader { geometry in
                HStack {
                    ForEach(rowData.itemArray.indices, id: \.self) { index in

                        ItemView(item: $rowData
                                .itemArray[index], animationNamespace: animationNamespace, index: rowIndex, subIndex: index).padding(5).onTapGesture(count: 1, perform: {
                            withAnimation(Animation.spring()
                            )
                            {
                                rowData.itemArray[index].toggleFullScreen()

                            }
                            goingBack = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                //                                        print("setting up data for tab..")
                                matrixData = matrixData.map { var temp = $0 ; temp.active = false ; return temp; }
                                selectedTab = index
                                matrixData[rowIndex].active = true // heres issue!!!
                                matrixData[rowIndex].itemArray = matrixData[rowIndex].itemArray.map { var temp = $0 ; temp.active = false ; return temp; }

                                matrixData[rowIndex].itemArray[index].active = true
                            }
                        })

                    }
                }.onChange(of: selectedTab, perform: { value in

                })
                    .onChange(of: goingBack, perform: { value in
                        print("rowdata active:", rowData.active)
                        print("goingback:", value)
                        if rowData.wasActiveRecently && value == true {
                            rowData.wasActiveRecently.toggle()
                            withAnimation(.spring()) {
                                geometry.scrollTo(min(selectedTab, rowData.itemArray.count - 1))

                            }
                        }
                    })
            }

        }

    }

}




struct RowData {
    var id: String = UUID().uuidString
    var active: Bool = false
    var wasActiveRecently: Bool = false

    var itemArray: [Item] = []
}

struct Item {
    var id: String
    var fullScreen: Bool
    var active: Bool = false
    var name: String
    var imageUrl: String

    mutating func toggleFullScreen() {
        self.fullScreen.toggle()
    }

}

struct ItemView: View {

    @Binding var item: Item
    var animationNamespace: Namespace.ID
    var index: Int
    var subIndex: Int

    var body: some View {

        VStack {
            Image(item.imageUrl).resizable()
                .aspectRatio(contentMode: .fill)
                .cornerRadius(10).matchedGeometryEffect(id: "\(index)-\(subIndex)", in: animationNamespace)
        }.frame(width: 160, height: 220, alignment: .center).cornerRadius(10)



    }
}
