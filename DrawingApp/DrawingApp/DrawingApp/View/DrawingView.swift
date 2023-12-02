//
//  ContentView.swift
//  DrawingApp
//
//  Created by Martin Krcma on 22/11/2023.
//

import SwiftUI
import CoreData

struct DrawingView: View {
    // ID of edited image (set on nil if image is new)
    @Binding var selectedImageId: NSManagedObjectID?
    
    @State private var d_ctx: DrawingContext = DrawingContext()
    
    private var imgExporter: ImageExportUtil = ImageExportUtil()
    
    @State private var showingColorPicker = false
    @State private var showingWidthDialog = false
    @State private var showingClearDialog = false
    @State private var isShowingSaveDialog = false
    
    @State private var isShowingGifOk = false
    @State private var isShowingGifError = false
    
    init(selectedImageId: Binding<NSManagedObjectID?> = .constant(nil)) {
        _selectedImageId = selectedImageId
    }
    
    var body: some View {
        ZStack {
            VStack {
                Canvas { (ctx, size) in
                    d_ctx.renderEvent(ctx, size: size)
                }.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({value in
                    d_ctx.drawingEvent(value)
                }))
                
                HStack {
                    colorButton(color: d_ctx.selectedColor)
                    sizeButton()
                    undoButton()
                    redoButton()
                    clearButton()
                    saveButton()
                    exportButton()
                }
            }
            .padding()
            .navigationBarBackButtonHidden(selectedImageId == nil ? false : true)
            .onAppear {
                loadImage()
            }
            
            GIFView(type: .name("tick"), isActive: $isShowingGifOk, durationToShow: 5.0)
                .aspectRatio(1, contentMode: .fit)
                .scaleEffect(0.6)
                .allowsHitTesting(false)
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            
            GIFView(type: .name("cross"), isActive: $isShowingGifError, durationToShow: 5.0)
                .aspectRatio(1, contentMode: .fit)
                .scaleEffect(0.6)
                .allowsHitTesting(false)
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)

        }
    }
    
    func loadImage() {
        if let id = selectedImageId {
            print("Drawing View call image load")
            d_ctx.loadFromCoreData(id)
        }
    }
    
    @ViewBuilder
    func colorButton(color: Color) -> some View {
        Button {
            UIColorWellHelper.helper.execute?()
        } label: {
            Image(systemName: "pencil.tip")
                .font(.largeTitle)
                .foregroundColor(color)
                .background(color.isNearWhite() ? Color.gray : Color(red: 1, green: 1, blue: 1, opacity: 0))
                .cornerRadius(10)
        }
        .background(
            ColorPicker("", selection: $d_ctx.selectedColor, supportsOpacity: false)    .labelsHidden().opacity(0)
        )
    }
    
    @ViewBuilder
    func clearButton() -> some View {
        Button {
            showingClearDialog.toggle()
        } label: {
            Image(systemName: "pencil.tip.crop.circle.badge.minus")
                .font(.largeTitle)
                .foregroundColor(.red)
        }
        .alert(isPresented: $showingClearDialog) {
            Alert(
                title: Text("Confirm Clear"),
                message: Text("Are you sure you want to clear the current image?"),
                primaryButton: .destructive(Text("Delete")) {
                    d_ctx.clear()
                },
                secondaryButton: .cancel()
            )
        }
    }
        
    @ViewBuilder
    func sizeButton() -> some View {
        Button {
            showingWidthDialog.toggle()
        } label: {
            Image(systemName: "chevron.up.chevron.down")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
        .sheet(isPresented: $showingWidthDialog, content: {
            VStack {
                Slider(value: $d_ctx.widthSize, in: 1...200, step: 1.0)
                    .padding()
                Text("Current pen width: \(Int(d_ctx.widthSize))")
                Button("OK") {
                    showingWidthDialog.toggle()
                }
                .padding()
            }
            .padding()
            .presentationDetents([.fraction(0.25)])
        })
    }
    
    @ViewBuilder
    func undoButton() -> some View {
        Button {
            d_ctx.undoAction()
        } label: {
            Image(systemName: "arrowshape.turn.up.left")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
    }
    
    @ViewBuilder
    func redoButton() -> some View {
        Button {
            d_ctx.redoAction()
        } label: {
            Image(systemName: "arrowshape.turn.up.right")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
    }
    
    @ViewBuilder
    func saveButton() -> some View {
        Button {
            // save image
            if d_ctx.imageData.name.isEmpty {
                isShowingSaveDialog = true
            } else {
                d_ctx.saveToCoreData(d_ctx.imageData.name)
                // show notification
                isShowingGifOk = true
            }
        } label: {
            Image(systemName: "tray.and.arrow.down")
                .font(.largeTitle)
                .foregroundColor(.black)
        }
        .sheet(isPresented: $isShowingSaveDialog, content: {
            VStack {
                TextField("Set name of image:", text: $d_ctx.imageData.name)
                HStack(spacing: 20) {
                    Button("Save") {
                        d_ctx.saveToCoreData(d_ctx.imageData.name)
                        // show notification
                        isShowingGifOk =  true
                        isShowingSaveDialog = false
                    }
                    .foregroundColor(.blue)
                    .padding()
                    
                    Button("Cancel") {
                        d_ctx.imageData.name = ""
                        isShowingSaveDialog = false
                    }
                    .foregroundColor(.red)
                    .padding()
                }
                .padding()
            }
            .padding()
            .presentationDetents([.fraction(0.25)])
        })
    }
    
    @ViewBuilder
    func exportButton() -> some View {
        Button {
            imgExporter.exportDrawing { status in
                if status == true {
                    isShowingGifOk = true
                } else {
                    isShowingGifError = true
                }
            }
        } label: {
            Image(systemName: "folder")
                .font(.largeTitle)
                .foregroundColor(.black)
        }
    }
    
}

extension UIColorWell {
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()

        if let uiButton = self.subviews.first?.subviews.last as? UIButton {
            UIColorWellHelper.helper.execute = {
                uiButton.sendActions(for: .touchUpInside)
            }
        }
    }
}

class UIColorWellHelper: NSObject {
    static let helper = UIColorWellHelper()
    var execute: (() -> ())?
    @objc func handler(_ sender: Any) {
        execute?()
    }
}

