import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isMenuOpen = false

    var body: some View {
        NavigationView {
            ZStack {
                
                TabView(selection: $selectedTab) {
                    HomeView(isMenuOpen: $isMenuOpen)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Anasayfa")
                        }
                        .tag(0)

                    CameraView() // Updated CameraView will be shown here
                        .tabItem {
                            Image(systemName: "camera.fill")
                            Text("Çek Gönder")
                        }
                        .tag(1)

                    ContactView()
                        .tabItem {
                            Image(systemName: "phone.fill")
                            Text("Bize Ulaşın")
                        }
                        .tag(2)
                }
                .accentColor(.black)

                if isMenuOpen {
                    SideMenu(isMenuOpen: $isMenuOpen)
                        .transition(.move(edge: .leading))
                }
            }
            .navigationBarHidden(true)
        }
    }
}



import SwiftUI

struct HomeView: View {
    @Binding var isMenuOpen: Bool

    let items = [
        ("Canlı Yayın", "video.and.waveform.fill", "https://giresun.bel.tr/canli-yayin/", true),
        ("Başkan", "person.fill", "https://giresun.bel.tr/baskanin-ozgecmisi/", true),
        ("İletişim", "phone.fill", "https://giresun.bel.tr/iletisim/", true),
        ("Nöbetçi Eczane", "cross.fill", "https://secure.eczaneleri.org/api/widget/iframe.php?key=a0ef59826f1442f6d148cbc604a76738", true),
        ("E.Belediye", "building.2.fill", "https://online.giresun.bel.tr/ebelediye/#", true),
        ("Vefat İlanları", "book.fill", "https://giresun.bel.tr/category/vefat-ilanlari/", true)
    ]

    var body: some View {
        VStack {
            // Safe Area kullanarak üst kısmı ayarlama
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding(.leading)
                    
                    Spacer()

                    Image("bg_ataturk")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 340, height: 110)
                        .padding(.trailing, 20)
                }
                .padding(.top, 1) // Safe area'ya uyumlu olmasını sağlamak için padding ekleyin
                .background(Color.white)
                .shadow(radius: 5)
                .padding(.horizontal)
            }

            
             CustomWebView(urlString: "https://giresun.bel.tr", injectJavaScript: true)
                 .frame(height: 300) // Yüksekliği ihtiyaca göre ayarlayabilirsiniz
             
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(0..<items.count, id: \.self) { index in
                        NavigationLink(destination: WebView(urlString: items[index].2, injectJavaScript: true)) {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(height: 100)
                                .cornerRadius(25)
                                .shadow(radius: 5)
                                .overlay(
                                    VStack {
                                        Image(systemName: items[index].1)
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.white)
                                        Text(items[index].0)
                                            .foregroundColor(.white)
                                    }
                                )
                        }
                    }
                }
                .padding(.horizontal,20)
            }

            Spacer()
        }
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.bottom) // Alt kısımda güvenli alanı yok sayma
    }
}






struct ContactView: View {
    var body: some View {
        VStack {
            Button(action: {
                if let url = URL(string: "tel:4444028") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Ara")
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct SideMenu: View {
    @Binding var isMenuOpen: Bool

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding()
                }
                Spacer()
            }
            .background(Color.black.opacity(0.8))
            .shadow(radius: 3)

            VStack(alignment: .leading, spacing: 20) {
                NavigationLink(destination: WebView(urlString: "https://giresun.bel.tr/baskan-yardimcilari/", injectJavaScript: true)) {
                    SideMenuItem(icon: "person.fill", text: "Başkan Yardımcıları")
                }
                NavigationLink(destination: WebView(urlString: "https://giresun.bel.tr/meclis-uyeleri/", injectJavaScript: true)) {
                    SideMenuItem(icon: "person.2.fill", text: "Meclis Üyeleri")
                }
                NavigationLink(destination: WebView(urlString: "https://giresun.bel.tr/kardes-sehirler/", injectJavaScript: true)) {
                    SideMenuItem(icon: "globe", text: "Kardeş Şehirler")
                }
                NavigationLink(destination: WebView(urlString: "https://giresun.bel.tr/category/guncel-duyurular/", injectJavaScript: true)) {
                    SideMenuItem(icon: "bell.fill", text: "Güncel Duyurular")
                }
                NavigationLink(destination: WebView(urlString: "https://giresun.bel.tr/category/imar-plan-degisiklikleri/", injectJavaScript: true)) {
                    SideMenuItem(icon: "map.fill", text: "İmar Planı Değişiklikleri")
                }
                NavigationLink(destination: WebView(urlString: "https://giresun.bel.tr/6698-sayili-kisisel-verilerin-korunmasi-kanunu-geregi-aydinlatma-metni/", injectJavaScript: true)) {
                    SideMenuItem(icon: "shield.fill", text: "KVKK")
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color.black.opacity(0.8))
        .foregroundColor(.white)
    }
}


struct SideMenuItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 20, height: 20)
                .padding(.trailing, 10)
            Text(text)
                .font(.headline)
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
