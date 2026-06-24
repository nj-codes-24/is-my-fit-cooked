import { BrowserRouter, Routes, Route } from "react-router-dom";
import { Layout } from "./components/Layout";
import { FitCheck } from "./pages/FitCheck";
import { Closet } from "./pages/Closet";
import { Explore } from "./pages/Explore";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<FitCheck />} />
          <Route path="closet" element={<Closet />} />
          <Route path="explore" element={<Explore />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

