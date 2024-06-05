//
//  ProfileView.swift
//  BonVoyage
//
//  Created by Christian Romero
//

import Foundation
import SwiftUI

struct ProfileView: View {
    
    @StateObject var healthManager = HealthManager()

    var body: some View {
        
        NavigationView {
            
            ScrollView {
                
                VStack {
                    
                    Image(systemName: "heart.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .padding(22)
                        .padding(.top, 10)
                        .foregroundColor(.red)
                    
                    Text("Datos de salud")
                        .font(.title)
                        .fontWeight(.bold)
                        .offset(x:0)
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
                VStack {
                    
                    Text("Corazón")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading, 20)
                        .padding(.top, 30)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                
                VStack {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("Frecuencia cardiaca")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    .frame(alignment: .leading)
                    .padding(.leading, 25)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.top, 25)
                    
                HStack{
                    Text("\(Int(healthManager.userHeartRate))")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("LPM")
                        .font(.system(size:20))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .offset(y:3)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.leading, 25)
                
                VStack {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("Variabilidad de la frecuencia")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    .frame(alignment: .leading)
                    .padding(.leading, 25)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.top, 25)
                    
                HStack{
                    Text("\(Int(healthManager.userHeartRateVariability))")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("ms")
                        .font(.system(size:20))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .offset(y:3)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.leading, 25)
                
                VStack {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("Frecuencia en reposo")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    .frame(alignment: .leading)
                    .padding(.leading, 25)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.top, 25)
                    
                HStack{
                    Text("\(Int(healthManager.userRestingHeartRate))")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("LPM")
                        .font(.system(size:20))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .offset(y:3)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.leading, 25)
                
            }
        }
        
        
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
