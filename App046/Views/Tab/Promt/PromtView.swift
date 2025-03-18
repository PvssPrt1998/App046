import SwiftUI

struct PromtView: View {
    
    @EnvironmentObject var source: Source
    @EnvironmentObject var router: EffectsV2Router
    
    @State var text = ""
    @State var selection = 0
    
    @State var showPro = true
    @State var showPaywall = false
    
    private var header: some View {
        HStack(spacing: 6) {
            Text("Promt")
                .font(.appFont(.Title2Emphasized))
                .foregroundStyle(.white)
            Spacer()
            Button {
                showPaywall = true
            } label: {
                Image("ProButton")//make it button
                    .resizable()
                    .scaledToFit()
                    .frame(width: 82, height: 32)
            }
            
                .disabled(source.proSubscription == true)
                .opacity(source.proSubscription ? 0 : 1)
            
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
    }
    
    var body: some View {
        ZStack {
            Color.bgSecond.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Video")
                        .font(.appFont(.Title2Emphasized))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        showPaywall = true
                    } label: {
                        Image("ProButton")//make it button
                            .resizable()
                            .scaledToFit()
                            .frame(width: 82, height: 32)
                    }
                    .disabled(source.proSubscription == true)
                    .opacity(source.proSubscription ? 0 : 1)
                }
                .padding(.horizontal, 16)
                .frame(height: 44)
                
                content
            }
        }
        .toolbar(.hidden)
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(show: $showPaywall)
            }
            .onAppear {
                if showPro != source.proSubscription {
                    showPro = source.proSubscription
                }
            }
    }
    
    
    
    private var styleForSelection: String {
        switch selection {
        case 0: return ""
        case 1: return "Realistic style video. "
        case 2: return "Anime style video. "
        case 3: return "Cyberpunk style video. "
        case 4: return "Pixar style video. "
        case 5: return "Graffiti style video. "
        default: return ""
        }
    }
    
    private var content: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Enter promt")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                textEditorCustom(text: $text, placeholder: "Enter any query to create your video using AI")
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                Text("Choose Style")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        styleElement(imageTitle: "NoStyle", text: "No style", selection: 0)
                        styleElement(imageTitle: "Realistic", text: "Realistic", selection: 1)
                        styleElement(imageTitle: "Anime", text: "Anime", selection: 2)
                        styleElement(imageTitle: "Cyberpunk", text: "Cyberpunk", selection: 3)
                        styleElement(imageTitle: "Pixar", text: "Pixar", selection: 4)
                        styleElement(imageTitle: "Graffiti", text: "Graffiti", selection: 5)
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 105)
            }
            
            Button {
                let text = styleForSelection + self.text
                router.path.append(EffectsV2Route.promt(text))
            } label: {
                Text("Create a masterpiece")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(height: 48)
                    .background(text == "" ? Color.accentGray : Color.cSecondary)
                    .clipShape(.rect(cornerRadius: 32))
            }
            .disabled(text == "")
            .padding(.horizontal, 16)
        }
        
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private func styleElement(imageTitle: String, text: String, selection: Int) -> some View {
        VStack(spacing: 4) {
            Image(imageTitle)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipped()
                .overlay(
                    Circle()
                        .stroke(self.selection == selection ? Color.accentSecondary : Color.clear, lineWidth: 2)
                )
            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.white)
        }
        .onTapGesture {
            self.selection = selection
        }
    }
    
    func placeholderView(isShow: Bool, text: String) -> some View {
        Text(isShow ? text : "")
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.white.opacity(0.6))
            .padding(EdgeInsets(top: 23, leading: 16, bottom: 15, trailing: 16))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private func textEditorCustom(text: Binding<String>, placeholder: String) -> some View {
        TextEditor(text: text)
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.white)
            .scrollContentBackground(.hidden)
            .padding(EdgeInsets(top: 15, leading: 12, bottom: 40, trailing: 12))
            .background(
                placeholderView(isShow: text.wrappedValue == "", text: placeholder)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .background(Color.white.opacity(0.08))
            .clipShape(.rect(cornerRadius: 16))
            .frame(height: 160)
    }
}

#Preview {
    PromtView()
}
