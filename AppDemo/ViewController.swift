//
//  ViewController.swift
//  AppDemo
//
//  Created by STI on 05/12/16.
//  Copyright © 2016 IntegraIT. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DetalleViewControllerDelegate, AgregarViewCotrollerDelegate {
    
    var rootRef: FIRDatabaseReference?
    
    var datos = [("Luis", 30), ("Kike", 28)]
    var arreglo: [(nombre: String, edad: Int, genero: String, foto: String)] = []
    var filaSeleccionada = -1
    var esEdicion = false
    
    @IBOutlet weak var uiProfileImage: UIImageView!
    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var tblTabla: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let idFacebook = FBSDKAccessToken.current().userID
        let cadenaUrl = "http://graph.facebook.com/\(idFacebook!)/picture?type=large"
        let url = URL(string: cadenaUrl)
        let dato: Data?
        
        do {
            dato = try Data(contentsOf: url!)
            uiProfileImage.image = UIImage(data: dato!)
        } catch {
            print("Error cargando la imagen.! \(error.localizedDescription)")
            dato = nil
            uiProfileImage.image = UIImage(named: "gato.jpg")
            
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        rootRef = FIRDatabase.database().reference()
        
        sincronizar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.rootRef!.child("base").observe(.value, with: {
            (snap: FIRDataSnapshot) in self.lblNombre.text = "\(snap.value!)"
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnAgregar_Click(_ sender: Any) {
        performSegue(withIdentifier: "Agregar Segue", sender: self)
    }

    
    @IBAction func btnRefresh_Click(_ sender: Any) {
        let valor = Int(lblNombre.text!)!
        rootRef?.child("base").setValue(valor + 1)
    }
    
    func numeroCambiado(numero: Int) {
        print("Numero cambiado: \(numero)")
        
        datos[numero].1 = datos[numero].1 + 1

        tblTabla.reloadData()
    }
    
    func agregarRegistro(nombre: String, edad: Int) {
        datos.append((nombre, edad))
        
        tblTabla.reloadData()
    }
    
    func modificarRegistro(nombre: String, edad: Int, fila: Int) {
        datos.remove(at: fila)
        datos.insert((nombre, edad), at: fila)
        tblTabla.reloadData()
    }
    //MARK: - UIViewDelegates
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        switch segue.identifier! {
        case "Detalle Segue":
            let view = segue.destination as! DetalleViewController
            
            view.numeroFila = filaSeleccionada
            view.dato = datos[filaSeleccionada].0
            view.datoNumero = datos[filaSeleccionada].1
            
            view.delegado = self
            break
            
        case "Agregar Segue":
            let view = segue.destination as! AgregarViewController
            
            if(esEdicion){
                view.fila = filaSeleccionada
                view.nombre = datos[filaSeleccionada].0
                view.edad = datos[filaSeleccionada].1
                esEdicion = false
            }
            
            view.delegado = self
            break
            
        default:
            break
        }
        
    }
    
    //MARK: - TableViewDelegates
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arreglo.count
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let eliminar = UITableViewRowAction(style: .destructive, title: "Borrar", handler: borrarFila)
        let editar = UITableViewRowAction(style: .normal, title: "Editar", handler: editarFila)
        
        return [eliminar, editar]
    }
    
    func borrarFila(sender: UITableViewRowAction, indexPath: IndexPath){
        datos.remove(at: indexPath.row)
        tblTabla.reloadData()
    }
    
    func editarFila(sender: UITableViewRowAction, indexPath: IndexPath){
        esEdicion = true
        filaSeleccionada = indexPath.row
        performSegue(withIdentifier: "Agregar Segue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        //let proto = (indexPath.row % 2 == 0) ? "proto1" : "proto2"
        
        
        let view = tableView.dequeueReusableCell(withIdentifier: "proto1", for: indexPath) as! FilaTableViewCell
        
        //if(indexPath.row % 2 == 0){
       //     vista.lblIzquierda.text = datos[indexPath.row].0
        //} else {
          //  vista.lblIzquierda.text = datos[indexPath.row].0
           // vista.lblDerecha.text = "\(datos[indexPath.row].1)"
        //}
        
        let dato = arreglo[indexPath.row]
        
        view.lblIzquierda.text = "\(dato.nombre)"
        view.lblDerecha.text = "\(dato.edad)"
        
        if(dato.genero == "m") {
            view.imgFoto.image = UIImage(named: "user_female")
        } else {
            view.imgFoto.image = UIImage(named: "user_male")
        }
        
        view.imgFoto.downloadData(url: dato.foto)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Detalle Segue
        filaSeleccionada = indexPath.row
        performSegue(withIdentifier: "Detalle Segue", sender: self)
    }
    
    func sincronizar(){
        
        let url = URL(string: "http://kke.mx/demo/contacto.php")
        
        var request = URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 1000)
        
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            guard (error == nil) else{
                print ("Ocurrio un error con la peticion: \(error)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                print("Ocurrio un error con la respuesta")
                return
            }
            
            if (!(statusCode >= 200 && statusCode <= 299)) {
                print("Respuesta no valida")
                return
            }
            
            let cad = String(data: data!, encoding: .utf8)
            print("Response: \(response!.description)")
            print("Error: \(error)")
            print("Data: \(cad!)")
            
            var parsedResult: Any!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            } catch {
                parsedResult = nil
                print("Error: \(error)")
                return
            }
            
            guard let datos = (parsedResult as? Dictionary<String, Any?>)?["datos"] as? [Dictionary<String, Any>]! else {
                print("Error: \(error)")
                return
            }
            
            self.arreglo.removeAll()
            
            for d in datos {
                let nombre = (d["nombre"] as! String)
                let edad = (d["edad"] as! Int)
                let foto = (d["foto"] as! String)
                let genero = (d["genero"] as! String)
                
                self.arreglo.append(nombre: nombre, edad: edad, genero: genero, foto: foto)
            }
        
            self.tblTabla.reloadData()
        })
        
        task.resume()
    }
}

