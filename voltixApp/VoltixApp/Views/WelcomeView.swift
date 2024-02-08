//
//  WelcomeView.swift
//  VoltixApp
//

import SwiftUI

struct WelcomeView: View {
    @Binding var presentationStack: Array<CurrentScreen>
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        #if os(iOS)
            welcomeSmallScreen(presentationStack: $presentationStack)
        #else
            welcomeLargeScreen(presentationStack: $presentationStack)
        #endif
    }
}

struct welcomeSmallScreen: View {
    @Binding var presentationStack: Array<CurrentScreen>
    
    var body: some View {
        VStack(alignment: .center) {
            HeaderView(
              rightIcon: "",
              leftIcon: "",
              head: "VOLTIX",
              leftAction: {},
              rightAction: {}
            )
            Logo(width: 100, height: 100)
            Text("SECURE CRYPTO VAULT")
              .font(Font.custom("Menlo", size: 20).weight(.bold))
              .lineSpacing(30)
              .foregroundColor(.black)
            ZStack() {
            Text("TWO FACTOR AUTHENTICATION")
              .font(Font.custom("Menlo", size: 20))
              .lineSpacing(30)
              .foregroundColor(.black)
              .offset(x: 0, y: -106.47)
            Text("SECURE, TRUSTED DEVICES")
              .font(Font.custom("Menlo", size: 20))
              .lineSpacing(30)
              .foregroundColor(.black)
              .offset(x: -0, y: -63.40)
            Text("FULLY SELF-CUSTODIAL")
              .font(Font.custom("Menlo", size: 20))
              .lineSpacing(30)
              .foregroundColor(.black)
              .offset(x: -0, y: -23.13)
            Text("NO TRACKING, NO REGISTRATION")
              .font(Font.custom("Menlo", size: 20))
              .lineSpacing(30)
              .foregroundColor(.black)
              .offset(x: -0, y: 19.94)
            Text("FULLY OPEN-SOURCE")
              .font(Font.custom("Menlo", size: 20))
              .lineSpacing(30)
              .foregroundColor(.black)
              .offset(x: -0, y: 63)
            Text("AUDITED")
              .font(Font.custom("Menlo", size: 20))
              .lineSpacing(30)
              .foregroundColor(.black)
              .offset(x: -0, y: 106.07)
            }
            .frame(width: 430, height: 256)
            .offset(x: 0, y: 19)
            Spacer()
            BottomBar(content: "START", onClick: {
                self.presentationStack.append(.startScreen)
            })
        }
        .frame(minWidth:0, maxWidth:.infinity, minHeight:0, maxHeight:.infinity, alignment: .top)
            .background(.white);
    }
}

struct welcomeLargeScreen: View {
    @Binding var presentationStack: Array<CurrentScreen>
    @State private var topPadding:CGFloat = 4;
    
    var body: some View {
        VStack(alignment: .center) {
            HeaderView(
              rightIcon: "",
              leftIcon: "",
              head: "VOLTIX",
              leftAction: {},
              rightAction: {}
            )
            Logo(width: 200, height: 200)
            Text("SECURE CRYPTO VAULT")
              .font(Font.custom("Menlo", size: 40).weight(.bold))
              .padding(.top, 12)
              .foregroundColor(.black)
            VStack() {
            Text("TWO FACTOR AUTHENTICATION")
              .font(Font.custom("Menlo", size: 40))
              .foregroundColor(.black)
            Text("SECURE, TRUSTED DEVICES")
              .font(Font.custom("Menlo", size: 40))
              .padding(.top, topPadding)
              .foregroundColor(.black)
            Text("FULLY SELF-CUSTODIAL")
              .font(Font.custom("Menlo", size: 40))
              .padding(.top, topPadding)
              .foregroundColor(.black)
            Text("NO TRACKING, NO REGISTRATION")
              .font(Font.custom("Menlo", size: 40))
              .padding(.top, topPadding)
              .foregroundColor(.black)
            Text("FULLY OPEN-SOURCE")
              .font(Font.custom("Menlo", size: 40))
              .padding(.top, topPadding)
              .foregroundColor(.black)
            Text("AUDITED")
              .font(Font.custom("Menlo", size: 40))
              .padding(.top, topPadding)
              .foregroundColor(.black)
            }
            .padding(.top, topPadding)
            Spacer()
            BottomBar(content: "START", onClick: {
                self.presentationStack.append(.startScreen)
            })
        }
        .frame(minWidth:0, maxWidth:.infinity, minHeight:0, maxHeight:.infinity, alignment: .top)
        .background(.white)
        .navigationBarBackButtonHidden();
    }
}



#Preview {
    WelcomeView(presentationStack: .constant([]))
}