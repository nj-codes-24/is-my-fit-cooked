export interface WardrobeItem {
  id: string;
  category: string;
  color: string;
  image: string; // base64 string
  addedAt: number;
}

export interface Outfit {
  style: string;
  description: string;
  itemIds: string[];
}
