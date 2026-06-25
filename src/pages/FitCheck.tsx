import React, { useRef, useState, useCallback } from "react";
import Webcam from "react-webcam";
import { Camera, RefreshCw, Upload, Sparkles, X, Activity, Layers, Timer, SwitchCamera } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import { cn } from "../components/Layout";

interface AnalysisResult {
  feedback: string[];
  upgrades: string[];
}

export function FitCheck() {
  const webcamRef = useRef<Webcam>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  
  const [image, setImage] = useState<string | null>(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [result, setResult] = useState<AnalysisResult | null>(null);
  const [isSelfieMode, setIsSelfieMode] = useState(true);

  const capture = useCallback(() => {
    const imageSrc = webcamRef.current?.getScreenshot();
    if (imageSrc) setImage(imageSrc);
  }, [webcamRef]);

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setImage(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const analyzeOutfit = async () => {
    if (!image) return;
    setIsAnalyzing(true);
    setResult(null);

    try {
      const res = await fetch("/api/analyze-outfit", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ imageBase64: image }),
      });
      
      if (!res.ok) throw new Error("Failed to analyze");
      
      const data = await res.json();
      setResult(data);
    } catch (error) {
      console.error(error);
      alert("Failed to analyze outfit. Please try again.");
    } finally {
      setIsAnalyzing(false);
    }
  };

  const retake = () => {
    setImage(null);
    setResult(null);
  };

  return (
    <div className="flex flex-col h-full overflow-hidden pb-4">
      {/* Header */}
      <header className="px-6 py-4 flex justify-center items-center shrink-0">
        <h1 className="font-display text-2xl tracking-tight font-bold text-white lowercase">fit check</h1>
      </header>

      {/* Main Content */}
      <div className={cn("flex-1 px-2 flex flex-col items-center justify-center min-h-0", image ? "overflow-y-auto" : "overflow-hidden")}>
        {!image ? (
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="h-full max-w-full aspect-[9/16] rounded-[32px] p-[1px] bg-gradient-to-b from-white/20 to-transparent shadow-2xl shadow-black/50 shrink-0"
          >
            <div className="w-full h-full relative rounded-[31px] overflow-hidden bg-zinc-900">
              {/* @ts-ignore */}
              <Webcam
                audio={false}
                ref={webcamRef}
                screenshotFormat="image/jpeg"
                className="absolute inset-0 w-full h-full object-cover"
                videoConstraints={{ facingMode: isSelfieMode ? "user" : "environment" }}
                mirrored={isSelfieMode}
              />
              
              {/* Camera Overlay Controls */}
              <div className="absolute inset-x-0 bottom-0 p-8 flex justify-between items-end bg-gradient-to-t from-black/60 via-black/20 to-transparent">
                {/* Left Controls */}
                <div className="flex-1 flex justify-start">
                  <button 
                    onClick={() => fileInputRef.current?.click()}
                    className="w-12 h-12 rounded-full bg-black/20 backdrop-blur-md flex items-center justify-center border border-white/20 active:scale-95 transition-transform"
                  >
                    <Upload size={20} className="text-white" />
                  </button>
                </div>
                
                {/* Center Shutter */}
                <button 
                  onClick={capture}
                  className="w-20 h-20 rounded-full border-[3px] border-white/50 flex items-center justify-center p-1.5 active:scale-95 transition-transform shrink-0"
                >
                  <div className="w-full h-full rounded-full bg-white shadow-sm" />
                </button>
                
                {/* Right Controls */}
                <div className="flex-1 flex justify-end gap-3">
                  <button 
                    className="w-12 h-12 rounded-full bg-black/20 backdrop-blur-md flex items-center justify-center border border-white/20 active:scale-95 transition-transform"
                  >
                    <Timer size={20} className="text-white" />
                  </button>
                  <button 
                    onClick={() => setIsSelfieMode(!isSelfieMode)}
                    className="w-12 h-12 rounded-full bg-black/20 backdrop-blur-md flex items-center justify-center border border-white/20 active:scale-95 transition-transform"
                  >
                    <SwitchCamera size={20} className="text-white" />
                  </button>
                </div>
              </div>
              <input 
                type="file" 
                ref={fileInputRef} 
                className="hidden" 
                accept="image/*"
                onChange={handleFileUpload}
              />
            </div>
          </motion.div>
        ) : (
          <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="w-full flex flex-col gap-6 pb-6"
          >
            <div className="w-full max-w-[400px] aspect-[9/16] mx-auto rounded-[32px] p-[1px] bg-gradient-to-b from-white/20 to-transparent shadow-2xl shadow-black/50 shrink-0">
              <div className="w-full h-full relative rounded-[31px] overflow-hidden bg-zinc-900">
                <img src={image} alt="Captured outfit" className="w-full h-full object-cover" />
                
                {/* Image Controls */}
                <div className="absolute top-4 right-4 flex gap-2">
                  <button 
                    onClick={retake}
                    className="w-10 h-10 rounded-full bg-black/40 backdrop-blur-xl flex items-center justify-center border border-white/20"
                  >
                    <X size={18} className="text-white" />
                  </button>
                </div>
              </div>
            </div>

            {!result && !isAnalyzing && (
              <button
                onClick={analyzeOutfit}
                className="w-full py-4 rounded-2xl bg-white text-black font-medium flex items-center justify-center gap-2 active:scale-[0.98] transition-transform"
              >
                <Sparkles size={20} />
                Analyze Outfit
              </button>
            )}

            {isAnalyzing && (
              <div className="flex flex-col items-center justify-center py-8 gap-4">
                <Activity size={32} className="text-white animate-pulse" />
                <p className="text-white/60 text-sm animate-pulse">Stylist is thinking...</p>
              </div>
            )}

            {/* Results */}
            <AnimatePresence>
              {result && (
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="flex flex-col gap-6 w-full"
                >
                  <div className="glass-panel p-6 rounded-3xl space-y-4">
                    <h3 className="font-display font-medium text-lg flex items-center gap-2 text-white">
                      <Layers size={18} className="text-white/60" />
                      Style Analysis
                    </h3>
                    <ul className="space-y-3">
                      {result.feedback.map((point, i) => (
                        <li key={i} className="text-sm text-white/80 leading-relaxed flex items-start gap-3">
                          <span className="w-1.5 h-1.5 rounded-full bg-white/40 mt-2 shrink-0" />
                          {point}
                        </li>
                      ))}
                    </ul>
                  </div>

                  <div className="glass-panel p-6 rounded-3xl space-y-4 bg-white/5 border-white/10">
                    <h3 className="font-display font-medium text-lg flex items-center gap-2 text-white">
                      <Sparkles size={18} className="text-white/60" />
                      Smart Upgrades
                    </h3>
                    <ul className="space-y-3">
                      {result.upgrades.map((point, i) => (
                        <li key={i} className="text-sm text-white/80 leading-relaxed flex items-start gap-3">
                          <span className="w-1.5 h-1.5 rounded-full bg-white/40 mt-2 shrink-0" />
                          {point}
                        </li>
                      ))}
                    </ul>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </motion.div>
        )}
      </div>
    </div>
  );
}
