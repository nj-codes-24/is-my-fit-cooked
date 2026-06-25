import React, { useState, useRef, useCallback } from "react";
import { Plus, Sparkles, Loader2, RefreshCw, Shirt, ShoppingBag, Search, ChevronRight, Camera, Link2, Upload, SwitchCamera, X } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import Webcam from "react-webcam";
import { useWardrobeStore } from "../store";
import { Outfit, WardrobeItem } from "../types";

export function Closet() {
  const { items, addItem, removeItem } = useWardrobeStore();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const webcamRef = useRef<Webcam>(null);
  
  const [isGenerating, setIsGenerating] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const [showPopover, setShowPopover] = useState(false);
  const [linkInputMode, setLinkInputMode] = useState(false);
  const [itemLink, setItemLink] = useState("");
  const [isCameraOpen, setIsCameraOpen] = useState(false);
  const [isSelfieMode, setIsSelfieMode] = useState(false);
  const [targetCategory, setTargetCategory] = useState<string | null>(null);
  const [selectedItem, setSelectedItem] = useState<WardrobeItem | null>(null);
  const [outfits, setOutfits] = useState<Outfit[]>([]);
  const [activeTab, setActiveTab] = useState<"items" | "outfits">("items");



  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setIsUploading(true);
      const reader = new FileReader();
      reader.onloadend = () => {
        // Simulate AI categorization delay
        setTimeout(() => {
          const categories = ['Shirts', 'T-Shirts', 'Pants', 'Shoes', 'Accessories'];
          const randomCategory = categories[Math.floor(Math.random() * categories.length)];
          
          addItem({
            id: Math.random().toString(36).substring(7),
            category: targetCategory || randomCategory,
            color: "Unknown",
            image: reader.result as string,
            addedAt: Date.now(),
          });
          setIsUploading(false);
          setIsCameraOpen(false);
          setTargetCategory(null);
        }, 1500);
      };
      reader.readAsDataURL(file);
    }
  };

  const captureFromCamera = useCallback(() => {
    const imageSrc = webcamRef.current?.getScreenshot();
    if (imageSrc) {
      setIsUploading(true);
      // Simulate AI categorization
      setTimeout(() => {
        const categories = ['Shirts', 'T-Shirts', 'Pants', 'Shoes', 'Accessories'];
        const randomCategory = categories[Math.floor(Math.random() * categories.length)];
        
        addItem({
          id: Math.random().toString(36).substring(7),
          category: targetCategory || randomCategory,
          color: "Unknown",
          image: imageSrc,
          addedAt: Date.now(),
        });
        setIsUploading(false);
        setIsCameraOpen(false);
        setTargetCategory(null);
      }, 1500);
    }
  }, [webcamRef, targetCategory, addItem]);

  const handleLinkUpload = () => {
    if (!itemLink) return;
    setIsUploading(true);
    setShowPopover(false);
    setTimeout(() => setLinkInputMode(false), 300);
    
    // Simulate AI fetching and categorization delay
    setTimeout(() => {
      const categories = ['Shirts', 'T-Shirts', 'Pants', 'Shoes', 'Accessories'];
      const randomCategory = categories[Math.floor(Math.random() * categories.length)];
      
      const mockImages = [
        "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&q=80&w=500", // black shirt
        "https://images.unsplash.com/photo-1624378439575-d1ead6cb46bc?auto=format&fit=crop&q=80&w=500", // blue pants
        "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=500", // red shoes
      ];
      
      addItem({
        id: Math.random().toString(36).substring(7),
        category: randomCategory,
        color: "Unknown",
        image: mockImages[Math.floor(Math.random() * mockImages.length)],
        addedAt: Date.now(),
      });
      setIsUploading(false);
      setItemLink("");
    }, 2000);
  };

  const generateOutfits = async () => {
    if (items.length === 0) return;
    setIsGenerating(true);
    setOutfits([]);
    setActiveTab("outfits");

    try {
      const res = await fetch("/api/generate-outfits", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        // Pass minimal metadata to avoid huge payloads
        body: JSON.stringify({ 
          wardrobeItems: items.map(i => ({ id: i.id, category: i.category, color: i.color })) 
        }),
      });
      
      if (!res.ok) throw new Error("Failed to generate");
      
      const data = await res.json();
      setOutfits(data.outfits);
    } catch (error) {
      console.error(error);
      alert("Failed to generate outfits.");
      setActiveTab("items");
    } finally {
      setIsGenerating(false);
    }
  };

  return (
    <div className="flex flex-col min-h-full pb-8">
      {/* Header */}
      <header className="px-6 pt-8 pb-4 sticky top-0 bg-[#111111]/80 backdrop-blur-xl z-20 border-b border-white/5">
        <div className="flex justify-center items-center relative z-50">
          <h1 className="font-display text-2xl tracking-tight font-bold text-white lowercase">closet</h1>
          <button 
            onClick={() => !isUploading && setShowPopover(true)}
            className="absolute right-0 w-10 h-10 rounded-full bg-white/10 flex items-center justify-center hover:bg-white/20 active:scale-95 transition-colors"
          >
            {isUploading ? <Loader2 size={20} className="text-white animate-spin" /> : <Plus size={20} className="text-white" />}
          </button>
          
          {/* Contextual Popover Menu */}
          <AnimatePresence>
            {showPopover && (
              <>
                {/* Invisible overlay for dismissing */}
                <motion.div 
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  className="fixed inset-0 z-40 bg-transparent"
                  onClick={() => {
                    setShowPopover(false);
                    setTimeout(() => setLinkInputMode(false), 300);
                  }}
                />
                
                {/* Popover Container */}
                <motion.div
                  initial={{ opacity: 0, scale: 0.8, y: -10 }}
                  animate={{ opacity: 1, scale: 1, y: 0 }}
                  exit={{ opacity: 0, scale: 0.9, y: -5, transition: { duration: 0.15 } }}
                  transition={{ type: "spring", damping: 25, stiffness: 350 }}
                  style={{ transformOrigin: "top right" }}
                  className="absolute top-14 right-0 z-50 w-[240px] box-border bg-[rgba(20,20,20,0.75)] backdrop-blur-[32px] saturate-[150%] border border-[rgba(255,255,255,0.08)] rounded-[32px] py-4 px-5 shadow-[0_16px_40px_rgba(0,0,0,0.6)] flex flex-col gap-4 overflow-hidden"
                >
                      <button 
                        onClick={() => {
                          if (navigator.vibrate) navigator.vibrate(50);
                          setShowPopover(false);
                          setTimeout(() => setIsCameraOpen(true), 150);
                        }}
                        className="flex items-center justify-start text-left w-full gap-4 group"
                      >
                        <div className="w-12 h-12 rounded-[20px] bg-white/5 flex items-center justify-center shrink-0 group-hover:bg-white/10 transition-colors shadow-inner !ml-0">
                          <Camera size={28} className="text-white/90" />
                        </div>
                        <div className="flex-1 whitespace-nowrap">
                          <p className="text-white font-bold text-[15px]">Camera</p>
                          <p className="text-[rgba(255,255,255,0.7)] text-[13px] leading-tight mt-0.5">Take a photo</p>
                        </div>
                        <ChevronRight size={18} className="text-white/20 group-hover:translate-x-1 transition-transform" />
                      </button>

                      <div className="h-[1px] w-full bg-[rgba(255,255,255,0.1)]" />

                      <button 
                        onClick={() => {
                          if (navigator.vibrate) navigator.vibrate(50);
                          setShowPopover(false);
                          setTimeout(() => setLinkInputMode(true), 150);
                        }}
                        className="flex items-center justify-start text-left w-full gap-4 group"
                      >
                        <div className="w-12 h-12 rounded-[20px] bg-white/5 flex items-center justify-center shrink-0 group-hover:bg-white/10 transition-colors shadow-inner !ml-0">
                          <Link2 size={28} className="text-white/90" />
                        </div>
                        <div className="flex-1 whitespace-nowrap">
                          <p className="text-white font-bold text-[15px]">Import Link</p>
                          <p className="text-[rgba(255,255,255,0.7)] text-[13px] leading-tight mt-0.5">Paste a store URL</p>
                        </div>
                        <ChevronRight size={18} className="text-white/20 group-hover:translate-x-1 transition-transform" />
                      </button>
                </motion.div>
              </>
            )}
          </AnimatePresence>

          <input 
            type="file" 
            ref={fileInputRef} 
            className="hidden" 
            accept="image/*"
            onChange={handleFileUpload}
          />
        </div>


        {/* Custom Segmented Control */}
        <div className="flex p-1 mt-6 bg-white/5 rounded-xl border border-white/10 relative">
          <motion.div 
            className="absolute inset-y-1 w-[calc(50%-4px)] bg-white/10 rounded-lg shadow-sm"
            animate={{ left: activeTab === "items" ? 4 : "50%" }}
            transition={{ type: "spring", bounce: 0.2, duration: 0.6 }}
          />
          <button 
            onClick={() => setActiveTab("items")}
            className={`flex-1 py-2 text-sm font-medium relative z-10 transition-colors ${activeTab === "items" ? "text-white" : "text-white/50"}`}
          >
            Items
          </button>
          <button 
            onClick={() => setActiveTab("outfits")}
            className={`flex-1 py-2 text-sm font-medium relative z-10 transition-colors ${activeTab === "outfits" ? "text-white" : "text-white/50"}`}
          >
            Outfits
          </button>
        </div>
      </header>

      {/* Main Content */}
      <div className="flex-1 px-4 pt-4">
        <AnimatePresence mode="wait">
          {activeTab === "items" ? (
            <motion.div 
              key="items"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              className="flex flex-col gap-6"
            >
              {items.length === 0 ? (
                <div className="flex flex-col items-center justify-center py-20 text-center px-4">
                  <div className="w-16 h-16 rounded-2xl bg-white/5 flex items-center justify-center mb-4">
                    <Plus size={24} className="text-white/40" />
                  </div>
                  <p className="text-white/80 font-medium">Your closet is empty</p>
                  <p className="text-white/50 text-sm mt-2 mb-6">Add some clothes to start generating outfits.</p>
                  <div className="flex gap-3">
                    <button 
                      onClick={() => fileInputRef.current?.click()}
                      className="px-6 py-3 rounded-full bg-white text-black font-medium text-sm shadow-xl"
                    >
                      Add First Item
                    </button>
                  </div>
                </div>
              ) : (
                <>
                <div className="pb-24">
                  {/* Dynamic Category Rows */}
                  {Array.from(new Set(items.map(i => i.category))).map((category, idx) => {
                    const categoryItems = items.filter(item => item.category === category);
                    return (
                    <div key={category} className="mb-8">
                      <div className="px-4 flex items-center justify-between mb-4">
                        <h2 className="text-xl font-bold text-white/90 lowercase">{category}</h2>
                      </div>
                      <div className="flex gap-3 overflow-x-auto px-4 pb-4 snap-x hide-scrollbar">
                        {categoryItems.map((item, i) => (
                          <div 
                            key={`${category}-${i}`} 
                            onClick={() => setSelectedItem(item)}
                            className="shrink-0 w-[140px] aspect-[4/5] bg-[#242426] ring-1 ring-inset ring-white/10 rounded-[24px] overflow-hidden snap-start relative shadow-lg active:scale-95 transition-transform cursor-pointer"
                          >
                            <img src={item.image} alt={category} className="w-full h-full object-cover opacity-90 hover:opacity-100 transition-opacity" />
                          </div>
                        ))}
                      </div>
                    </div>
                  )})}
                </div>
                </>
              )}
            </motion.div>
          ) : (
            <motion.div 
              key="outfits"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              className="flex flex-col gap-4"
            >
              {isGenerating ? (
                <div className="flex flex-col items-center justify-center py-20 gap-4">
                  <Loader2 size={32} className="text-white/60 animate-spin" />
                  <p className="text-white/60 text-sm">Curating your looks...</p>
                </div>
              ) : outfits.length === 0 ? (
                <div className="flex flex-col items-center justify-center py-20 text-center px-4">
                  <div className="w-16 h-16 rounded-2xl bg-white/5 flex items-center justify-center mb-4">
                    <Sparkles size={24} className="text-white/40" />
                  </div>
                  <p className="text-white/80 font-medium">No outfits yet</p>
                  <p className="text-white/50 text-sm mt-2 mb-6">Generate some looks from your closet.</p>
                  <button 
                    onClick={generateOutfits}
                    disabled={items.length < 2}
                    className="px-6 py-3 rounded-full bg-white text-black font-medium text-sm disabled:opacity-50"
                  >
                    Generate Now
                  </button>
                </div>
              ) : (
                <div className="space-y-6">
                  {outfits.map((outfit, i) => (
                    <div key={i} className="glass-panel p-5 rounded-3xl space-y-4">
                      <div className="flex items-center justify-between">
                        <span className="text-xs font-mono tracking-widest uppercase text-white/50 border border-white/10 px-2 py-1 rounded-md">
                          {outfit.style}
                        </span>
                      </div>
                      <p className="text-sm text-white/90 leading-relaxed">
                        {outfit.description}
                      </p>
                      
                      {/* We mock the item display since Gemini only returns IDs and we might not have the full context perfectly matched, but we can try to find them */}
                      <div className="flex gap-3 overflow-x-auto pb-2 snap-x">
                        {outfit.itemIds.map((id, j) => {
                          const item = items.find(i => i.id === id);
                          if (!item) return null;
                          return (
                            <div key={j} className="shrink-0 w-20 h-20 rounded-2xl overflow-hidden bg-zinc-900 snap-start border border-white/10">
                              <img src={item.image} alt="Outfit part" className="w-full h-full object-cover" />
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  ))}
                  <button 
                    onClick={generateOutfits}
                    className="w-full py-4 rounded-2xl bg-white/5 text-white font-medium flex items-center justify-center gap-2 active:scale-[0.98] transition-transform border border-white/10"
                  >
                    <RefreshCw size={18} />
                    Regenerate
                  </button>
                </div>
              )}
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Item Details Modal */}
      <AnimatePresence>
        {selectedItem && (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-center justify-center p-6 bg-black/80 backdrop-blur-sm"
            onClick={() => setSelectedItem(null)}
          >
            <motion.div 
              initial={{ scale: 0.9, opacity: 0, y: 20 }}
              animate={{ scale: 1, opacity: 1, y: 0 }}
              exit={{ scale: 0.9, opacity: 0, y: 20 }}
              transition={{ type: "spring", damping: 25, stiffness: 300 }}
              onClick={(e) => e.stopPropagation()}
              className="w-full max-w-xs bg-[#1C1C1E] border border-white/10 rounded-[32px] overflow-hidden shadow-2xl flex flex-col"
            >
              <div className="w-full aspect-square bg-[#242426] relative">
                <img src={selectedItem.image} alt={selectedItem.category} className="w-full h-full object-cover" />
                <button 
                  onClick={() => setSelectedItem(null)}
                  className="absolute top-4 right-4 w-8 h-8 rounded-full bg-black/50 backdrop-blur-md flex items-center justify-center hover:bg-black/70 transition-colors"
                >
                  <Plus size={20} className="text-white rotate-45" />
                </button>
              </div>
              <div className="p-6 flex flex-col gap-6">
                <div>
                  <h3 className="text-white font-bold text-xl capitalize">{selectedItem.category}</h3>
                  <p className="text-white/50 text-sm mt-1">Added {new Date(selectedItem.addedAt).toLocaleDateString()}</p>
                </div>
                <button 
                  onClick={() => {
                    removeItem(selectedItem.id);
                    setSelectedItem(null);
                  }}
                  className="w-full py-4 rounded-2xl bg-red-500/10 text-red-500 font-bold active:scale-[0.98] transition-all border border-red-500/20 hover:bg-red-500/20 flex items-center justify-center gap-2"
                >
                  Delete Item
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>


      {/* Import Link Bottom Sheet */}
      <AnimatePresence>
        {linkInputMode && (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-center justify-center p-6 bg-black/40 backdrop-blur-xl"
            onClick={() => setLinkInputMode(false)}
          >
            <motion.div 
              initial={{ scale: 0.9, opacity: 0, y: 20 }}
              animate={{ scale: 1, opacity: 1, y: 0 }}
              exit={{ scale: 0.9, opacity: 0, y: 20 }}
              transition={{ type: "spring", damping: 25, stiffness: 300 }}
              onClick={(e) => e.stopPropagation()}
              className="w-full max-w-sm bg-[rgba(30,30,30,0.8)] backdrop-blur-3xl rounded-[32px] p-6 shadow-[0_24px_60px_rgba(0,0,0,0.8)] border border-[rgba(255,255,255,0.1)] flex flex-col relative"
            >
              <button 
                onClick={() => setLinkInputMode(false)}
                className="absolute top-6 right-6 w-8 h-8 rounded-full bg-white/5 flex items-center justify-center text-white/70 hover:bg-white/10 hover:text-white transition-colors"
              >
                <X size={18} />
              </button>
              
              <h3 className="text-white font-bold text-2xl mb-1">Import via Link</h3>
              <p className="text-[rgba(255,255,255,0.6)] text-sm mb-6">Paste product URL from any store</p>
              
              <div className="flex flex-col gap-4 mb-6">
                <input 
                  type="url" 
                  placeholder="https://..."
                  value={itemLink}
                  onChange={(e) => setItemLink(e.target.value)}
                  className="w-full bg-black/40 ring-1 ring-inset ring-white/10 rounded-2xl px-5 py-4 text-white placeholder:text-white/30 focus:outline-none focus:ring-white/30 transition-all text-lg shadow-inner"
                  autoFocus
                />
              </div>

              <button 
                disabled={!itemLink}
                onClick={handleLinkUpload}
                className="w-full py-4 rounded-2xl bg-white text-black font-bold active:scale-[0.98] transition-all disabled:opacity-50 disabled:cursor-not-allowed text-lg shadow-[0_4px_16px_rgba(255,255,255,0.2)]"
              >
                Fetch Item
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>


      {/* Full-Screen Camera View */}
      <AnimatePresence>
        {isCameraOpen && (
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            className="fixed inset-0 z-[100] bg-black flex flex-col items-center justify-center overflow-hidden"
          >
            {/* Header */}
            <div className="absolute top-0 inset-x-0 p-6 flex justify-between items-center z-50">
              <button 
                onClick={() => setIsCameraOpen(false)}
                className="w-12 h-12 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-colors backdrop-blur-md active:scale-95"
              >
                <X size={24} />
              </button>
              <button 
                onClick={() => setIsSelfieMode(!isSelfieMode)}
                className="w-12 h-12 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-colors backdrop-blur-md active:scale-95"
              >
                <SwitchCamera size={24} />
              </button>
            </div>

            {/* Camera Viewport (4:5 Aspect Ratio) */}
            <div className="w-full px-4 flex justify-center items-center h-full">
              <div className="w-full max-w-md aspect-[4/5] rounded-[32px] overflow-hidden relative bg-zinc-900 shadow-2xl">
                {/* @ts-ignore */}
                <Webcam
                  audio={false}
                  ref={webcamRef}
                  screenshotFormat="image/jpeg"
                  screenshotQuality={1}
                  className="absolute inset-0 w-full h-full object-cover"
                  videoConstraints={{ 
                    facingMode: isSelfieMode ? "user" : "environment",
                    aspectRatio: 4/5
                  }}
                  mirrored={isSelfieMode}
                />
                
                {isUploading && (
                  <div className="absolute inset-0 bg-black/60 backdrop-blur-md flex flex-col items-center justify-center gap-4 z-50">
                    <Loader2 size={36} className="text-white animate-spin" />
                    <p className="text-white font-medium text-lg">Categorizing item...</p>
                  </div>
                )}
              </div>
            </div>

            {/* Bottom Controls */}
            <div className="absolute bottom-0 inset-x-0 p-8 pb-12 flex justify-between items-center z-50 px-10 max-w-md mx-auto">
              <button 
                onClick={() => fileInputRef.current?.click()}
                className="w-14 h-14 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-colors backdrop-blur-md active:scale-95"
              >
                <Upload size={24} />
              </button>

              <button 
                onClick={captureFromCamera}
                disabled={isUploading}
                className="w-20 h-20 rounded-full border-[4px] border-white/50 flex items-center justify-center p-1.5 active:scale-95 transition-transform"
              >
                <div className="w-full h-full rounded-full bg-white shadow-sm" />
              </button>
              
              <div className="w-14 h-14" /> {/* Spacer to perfectly center the shutter */}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
