import express from "express";
import path from "path";
import { createServer as createViteServer } from "vite";
import { GoogleGenAI, Type, Schema } from "@google/genai";

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

async function startServer() {
  const app = express();
  const PORT = 3000;

  app.use(express.json({ limit: "50mb" }));
  app.use(express.urlencoded({ extended: true, limit: "50mb" }));

  app.post("/api/analyze-outfit", async (req, res) => {
    try {
      const { imageBase64 } = req.body;
      if (!imageBase64) {
        return res.status(400).json({ error: "No image provided" });
      }

      // Remove data:image/...;base64, prefix if present
      const base64Data = imageBase64.replace(/^data:image\/\w+;base64,/, "");

      const prompt = `Act as a high-end personal stylist. Analyze this outfit's color palette, fit, and style. Provide 3 bullet points of constructive feedback and suggest 2 smart, actionable upgrades to elevate the look.`;

      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash",
        contents: [
          {
            role: "user",
            parts: [
              {
                inlineData: {
                  mimeType: "image/jpeg",
                  data: base64Data,
                },
              },
              { text: prompt },
            ],
          },
        ],
        config: {
          responseMimeType: "application/json",
          responseSchema: {
            type: Type.OBJECT,
            properties: {
              feedback: {
                type: Type.ARRAY,
                items: { type: Type.STRING },
                description: "3 bullet points of constructive feedback.",
              },
              upgrades: {
                type: Type.ARRAY,
                items: { type: Type.STRING },
                description: "2 smart, actionable upgrades to elevate the look.",
              },
            },
            required: ["feedback", "upgrades"],
          },
        },
      });

      const text = response.text;
      if (!text) {
        return res.status(500).json({ error: "No response from AI" });
      }

      res.json(JSON.parse(text));
    } catch (error: any) {
      console.error("Error analyzing outfit:", error);
      res.status(500).json({ error: error.message || "Failed to analyze outfit" });
    }
  });

  app.post("/api/generate-outfits", async (req, res) => {
    try {
      const { wardrobeItems } = req.body;
      
      if (!wardrobeItems || !Array.isArray(wardrobeItems) || wardrobeItems.length === 0) {
        return res.status(400).json({ error: "No wardrobe items provided" });
      }

      const prompt = `You are a high-end personal stylist. Based on the following metadata of the user's clothing items, generate 3 complete, segregated outfit combinations (e.g., Casual, Formal, Streetwear) based on color theory and current trends.
      
      User's Wardrobe Items:
      ${JSON.stringify(wardrobeItems)}
      `;

      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash",
        contents: [
          {
            role: "user",
            parts: [{ text: prompt }],
          },
        ],
        config: {
          responseMimeType: "application/json",
          responseSchema: {
            type: Type.OBJECT,
            properties: {
              outfits: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    style: { type: Type.STRING, description: "e.g., Casual, Formal, Streetwear" },
                    description: { type: Type.STRING, description: "A brief description of the overall look." },
                    itemIds: {
                      type: Type.ARRAY,
                      items: { type: Type.STRING },
                      description: "The IDs of the items used in this outfit.",
                    },
                  },
                  required: ["style", "description", "itemIds"],
                },
              },
            },
            required: ["outfits"],
          },
        },
      });

      const text = response.text;
      if (!text) {
        return res.status(500).json({ error: "No response from AI" });
      }

      res.json(JSON.parse(text));
    } catch (error: any) {
      console.error("Error generating outfits:", error);
      res.status(500).json({ error: error.message || "Failed to generate outfits" });
    }
  });

  // Vite middleware for development
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

startServer();
