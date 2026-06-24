import React, { useRef, useState, useCallback } from "react";
import Webcam from "react-webcam";
import { Camera, RefreshCw, Upload, Sparkles, X, Activity, Layers } from "lucide-react";
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
    <div className="flex flex-col min-h-full pb-8">
      {/* Header */}
      <header className="px-6 py-8">
        <h1 className="font-display text-3xl tracking-tight font-medium">Fit Check</h1>
        <p className="text-white/50 text-sm mt-1">AI-powered style analysis</p>
      </header>

      {/* Main Content */}
      <div className="flex-1 px-4 flex flex-col items-center">
        {!image ? (
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="w-full relative rounded-3xl overflow-hidden aspect-[3/4] bg-zinc-900 border border-white/10"
          >
            {/* @ts-ignore */}
            <Webcam
              audio={false}
              ref={webcamRef}
              screenshotFormat="image/jpeg"
              className="absolute inset-0 w-full h-full object-cover"
              videoConstraints={{ facingMode: "user" }}
              mirrored={false}
            />
            
            {/* Camera Overlay Controls */}
            <div className="absolute inset-x-0 bottom-0 p-6 flex justify-between items-center bg-gradient-to-t from-black/80 to-transparent">
              <button 
                onClick={() => fileInputRef.current?.click()}
                className="w-12 h-12 rounded-full bg-white/10 backdrop-blur-md flex items-center justify-center border border-white/20 active:scale-95 transition-transform"
              >
                <Upload size={20} className="text-white" />
              </button>
              
              <button 
                onClick={capture}
                className="w-16 h-16 rounded-full border-2 border-white flex items-center justify-center p-1 active:scale-95 transition-transform"
              >
                <div className="w-full h-full rounded-full bg-white" />
              </button>
              
              <div className="w-12 h-12" /> {/* Spacer */}
            </div>
            <input 
              type="file" 
              ref={fileInputRef} 
              className="hidden" 
              accept="image/*"
              onChange={handleFileUpload}
            />
          </motion.div>
        ) : (
          <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="w-full flex flex-col gap-6"
          >
            <div className="relative rounded-3xl overflow-hidden aspect-[3/4] border border-white/10">
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
