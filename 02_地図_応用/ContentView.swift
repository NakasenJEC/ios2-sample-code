// ============================================
// 第2章（応用）：現在地を表示し、周辺検索する地図アプリ
// ============================================
// ユーザーの現在地を取得して地図上に表示し、
// 周辺のコンビニやカフェなどを検索する機能を追加します。
//
// 【注意】Info.plist に以下のキーを追加してください：
//   - NSLocationWhenInUseUsageDescription
//     値: "現在地を地図に表示するために位置情報を使用します"
// ============================================

import SwiftUI
import MapKit

// MARK: - 位置情報マネージャー

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last?.coordinate
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdating()
        default:
            break
        }
    }
}

// MARK: - 検索結果モデル

struct NearbyPlace: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let category: String
}

// MARK: - メインビュー

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedCategory: String = "コンビニ"

    let searchCategories = ["コンビニ", "カフェ", "レストラン", "駅"]

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $cameraPosition) {
                // 現在地のマーカー
                UserAnnotation()

                // 検索結果のマーカー
                ForEach(searchResults, id: \.self) { item in
                    if let name = item.name {
                        Marker(name, coordinate: item.placemark.coordinate)
                            .tint(.orange)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }

            // 検索カテゴリボタン
            VStack {
                categoryButtons
                    .padding(.top, 8)
                Spacer()
            }
        }
        .onAppear {
            locationManager.requestPermission()
        }
        .onChange(of: locationManager.userLocation) { _, newLocation in
            if let location = newLocation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            }
        }
    }

    // MARK: - カテゴリボタン

    private var categoryButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(searchCategories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                        Task { await searchNearby(query: category) }
                    } label: {
                        Text(category)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == category
                                    ? Color.blue
                                    : Color(.systemBackground)
                            )
                            .foregroundStyle(
                                selectedCategory == category
                                    ? .white
                                    : .primary
                            )
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.1), radius: 2)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - 周辺検索

    func searchNearby(query: String) async {
        guard let userLocation = locationManager.userLocation else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: userLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )

        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            searchResults = response.mapItems
        } catch {
            print("検索エラー: \(error.localizedDescription)")
            searchResults = []
        }
    }
}

#Preview {
    ContentView()
}
