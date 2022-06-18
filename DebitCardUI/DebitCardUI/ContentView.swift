//
//  ContentView.swift
//  DebitCardUI
//
//  Created by Saran Goda on 6/16/22.
//

import SwiftUI

struct ContentView: View {
	
	@State var shouldShowBack = false
	@State var isPrideTheme = false
	@State var colorArrayPride: [Color] = [.redCustom, .saffron, .yellowCustom, .greenCustom, .blueCustom, .violet]
	@State var colorArray: [Color] = [.mauve2, .mauve2, .mauve2, .mauve1, .mauve1, .mauve1]
	
	@State var cardHolderName = ""
	@State var cardNumberBlock1 = ""
	@State var cardNumberBlock2 = ""
	@State var cardNumberBlock3 = ""
	@State var cardNumberBlock4 = ""
	@State var cardValidFrom = ""
	@State var cardValidTo = ""
	@State var cvv = ""
	@State var validFromDate = Date()
	@State var validToDate = Date()
	
	@State var cardFrontDegree = 0.0
	@State var cardBackDegree = -90.0
	
	@State var shouldShowEditScreen = false
	@State var cardIssuer = ""
	
    var body: some View {
		VStack(spacing: 20) {
			GeometryReader{proxy in
				self.cardBack
					.rotation3DEffect(Angle(degrees: self.cardBackDegree), axis: (x: 0, y: 1, z: 0))
					.frame(width: proxy.size.width, height: proxy.size.height)
				self.cardFront
					.rotation3DEffect(Angle(degrees: self.cardFrontDegree), axis: (x: 0, y: 1, z: 0))
					.frame(width: proxy.size.width, height: proxy.size.height)
			}
			.frame(width: 300, height: 200)
			.cornerRadius(20)
			.onTapGesture {
				if !self.shouldShowBack{
					self.shouldShowEditScreen = true
				}
			}
			Text("Tap to Edit")
			Button(action: {
				self.flipCard()
			}){
				Text("Flip Card")
			}
			Toggle("Pride Theme", isOn: self.$isPrideTheme.animation())
				.frame(width: 300)
		}
		.sheet(isPresented: self.$shouldShowEditScreen){
			self.editScreen
		}
		.onChange(of: self.validFromDate) { newValue in
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MM/yy"
			self.cardValidFrom = dateFormatter.string(from: self.validFromDate)
		}
		.onChange(of: self.validToDate) { newValue in
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MM/yy"
			self.cardValidTo = dateFormatter.string(from: self.validToDate)
		}
    }
	
	func flipCard () {
		if self.shouldShowBack {
			withAnimation(.linear(duration: 0.3)) {
				self.cardBackDegree = 90
			}
			withAnimation(.linear(duration: 0.3).delay(0.3)){
				self.cardFrontDegree = 0
			}
		} else {
			withAnimation(.linear(duration: 0.3)) {
				self.cardFrontDegree = -90
			}
			withAnimation(.linear(duration: 0.3).delay(0.3)){
				self.cardBackDegree = 0
			}
		}
		self.shouldShowBack = !self.shouldShowBack
	}
	
	var cardBack: some View {
		ZStack{
			if self.isPrideTheme{
				LinearGradient(colors: colorArrayPride, startPoint: .top, endPoint: .bottom)
			}
			else {
				LinearGradient(colors: colorArray, startPoint: .top, endPoint: .bottom)
			}
			VStack{
				Rectangle()
					.fill(Color.black)
					.frame(height: 50)
				HStack{
					Spacer()
					VStack(alignment: .leading, spacing: 0){
						Text("CVV").font(Font.system(size: 10)).foregroundColor(self.isPrideTheme ? .black : .white)
						TextField("...", text: self.$cvv).foregroundColor(self.isPrideTheme ? .black : .white).keyboardType(.numberPad).font(.body)
							.onChange(of: self.cvv, perform: { newValue in
								if self.cvv.count > 3 {
									self.cvv = String(self.cvv.dropLast())
								}
							})
							.frame(width: 100)
					}
					.padding(.trailing, 20)
				}
				Spacer()
			}
			.padding(.top, 20)
		}
	}
	
	var cardFront: some View {
		ZStack{
			if self.isPrideTheme{
				LinearGradient(colors: colorArrayPride, startPoint: .top, endPoint: .bottom)
			}
			else {
				LinearGradient(colors: colorArray, startPoint: .top, endPoint: .bottom)
			}
			VStack{
				HStack{
					VStack(alignment: .leading){
						Text("H Y P D .")
							.font(.title3)
							.fontWeight(.bold)
							.foregroundColor(.black)
						Spacer()
					}
					.padding([.top, .leading], 20)
					Spacer()
				}
			}
			HStack{
				VStack(alignment: .leading, spacing: 8){
					Spacer()
					Text("\(self.cardNumberBlock1.isEmpty ? "XXXX" : "\(self.cardNumberBlock1)")-\(self.cardNumberBlock2.isEmpty ? "XXXX" : "\(self.cardNumberBlock2)")-\(self.cardNumberBlock3.isEmpty ? "XXXX" : "\(self.cardNumberBlock3)")-\(self.cardNumberBlock4.isEmpty ? "XXXX" : "\(self.cardNumberBlock4)")").font(.title3).fontWeight(.bold).foregroundColor(.white)
					HStack(spacing: 20){
						VStack(alignment: .leading, spacing: 0){
							Text("Valid From").font(Font.system(size: 10)).foregroundColor(.white)
							Text("\(self.cardValidFrom.isEmpty ? "MM/YY" : self.cardValidFrom)").font(.body).fontWeight(.bold).foregroundColor(.white)
						}
						VStack(alignment: .leading, spacing: 0){
							Text("Valid To").font(Font.system(size: 10)).foregroundColor(.white)
							Text("\(self.cardValidTo.isEmpty ? "MM/YY" : self.cardValidTo)").font(.body).fontWeight(.bold).foregroundColor(.white)
						}
						Text("\(self.cardIssuer)")
						Spacer()
					}
					Text("\(self.cardHolderName.isEmpty ? "Card Holder Name" : self.cardHolderName)")
						.font(.title3).fontWeight(.bold).foregroundColor(.white)
				}
				Spacer()
			}
			.padding(.leading, 20)
			.padding(.bottom, 10)
		}
	}
	
	func checkVisa(in text: String) -> [String] {
		
		do {
			let regex = try NSRegularExpression(pattern: "^4[0-9]{12}(?:[0-9]{3})?$")
			let results = regex.matches(in: text,
										range: NSRange(text.startIndex..., in: text))
			return results.map {
				String(text[Range($0.range, in: text)!])
			}
		} catch let error {
			print("invalid regex: \(error.localizedDescription)")
			return []
		}
	}
	
	func checkMaster(in text: String) -> [String] {
		
		do {
			let regex = try NSRegularExpression(pattern: "^(5[1-5][0-9]{14}|2(22[1-9][0-9]{12}|2[3-9][0-9]{13}|[3-6][0-9]{14}|7[0-1][0-9]{13}|720[0-9]{12}))$")
			let results = regex.matches(in: text,
										range: NSRange(text.startIndex..., in: text))
			return results.map {
				String(text[Range($0.range, in: text)!])
			}
		} catch let error {
			print("invalid regex: \(error.localizedDescription)")
			return []
		}
	}
//	^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$
	
	var editScreen: some View {
		VStack{
			HStack{
				TextField("XXXX", text: self.$cardNumberBlock1)
					.keyboardType(.numberPad)
					.onChange(of: self.cardNumberBlock1) { newValue in
						if self.cardNumberBlock1.count > 4 {
							self.cardNumberBlock1 = String(self.cardNumberBlock1.dropLast())
						}
					}
				Text("-")
				TextField("XXXX", text: self.$cardNumberBlock2)
					.keyboardType(.numberPad)
					.onChange(of: self.cardNumberBlock2) { newValue in
						if self.cardNumberBlock2.count > 4 {
							self.cardNumberBlock2 = String(self.cardNumberBlock2.dropLast())
						}
					}
				Text("-")
				TextField("XXXX", text: self.$cardNumberBlock3)
					.keyboardType(.numberPad)
					.onChange(of: self.cardNumberBlock3) { newValue in
						if self.cardNumberBlock3.count > 4 {
							self.cardNumberBlock3 = String(self.cardNumberBlock3.dropLast())
						}
					}
				Text("-")
				TextField("XXXX", text: self.$cardNumberBlock4)
					.keyboardType(.numberPad)
					.onChange(of: self.cardNumberBlock4) { newValue in
						if self.cardNumberBlock4.count > 4 {
							self.cardNumberBlock4 = String(self.cardNumberBlock4.dropLast())
						}
						else if self.cardNumberBlock4.count == 4 {
							if self.cardNumberBlock1.count == 4 && self.cardNumberBlock2.count == 4 && self.cardNumberBlock3.count == 4{
								var results = self.checkVisa(in: "\(self.cardNumberBlock1)\(self.cardNumberBlock2)\(self.cardNumberBlock3)\(self.cardNumberBlock4)")
								if results.count > 0 {
									self.cardIssuer = "VISA"
								}
								else {
									results = self.checkMaster(in: "\(self.cardNumberBlock1)\(self.cardNumberBlock2)\(self.cardNumberBlock3)\(self.cardNumberBlock4)")
									if results.count > 0 {
										self.cardIssuer = "MasterCard"
									}
									else {
										self.cardIssuer = ""
									}
								}
							}
						}
					}
			}
			HStack{
				DatePicker("Valid From", selection: self.$validFromDate, displayedComponents: .date)
				DatePicker("Valid To", selection: self.$validToDate, displayedComponents: .date)
			}
			TextField("Card Holder Name", text: self.$cardHolderName)
		}
		.padding(.horizontal)
	}
}

enum FocusedField {
	case cardBlock1, cardBlock2, cardBlock3, cardBlock4
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Color {
	static let violet = Color("violet")
	static let redCustom = Color("red")
	static let saffron = Color("saffron")
	static let greenCustom = Color("green")
	static let blueCustom = Color("blue")
	static let yellowCustom = Color("yellow")
	static let mauve1 = Color("mauve1")
	static let mauve2 = Color("mauve2")
}
