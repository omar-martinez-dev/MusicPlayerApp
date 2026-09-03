//
//  PlaylistListCell.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/21/24.
//

import SwiftUI

struct PlaylistListCell: View {
    
    var playlist: PlaylistType
    
    func calculateOffset(offset: Int, iteration: Int) -> Int {
        return (iteration - 1) * offset
    }
    
    var body: some View {
        HStack(alignment: .center) {
            ZStack(alignment: .leading) {
                ForEach(0..<3) { x in
                    PlaylistIcon()
                        .offset(
                            x: CGFloat(calculateOffset(offset: 6, iteration: x)),
                            y: CGFloat(calculateOffset(offset: 6, iteration: x)))
                }
            }
            
            VStack(alignment:.leading) {
                Text(playlist.title)
                    .font(.title3)
                    .lineLimit(2)
                
                Spacer()
                
                Text("\(playlist.trackList.count)" + " tracks")
                    .font(.caption)
            }
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
    }
}

struct PlaylistIcon: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(.gray.gradient)
            .frame(width: 46, height: 46)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.black)
                    .frame(width: 48, height: 48)
            }
       
        .overlay {
            VStack {
                Image(.musicNoteIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
        }
    }
}

//#Preview {
//    PlaylistListCell()
//}
