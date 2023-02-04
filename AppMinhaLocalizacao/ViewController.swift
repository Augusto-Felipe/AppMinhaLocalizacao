//
//  ViewController.swift
//  AppMinhaLocalizacao
//
//  Created by Felipe Augusto Correia on 04/02/23.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapa: MKMapView!
    
    @IBOutlet var velocidadeLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var enderecoLabel: UILabel!
    
    var gerenciadorDeLocalizacao = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gerenciadorDeLocalizacao.delegate = self
        gerenciadorDeLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorDeLocalizacao.requestWhenInUseAuthorization()
        gerenciadorDeLocalizacao.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        // Aqui peguei a ultima localização que está sendo atualizada e joguei nas labels
        let localizacaoUsuario = locations.last!
        
        let longitude = localizacaoUsuario.coordinate.longitude
        let latitude = localizacaoUsuario.coordinate.latitude
        let velocidade = localizacaoUsuario.speed

        longitudeLabel.text = String(longitude)
        latitudeLabel.text = String(latitude)
        velocidadeLabel.text = String(velocidade)
        
        
        // Aqui vou mostrar no mapa a região aonde o usuário se encontra
        let localizacao: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Zoom
        let latitudeDelta: CLLocationDegrees = 0.01
        let longitudeDelta: CLLocationDegrees = 0.01
        
        let visualizacao: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        
        // Região -> zoom + localização
        let regiao: MKCoordinateRegion = MKCoordinateRegion(center: localizacao, span: visualizacao)
        
        
        // Agora baseado na nossa localização(alt e long) vamos recuperar o endereço
        CLGeocoder().reverseGeocodeLocation(localizacaoUsuario) { detalhesLocal, erro in
            
            if erro == nil {
                
                if let dadosLocal = detalhesLocal?.first {
                    
                    var thoroughfare = ""
                    if dadosLocal.thoroughfare != nil {
                        thoroughfare = dadosLocal.thoroughfare!
                    }
                    
                    var subThoroughfare = ""
                    if dadosLocal.subThoroughfare != nil {
                        subThoroughfare = dadosLocal.subThoroughfare!
                    }
                    
                    var locality = ""
                    if dadosLocal.locality != nil {
                        locality = dadosLocal.locality!
                    }
                    
                    var subLocality = ""
                    if dadosLocal.subLocality != nil {
                        subLocality = dadosLocal.subLocality!
                    }
                    
                    var postalCode = ""
                    if dadosLocal.postalCode != nil {
                        postalCode = dadosLocal.postalCode!
                    }
                    
                    var country = ""
                    if dadosLocal.country != nil {
                        country = dadosLocal.country!
                    }
                    
                    var administrativeArea = ""
                    if dadosLocal.administrativeArea != nil {
                        administrativeArea = dadosLocal.administrativeArea!
                    }
                    
                    var subAdministrativeArea = ""
                    if dadosLocal.subAdministrativeArea != nil {
                        subAdministrativeArea = dadosLocal.subAdministrativeArea!
                    }
                    
                    self.enderecoLabel.text = thoroughfare + " - " + subThoroughfare + " / " + locality + " / " + country
                
                }
            } else {
                print(erro)
            }
            
        }
        
        // Seta a região no mapa
        self.mapa.setRegion(regiao, animated: true)
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .authorizedWhenInUse {
            
            let alert = UIAlertController(title: "Permissão de Localização", message: "É necessário a permissão de localização para poder usar o app.", preferredStyle: UIAlertController.Style.alert)
            
            let permitir = UIAlertAction(title: "Permitir", style: UIAlertAction.Style.default, handler: { (alertaConfiguracoes) in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            })
            
            let cancelar = UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil)
            
            alert.addAction(permitir)
            alert.addAction(cancelar)
            
            present(alert, animated: true , completion: nil)
            
        } else {
            print("Autorizado.")
        }
    }
}


