//
//  ContentView.swift
//  CoreDataRelationships
//
//  Created by Christian Skorobogatow on 7/7/22.
//

import SwiftUI
import CoreData

class CoreDataManager {
    
    static let instance = CoreDataManager()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "CoreDataContainer")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core data \(error)")
            }
        }
        context = container.viewContext
    }
    
    func save() {
        do {
            try context.save()
            print("Saved succesfully!")
        } catch let error {
            print("Error saving Core Data: \(error.localizedDescription)")
        }
    }
    
}

class CoreDataRelationshipViewModel: ObservableObject {
    
    let manager = CoreDataManager.instance
    
    @Published var businesses: [BusinenessEntity] = []
    @Published var departments: [DepartmentEntity] = []
    @Published var employees: [EmployeeEntity] = []
    
    
    init() {
        getBusinesses()
        getDepartments()
        getEmployess()
    }
    
    func getBusinesses() {
        let request = NSFetchRequest<BusinenessEntity>(entityName: "BusinenessEntity")
        
        let sort = NSSortDescriptor(keyPath: \BusinenessEntity.name, ascending: true)
        request.sortDescriptors = [sort]
        
        
//        let filter = NSPredicate(format: "name == %@", "Apple")
//        request.predicate = filter

        
        do {
            businesses = try manager.context.fetch(request)
            
        } catch let error {
            print("Error fetching: \(error)")
        }
    }
        
    func getDepartments() {
        let request = NSFetchRequest<DepartmentEntity>(entityName: "DepartmentEntity")
        
        
        do {
            departments = try manager.context.fetch(request)
            
        } catch let error {
            print("Error fetching: \(error)")
        }
    }
    
    func getEmployess() {
        let request = NSFetchRequest<EmployeeEntity>(entityName: "EmployeeEntity")
        
        
        do {
            employees = try manager.context.fetch(request)
            
        } catch let error {
            print("Error fetching: \(error)")
        }
    }
    
    func getEmployess(forBusiness business: BusinenessEntity) {
        let request = NSFetchRequest<EmployeeEntity>(entityName: "EmployeeEntity")
        
        let filter = NSPredicate(format: "business == %@",  business)
        request.predicate = filter
        
        
        do {
            employees = try manager.context.fetch(request)
            
        } catch let error {
            print("Error fetching: \(error)")
        }
    }
    
    func updateBusiness() {
        let existingBusineness = businesses[2]
        existingBusineness.addToDepartments(departments[1])
        save()
        
    }
    
    func addBusiness() {
        let newBusiness = BusinenessEntity(context: manager.context)
        newBusiness.name = "Facebook"
        
        // add existing departments to the new business
//        newBusiness.departments = [departments[0], departments[1]]
        
        
        //add exisiting employess to the new business
//        newBusiness.employees = [employees[1]]
        
        //add new business to existing department
        //        newBusiness.addToDepartments()
        
        
        // new business to exisiting employee
        //        newBusiness.addToEmployees()
        
        save()
    }
    
    func addDepartment() {
        let newDepartment = DepartmentEntity(context: manager.context)
        newDepartment.name = "Finance"
        newDepartment.businesses = [businesses[0] , businesses[1], businesses[2]]
        newDepartment.addToEmployees(employees[1])
        
        
//        newDepartment.employees = [employees[1]]
        newDepartment.addToEmployees(employees[1])
        save()
    }
    
    func addEmployee() {
        
        let newEmployee = EmployeeEntity(context: manager.context)
        newEmployee.name = "John"
        newEmployee.age = 21
        newEmployee.dateJoined = Date()
        newEmployee.business = businesses[2]
        newEmployee.department = departments[1]
        
//        newEmployee.business = businesses[0]
//        newEmployee.department = departments[0]
        save()
    }
    
    func deleteDepartment() {
        let department = departments[1]
        manager.context.delete(department)
        save()
    }

    func save() {
        businesses.removeAll()
        departments.removeAll()
        employees.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.manager.save()
            self.getBusinesses()
            self.getDepartments()
            self.getEmployess()
        }
    }
}

struct ContentView: View {
    
    @StateObject var vm = CoreDataRelationshipViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    Button {
                        vm.addBusiness()
                    } label: {
                        Text("Add Business")
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .cornerRadius(10)
                            .padding()
                        
                    }
                    
                    Button {
                        vm.deleteDepartment()
                    } label: {
                        Text("Add Department")
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .cornerRadius(10)
                            .padding()
                        
                    }
                    
                    Button {
                        vm.addEmployee()
                    } label: {
                        Text("Add Employee")
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .cornerRadius(10)
                            .padding()
                        
                    }
                    
                    
                    ScrollView(.horizontal, showsIndicators: true){
                        HStack(alignment: .top) {
                            ForEach(vm.businesses) { business in
                                BusinessView(entity: business)
                            }
                        }
                    }
                    .padding()
                    
                    ScrollView(.horizontal, showsIndicators: true){
                        HStack(alignment: .top) {
                            ForEach(vm.departments) { department in
                                DepartmentView(entity: department)
                            }
                        }
                    }
                    .padding()
                    
                    
                    ScrollView(.horizontal, showsIndicators: true){
                        HStack(alignment: .top) {
                            ForEach(vm.employees) { employee in
                                EmployeeView(entity: employee)
                            }
                        }
                    }
                    .padding()
                    
                    
                }
                .navigationTitle("Relationships")
            }
        }
    }
}


struct BusinessView: View {
    let entity: BusinenessEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20){
            Text("Name: \(entity.name ?? "")")
                .bold()
            
            if let departments = entity.departments?.allObjects as? [DepartmentEntity] {
                Text("Departments:")
                    .bold()
                
                ForEach(departments) { department in
                    Text(department.name ?? "")
                }
            }
            
            if let employees = entity.employees?.allObjects as? [EmployeeEntity] {
                Text("Employees:")
                    .bold()
                
                ForEach(employees) { employee in
                    Text(employee.name ?? "")
                }
            }
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(.gray.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}


struct DepartmentView: View {
    let entity: DepartmentEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20){
            Text("Name: \(entity.name ?? "")")
                .bold()
            
            if let businesses = entity.businesses?.allObjects as? [BusinenessEntity] {
                Text("Businesses:")
                    .bold()
                
                ForEach(businesses) { business in
                    Text(business.name ?? "")
                }
            }
            
            if let employees = entity.employees?.allObjects as? [EmployeeEntity] {
                Text("Employees:")
                    .bold()
                
                ForEach(employees) { employee in
                    Text(employee.name ?? "")
                }
            }
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(.green.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}


struct EmployeeView: View {
    let entity: EmployeeEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20){
            Text("Name: \(entity.name ?? "")")
                .bold()
            
            Text("Age: \(entity.age)")
            Text("Date Joined: \(entity.dateJoined ?? Date())")
            
            
            Text("Business:")
                .bold()
            
            Text(entity.business?.name ?? "")
                
            
            Text("Department:")
                .bold()
            
            Text(entity.department?.name ?? "")
                
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(.blue.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
