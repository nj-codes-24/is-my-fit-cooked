import React, { useRef, useState, useCallback } from "react";
import Webcam from "react-webcam";
import { Camera, RefreshCw, Upload, Sparkles, X, Activity, Layers, Timer, SwitchCamera, ChevronLeft } from "lucide-react";
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
  const [timerSeconds, setTimerSeconds] = useState(0);
  const [countdown, setCountdown] = useState<number | null>(null);

  const capture = useCallback(() => {
    const imageSrc = webcamRef.current?.getScreenshot();
    if (imageSrc) setImage(imageSrc);
  }, [webcamRef]);

  const handleTimerClick = () => {
    setTimerSeconds(prev => {
      if (prev === 0) return 3;
      if (prev === 3) return 5;
      if (prev === 5) return 10;
      return 0;
    });
  };

  const handleCaptureClick = () => {
    if (countdown !== null) return;
    if (timerSeconds > 0) {
      setCountdown(timerSeconds);
      let currentCount = timerSeconds;
      const interval = setInterval(() => {
        currentCount -= 1;
        if (currentCount <= 0) {
          clearInterval(interval);
          setCountdown(null);
          capture();
        } else {
          setCountdown(currentCount);
        }
      }, 1000);
    } else {
      capture();
    }
  };

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
      // Simulate an API call delay for the loading animation
      await new Promise(resolve => setTimeout(resolve, 2500));
      
      const dummyData = {
        feedback: [
          "The monochromatic palette creates a sleek and modern silhouette.",
          "The relaxed fit of the top provides a comfortable, effortless vibe.",
          "Your choice of glasses adds a great intellectual edge to the look."
        ],
        upgrades: [
          "Try layering with a structured overshirt or light jacket to add dimension.",
          "A simple silver chain or pendant could break up the solid color nicely.",
          "Swapping to a slightly more tailored pant would sharpen the overall profile."
        ]
      };
      
      setResult(dummyData);
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
      {!image && (
        <header className="px-6 py-4 flex justify-center items-center shrink-0">
          <h1 className="font-display text-2xl tracking-tight font-bold text-white lowercase">fit check</h1>
        </header>
      )}

      {/* Main Content */}
      <div className={cn("flex-1 px-2 flex flex-col items-center justify-center min-h-0", !image && "overflow-hidden")}>
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
                screenshotQuality={1}
                className="absolute inset-0 w-full h-full object-cover"
                videoConstraints={{ 
                  facingMode: isSelfieMode ? "user" : "environment",
                  width: { ideal: 1080 },
                  height: { ideal: 1920 }
                }}
                mirrored={false}
              />

              {/* Countdown Overlay */}
              <AnimatePresence>
                {countdown !== null && (
                  <motion.div 
                    initial={{ scale: 0.5, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    exit={{ scale: 1.5, opacity: 0 }}
                    key={countdown}
                    className="absolute inset-0 flex items-center justify-center z-40 pointer-events-none"
                  >
                    <span className="text-[120px] font-bold text-white drop-shadow-[0_0_20px_rgba(0,0,0,0.5)]">
                      {countdown}
                    </span>
                  </motion.div>
                )}
              </AnimatePresence>
              
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
                  onClick={handleCaptureClick}
                  disabled={countdown !== null}
                  className="w-20 h-20 rounded-full border-[3px] border-white/50 flex items-center justify-center p-1.5 active:scale-95 transition-transform shrink-0"
                >
                  <div className="w-full h-full rounded-full bg-white shadow-sm" />
                </button>
                
                {/* Right Controls */}
                <div className="flex-1 flex justify-end gap-3 z-50">
                  <button 
                    onClick={handleTimerClick}
                    className="w-12 h-12 rounded-full bg-black/20 backdrop-blur-md flex items-center justify-center border border-white/20 active:scale-95 transition-transform"
                  >
                    {timerSeconds > 0 ? (
                      <span className="text-white font-medium text-lg">{timerSeconds}s</span>
                    ) : (
                      <Timer size={20} className="text-white" />
                    )}
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
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="fixed inset-0 z-[100] bg-[#111111] flex flex-col justify-start items-center pb-12 overflow-y-auto"
          >
            {/* Post-Capture Header */}
            <header className="px-6 pt-8 pb-4 flex justify-start items-center shrink-0 w-full">
              <button onClick={retake} className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-colors">
                <ChevronLeft size={24} />
              </button>
            </header>

            {/* Captured Image */}
            <div className={cn("w-full relative flex justify-center items-center px-4 transition-all duration-500", result ? "mb-6 shrink-0" : "flex-1 min-h-[50vh] max-h-[70vh] mb-8")}>
              <div className={cn("overflow-hidden shrink-0 shadow-2xl transition-all duration-500", result ? "w-[220px] aspect-square rounded-3xl" : "h-full max-w-full aspect-[9/16] rounded-[32px]")}>
                <img src={image} alt="Captured outfit" className="w-full h-full object-cover" />
              </div>
            </div>

            {/* Analyze Button */}
            <div className="w-full px-6 shrink-0 flex flex-col items-center">
              {!result && !isAnalyzing && (
                <button
                  onClick={analyzeOutfit}
                  className="w-full max-w-[220px] py-3.5 rounded-full bg-white text-black font-semibold text-[15px] flex items-center justify-center gap-2 active:scale-[0.98] transition-transform shadow-xl"
                >
                  <Sparkles size={18} />
                  Analyze Outfit
                </button>
              )}

              {isAnalyzing && (
                <div className="flex flex-col items-center justify-center py-4 gap-4">
                  <Activity size={32} className="text-white animate-pulse" />
                  <p className="text-white/60 text-sm animate-pulse">Stylist is thinking...</p>
                </div>
              )}
            </div>

            {/* Results */}
            <AnimatePresence>
              {result && (
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="flex flex-col gap-6 w-full px-6"
                >
                  <div className="bg-[#1C1C1E] border border-white/10 p-6 rounded-[24px] space-y-4 shadow-lg">
                    <h3 className="font-display font-medium text-lg flex items-center gap-2 text-white">
                      <Layers size={18} className="text-white/60" />
                      Style Analysis
                    </h3>
                    <ul className="space-y-3">
                      {result.feedback.map((point, i) => (
                        <li key={i} className="text-[15px] text-white/80 leading-relaxed flex items-start gap-3">
                          <span className="w-1.5 h-1.5 rounded-full bg-white/40 mt-2 shrink-0" />
                          {point}
                        </li>
                      ))}
                    </ul>
                  </div>

                  <div className="bg-[#1C1C1E] border border-white/10 p-6 rounded-[24px] space-y-4 shadow-lg">
                    <h3 className="font-display font-medium text-lg flex items-center gap-2 text-white">
                      <Sparkles size={18} className="text-white/60" />
                      Smart Upgrades
                    </h3>
                    <ul className="space-y-3">
                      {result.upgrades.map((point, i) => (
                        <li key={i} className="text-[15px] text-white/80 leading-relaxed flex items-start gap-3">
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
