import { motion } from "motion/react";
import { ArrowUpRight, Flame, Heart } from "lucide-react";

// Placeholder data
const TRENDING_DEALS = [
  {
    id: 1,
    brand: "Acne Studios",
    offer: "Archive Sale — Up to 40% Off",
    image: "https://images.unsplash.com/photo-1550614000-4b95d4ed798a?q=80&w=2000&auto=format&fit=crop",
  },
  {
    id: 2,
    brand: "SSENSE",
    offer: "Private Sale unlocked for you",
    image: "https://images.unsplash.com/photo-1617137968427-85924c800a22?q=80&w=2000&auto=format&fit=crop",
  }
];

const SPOTLIGHTS = [
  {
    id: 1,
    brand: "Aime Leon Dore",
    title: "Uniform Essentials II",
    description: "The new collection redefining everyday luxury.",
    image: "https://images.unsplash.com/photo-1516257984-b1b4d707412e?q=80&w=2000&auto=format&fit=crop",
  },
  {
    id: 2,
    brand: "Salomon",
    title: "XT-6 Advanced",
    description: "Trail running heritage meets modern aesthetic.",
    image: "https://images.unsplash.com/photo-1608231387042-66d1773070a5?q=80&w=2000&auto=format&fit=crop",
  }
];

export function Explore() {
  return (
    <div className="flex flex-col min-h-full pb-8">
      {/* Header */}
      <header className="px-6 py-8">
        <h1 className="font-display text-3xl tracking-tight font-medium">Explore</h1>
        <p className="text-white/50 text-sm mt-1">Curated fashion & offers</p>
      </header>

      {/* Main Content */}
      <div className="flex-1 px-4 flex flex-col gap-8">
        
        {/* Trending Deals - Horizontal Scroll */}
        <section>
          <div className="flex items-center gap-2 mb-4 px-2">
            <Flame size={18} className="text-orange-500" />
            <h2 className="font-display font-medium text-lg">Trending Deals</h2>
          </div>
          
          <div className="flex gap-4 overflow-x-auto pb-4 px-2 snap-x hide-scrollbar">
            {TRENDING_DEALS.map((deal) => (
              <motion.div 
                key={deal.id}
                whileTap={{ scale: 0.98 }}
                className="shrink-0 w-[280px] snap-start relative rounded-3xl overflow-hidden aspect-[4/3] group border border-white/10"
              >
                <img src={deal.image} alt={deal.brand} className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105" />
                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent flex flex-col justify-end p-5">
                  <span className="text-xs font-mono tracking-widest uppercase text-white/70 mb-1">
                    {deal.brand}
                  </span>
                  <h3 className="text-white font-medium text-lg leading-tight">
                    {deal.offer}
                  </h3>
                </div>
              </motion.div>
            ))}
          </div>
        </section>

        {/* Brand Spotlights */}
        <section className="px-2 flex flex-col gap-6">
          <div className="flex items-center gap-2 mb-2">
            <div className="w-1.5 h-1.5 rounded-full bg-white/40" />
            <h2 className="font-display font-medium text-lg text-white/80">Brand Spotlight</h2>
          </div>

          {SPOTLIGHTS.map((spotlight) => (
            <motion.div 
              key={spotlight.id}
              whileTap={{ scale: 0.98 }}
              className="glass-panel rounded-[2rem] overflow-hidden group cursor-pointer"
            >
              <div className="aspect-[4/5] relative overflow-hidden">
                <img src={spotlight.image} alt={spotlight.title} className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-105" />
                <div className="absolute top-4 right-4 w-10 h-10 rounded-full bg-black/20 backdrop-blur-md flex items-center justify-center border border-white/10">
                  <Heart size={18} className="text-white" />
                </div>
              </div>
              <div className="p-6">
                <div className="flex justify-between items-start mb-2">
                  <span className="text-xs font-mono tracking-widest uppercase text-white/50">
                    {spotlight.brand}
                  </span>
                  <ArrowUpRight size={18} className="text-white/40" />
                </div>
                <h3 className="text-xl font-display font-medium text-white mb-2">
                  {spotlight.title}
                </h3>
                <p className="text-sm text-white/60 leading-relaxed">
                  {spotlight.description}
                </p>
              </div>
            </motion.div>
          ))}
        </section>

      </div>
    </div>
  );
}
