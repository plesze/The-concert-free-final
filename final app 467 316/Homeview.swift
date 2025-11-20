//
//  Homeview.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 17/11/2568 BE.
//

import SwiftUI

struct Homeview: View {
    
    // MARK: - Model
    struct Concert: Identifiable {
        let id = UUID()
        let title: String        // ชื่อคอนเสิร์ตใหญ่ ๆ
        let subtitle: String     // subtitle / stage / tagline
        let dateText: String     // ข้อความวันที่
        let timeText: String     // ข้อความเวลา
        let locationText: String // สถานที่
        let imageName: String    // ชื่อรูปใน Assets
        let detail: String
        let mapURL: URL?         // ลิงก์แผนที่เฉพาะของงาน (ถ้ามี)
    }
    
    // MARK: - Sample Data
    static let sampleConcerts: [Concert] = [
        Concert(
            title: "MEDMUSIC IN THE PARK 2025",
            subtitle: "Live in the City of Angels",
            dateText: "เสาร์ที่ 29 พฤศจิกายน 2568",
            timeText: "19:00 – 21:00",
            locationText: "Main Amphitheater สวนเบญจกิติ กรุงเทพมหานคร",
            imageName: "Medmusic",
            detail: "MedMusic in the Park 2025 กิจกรรมฟรีคอนเสิร์ต ที่ โรงพยาบาลเมดพาร์ค ร่วมกับ กรุงเทพมหานคร จัดขึ้นมาอย่างต่อเนื่อง นับตั้งแต่ปี พ.ศ.2565 เป็นต้นมา ด้วยเชื่อว่า “สุขภาพที่ดีอย่างยั่งยืน” คือ การดูแลสุขภาพแบบองค์รวม ผ่านการผสมผสานของนวัตกรรมทางการแพทย์ พลังบำบัดของศิลปะทุกแขนง และธรรมชาติที่สมบูรณ์ ",
            mapURL: URL(string: "https://maps.apple.com/place?place-id=I9084CA8D19372506&address=184+Rama+4+Road%2C+Khlong+Toei%2C+Khlong+Toei+District%2C+Bangkok+10110%2C+Thailand&coordinate=13.7285273%2C100.5537236&name=Main+Amphitheatre&_provider=9902")
        ),
        Concert(
            title: "THE SNOWVILLE CONCERT",
            subtitle: "STAGE: Winter Fantasy Night",
            dateText: "19-22 Dec 2025",
            timeText: "18:30 – 22:00",
            locationText: "SW1 MARKET",
            imageName: "snowville",
            detail: "Snow Ville” กลับมาอีกครั้ง!  เทศกาลดนตรีในเมืองหิมะใจกลางกรุงเทพฯ ฟรีคอนเสิร์ต 4 วันเต็ม!  กับ 10 ศิลปินสุดฮอต  19–22 ธันวาคมนี้พบกับไลน์อัพ 10  ศิลปิน ที่จะมาสร้างความฟินด้วยเสียงเพลง จัดเต็ม 4 วัน ให้ทุกคนได้อิ่มใจ 19 ธ.ค. : Landokmai / YEW 20 ธ.ค. : Whal & Dolph / Moving and Cut 21 ธ.ค. : Chilax / Dept / Purpeech 22 ธ.ค. : Bell Warisara / Serious Bacon / PROXIE",
            mapURL: URL(string: "https://maps.apple/p/yQk1ooWMpuh1UE")
        ),
        Concert(
            title: "SIAM MUSIC FEST 2025",
            subtitle: "STAGE: Before the End of Summer",
            dateText: "13-14 Dec 2025",
            timeText: "17:00 – 23:00",
            locationText: "Siam Square",
            imageName: "siammusic",
            detail: "เทศกาลดนตรี PMCU x NYLON – SIAM MUSIC FEST 2025 จะจัดขึ้นในวันที่ 13–14 ธันวาคม 2568 ใจกลางสยามสแควร์ และเปิดให้เข้าชม ฟรีตลอดงาน โดยงานนี้เป็นเฟสติวัลดนตรีขนาดใหญ่ที่รวมศิลปินชื่อดังและศิลปินรุ่นใหม่ไว้มากมาย เช่น ลำไย ไหทองคำ, NONT TANONT, DICE, PERSES, JACKIE JACKRIN รวมถึงศิลปินอื่น ๆ อย่าง ALLY, LANDOKMAI, PURPEECH, LITTLE JOHN, ALALA, BENZKHAOKHWAN, paiiinnnt, Praesun และอีกจำนวนมาก พร้อมโชว์พิเศษจาก D-NA x Wizzle x NEVONE, JETAIME, SAMUI และ guncharlie feat. FRONC บรรยากาศภายในงานถูกออกแบบมาให้สนุกสุดมันส์ทั้งแสง สี เสียง และกิจกรรมต่าง ๆ บนพื้นที่สยามสแควร์ที่เต็มไปด้วยผู้คน เหมาะกับการมาสนุก ถ่ายรูป และชมศิลปินที่ชื่นชอบแบบจัดเต็มตลอดสองวันเต็มในงาน #SiamMusicFest2025",
            mapURL: URL(string: "https://maps.apple/p/n~36iakw1.s_5w")
        ),
        Concert(
            title: "THE MAGICAL COUNTDOWN CELEBRATION 2025 ",
            subtitle: "STAGE: A Night of Wonders",
            dateText: "26-31 Dec 2025",
            timeText: "19:00 – 22:00",
            locationText: "Siam Paragon",
            imageName: "the magical",
            detail: "สยามพารากอนชวนทุกคนร่วมต้อนรับปีใหม่ด้วยงาน “SIAM PARAGON THE MAGICAL COUNTDOWN CELEBRATION 2025” มหกรรมความบันเทิงเต็มรูปแบบที่จัดต่อเนื่องยาวนานถึง 6 วันเต็ม ตั้งแต่วันที่ 26–31 ธันวาคม 2567 ณ พาร์ค พารากอน ชั้น M โดยภายในงานจะมีคอนเสิร์ตสุดมันส์แบบนันสต๊อป พร้อมทัพศิลปินชื่อดังของไทยกว่า 100 ชีวิต อาทิ ซี–นุนิว, คริส–สิงโต, THREE MAN DOWN, POTATO, TILLY BIRDS, ป๊อบ ปองกูล–โอ๊ต ปราโมทย์, ต้าห์อู๋–ออฟโรด, URBOYTJ, วี–วิโอเลต, getsunova, NONT TANONT, PALMY, PARADOX, PAPER PLANES, ปอนด์–ภูวินทร์, เจมิไนน์–โฟร์ท และ BODYSLAM ร่วมสร้างความสนุกส่งท้ายปีอย่างจุใจท่ามกลางบรรยากาศเฉลิมฉลองสุดคึกคัก พร้อมมาตรการความปลอดภัยเข้มงวด",
            mapURL: URL(string: "https://maps.apple/p/uQz5e-c9gkX8Gd")
        )
    ]
    
    let concerts = Homeview.sampleConcerts
    
    @State private var currentIndex: Int = 0
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // พื้นหลังทั้งจอ
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                TabView(selection: $currentIndex) {
                    ForEach(concerts.indices, id: \.self) { index in
                        let concert = concerts[index]
                        
                        VStack(spacing: 0 ) {
                            Image(concert.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 320)
                                .frame(width: 280)
                                .clipShape(RoundedRectangle(cornerRadius: 1))
                            
                            Spacer().frame(height: 0)
                                
                            NavigationLink {
                                ConcertDetailView(concert: concert)
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(concert.title)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .lineLimit(2)
                                            .truncationMode(.tail)
                                            .multilineTextAlignment(.leading)
                                        
                                        Text(concert.subtitle)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.green)
                                        Text(concert.dateText)
                                            .foregroundColor(.green)
                                            .font(.subheadline)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "clock")
                                            .foregroundColor(.green)
                                        Text(concert.timeText)
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    
                                    // แถวสถานที่ (แค่แสดงผล ไม่ต้องกดในหน้านี้)
                                    HStack(spacing: 8) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .foregroundColor(.blue)
                                        Text(concert.locationText)
                                            .foregroundColor(.blue)
                                            .font(.subheadline)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                }
                                .padding(20)
                                .frame(width: 280, height: 170)
                                .background(
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(Color.gray.opacity(0.5))
                                )
                                .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 8)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 24)
                            .padding(.top, 2)
                        }
                        .padding(.horizontal)
                        .tag(index)
                    }
                }
                .frame(height: 560)
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                HStack(spacing: 8) {
                    ForEach(concerts.indices, id: \.self) { index in
                        Circle()
                            .frame(
                                width: currentIndex == index ? 10 : 6,
                                height: currentIndex == index ? 10 : 6
                            )
                            .foregroundStyle(
                                currentIndex == index
                                ? Color.white
                                : Color.white.opacity(0.4)
                            )
                            .animation(.spring(duration: 0.2), value: currentIndex)
                    }
                }
                .padding(.top, 8)
                
                Spacer()
            }
        }
    }
}

#Preview {
    Homeview()
}
