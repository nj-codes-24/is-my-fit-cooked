import React, { useState, useRef } from "react";
import { Plus, Sparkles, Loader2, RefreshCw } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import { useWardrobeStore } from "../store";
import { Outfit } from "../types";

export function Closet() {
  const { items, addItem, removeItem } = useWardrobeStore();
  const fileInputRef = useRef<HTMLInputElement>(null);
  
  const [isGenerating, setIsGenerating] = useState(false);
  const [outfits, setOutfits] = useState<Outfit[]>([]);
  const [activeTab, setActiveTab] = useState<"items" | "outfits">("items");

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        addItem({
          id: Math.random().toString(36).substring(7),
          category: "Uncategorized",
          color: "Unknown",
          image: reader.result as string,
          addedAt: Date.now(),
        });
      };
      reader.readAsDataURL(file);
    }
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
      <header className="px-6 pt-8 pb-4 sticky top-0 bg-black/80 backdrop-blur-xl z-10 border-b border-white/5">
        <div className="flex justify-between items-end">
          <div>
            <h1 className="font-display text-3xl tracking-tight font-medium">Closet</h1>
            <p className="text-white/50 text-sm mt-1">{items.length} items saved</p>
          </div>
          <button 
            onClick={() => fileInputRef.current?.click()}
            className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center active:scale-95 transition-transform"
          >
            <Plus size={20} className="text-white" />
          </button>
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
                  <button 
                    onClick={() => fileInputRef.current?.click()}
                    className="px-6 py-3 rounded-full bg-white text-black font-medium text-sm"
                  >
                    Add First Item
                  </button>
                </div>
              ) : (
                <>
                  <div className="grid grid-cols-3 gap-3">
                    {items.map((item) => (
                      <div key={item.id} className="relative aspect-square rounded-2xl overflow-hidden bg-zinc-900 border border-white/5 group">
                        <img src={item.image} alt="Clothing item" className="w-full h-full object-cover" />
                        <button 
                          onClick={() => removeItem(item.id)}
                          className="absolute top-2 right-2 w-6 h-6 rounded-full bg-black/60 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
                        >
                          <Plus size={12} className="text-white rotate-45" />
                        </button>
                      </div>
                    ))}
                  </div>
                  
                  <div className="sticky bottom-24 left-0 right-0 px-4 pointer-events-none flex justify-center">
                    <button
                      onClick={generateOutfits}
                      disabled={isGenerating || items.length < 2}
                      className="pointer-events-auto w-full max-w-xs py-4 rounded-full bg-white text-black font-medium flex items-center justify-center gap-2 active:scale-[0.98] transition-transform disabled:opacity-50 disabled:active:scale-100 shadow-2xl"
                    >
                      <Sparkles size={20} />
                      Generate Outfits
                    </button>
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
    </div>
  );
}
