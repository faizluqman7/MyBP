//
//  ContentView.swift
//  MyBP
//
//  Created by Faiz Luqman on 23/11/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var topnumberinput: String = ""
    @State private var bottomnumberinput: String = ""
    @State private var newdate = Date()
    @State private var showingAlert: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationView {
            VStack{
                HStack{
                    Text("Enter Reading").padding()
                    TextField("Systolic", text: $topnumberinput).keyboardType(.numberPad).padding()
                    TextField("Diastolic", text: $bottomnumberinput).keyboardType(.numberPad).padding()
                }
                Button {
                    addItem()
                } label: {
                    Text("Add Reading")
                }.alert("Enter a valid number first!", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            //after tapping in theeach one record
                            VStack{
                                Text("Update Records").bold().font(.system(.title))
                                
                                HStack{
                                    Text("Systolic").padding()
                                    TextField("First number", text: $topnumberinput).keyboardType(.numberPad).padding()
                                }
                                
                                HStack{
                                    Text("Diastolic").padding()
                                    TextField("Second Number", text: $bottomnumberinput).keyboardType(.numberPad).padding()
                                }
                                
                                DatePicker("Date", selection: $newdate).padding()
                                Button {
                                    updateItems(item)
                                    hideKeyboard()
                                } label: {
                                    Text("Update Readings")
                                }
                                
                                Spacer()
                                
                                Text("Latest Readings").bold().font(.system(.headline))
                                Text("Date: \(item.timestamp!, formatter: itemFormatter)")
                                Text("Upper: \(item.uppernumber) \nLower: \(item.lowernumber)")
                                Spacer()

                            }
                        } label: {
                            Text("SYS \n **\(item.uppernumber)**") .padding().multilineTextAlignment(.center)
                            Text("DIA \n **\(item.lowernumber)**") .padding().multilineTextAlignment(.center)
                            Text(item.timestamp!, formatter: itemFormatter)
                        }//.navigationTitle(Text("BP Tracker"))
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }.navigationTitle(Text("BP Tracker"))
        }
        
    }

    private func addItem() {
        withAnimation {
            if self.topnumberinput != ""{
                if self.bottomnumberinput != ""{
                    let newItem = Item(context: viewContext)
                    newItem.timestamp = Date()

                    newItem.uppernumber = Int64(self.topnumberinput) ?? 0
                    newItem.lowernumber = Int64(self.bottomnumberinput) ?? 0
                    
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }

                }
                else{
                    self.showingAlert = true
                }
            }
            else{
                self.showingAlert = true
            }
            self.hideKeyboard()

        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func updateItems(_ items: FetchedResults<Item>.Element){
        withAnimation {
            items.timestamp = newdate
            items.lowernumber = Int64(self.bottomnumberinput) ?? 0
            items.uppernumber = Int64(self.topnumberinput) ?? 0
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    formatter.dateFormat = "dd/MM/yyyy HH:mm"
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
