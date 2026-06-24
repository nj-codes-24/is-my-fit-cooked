import { create } from "zustand";
import { persist } from "zustand/middleware";
import { WardrobeItem } from "./types";

interface WardrobeState {
  items: WardrobeItem[];
  addItem: (item: WardrobeItem) => void;
  removeItem: (id: string) => void;
}

export const useWardrobeStore = create<WardrobeState>()(
  persist(
    (set) => ({
      items: [],
      addItem: (item) => set((state) => ({ items: [item, ...state.items] })),
      removeItem: (id) =>
        set((state) => ({ items: state.items.filter((i) => i.id !== id) })),
    }),
    {
      name: "wardrobe-storage",
    }
  )
);
