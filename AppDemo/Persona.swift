//
//  Persona.swift
//  AppDemo
//
//  Created by adminisitradorUTM on 09/12/16.
//  Copyright © 2016 IntegraIT. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Persona {
    
    class func fetch() -> NSFetchRequest<Persona> {
        return fetchRequest()
    }
    
    class func agregarTodos(datos: [Dictionary<String, Any?>]) -> (agregados: Int, modificados: Int, errores: Int) {
        var agregados = 0
        var modificados = 0
        var errores = 0
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        for dato in datos {
            let id = dato["id"] as? Int ?? -1
            let nombre = dato["nombre"] as? String ?? ""
            let edad = dato["edad"] as? Int ?? -1
            let genero = dato["genero"] as? String ?? ""
            let foto = dato["foto"] as? String ?? ""
            
            if id == -1 {
                errores = errores + 1
            } else {
                let persona = selectId(id: id) ?? Persona(context: context)
            
                persona.nombre = nombre
                persona.edad = Int16(edad)
                persona.genero = genero
                persona.foto = foto
            
                do {
                    if persona.isUpdated {
                        print("Actualizando dato: \(nombre)")
                        modificados = modificados + 1
                    } else {
                        print("Agregando dato: \(nombre)")
                        agregados = agregados + 1
                    }
                    
                    try context.save()
                    
                } catch {
                    errores = errores + 1
                    print("Error guardando \(nombre)")
                }
            }
        }
        
        return (agregados, modificados, errores)
    }
    
   
    class func selectTodos() -> [Persona] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request = Persona.fetch()
        let sort = NSSortDescriptor(key: "edad", ascending: true)
        
        request.sortDescriptors = [sort]
        
        var personas = [Persona]()
        
        do {
            personas = try context.fetch(request) as [Persona]
        } catch {
            print("Error con la consulta. \(error)")
        }
        
        return personas
    }
    
    
    class func selectNombre(nombre: String) -> [Persona] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request = Persona.fetch()
        
        let predicado = NSPredicate(format: " nombre == %@ ", nombre)
        request.predicate = predicado
        
        var personas = [Persona]()
        
        do {
            personas = try context.fetch(request) as [Persona]
        } catch {
            print("Error con la consulta. \(error)")
        }
        
        return personas
    }

    
    class func selectId(id: Int) -> Persona? {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request = Persona.fetch()
        
        let predicado = NSPredicate(format: " id == %ld ", id)
        request.predicate = predicado
        
        var personas = [Persona]()
        
        do {
            personas = try context.fetch(request) as [Persona]
        } catch {
            print("Error con la consulta. \(error)")
        }
        
        return personas.first!
    }
}
