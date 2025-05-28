"use client";

import { Nav } from "@/components/layout/nav";
import OpenMap from "@/components/OpenMap";

export default function HomePage() {
  return (
    <>
      <Nav />
      <main className="min-h-screen bg-midnight pt-24 pb-12">
        <div className="container mx-auto px-4">
          <h1 className="text-4xl font-bold mb-8">Explore Locations</h1>
          <OpenMap />
        </div>
      </main>
    </>
  );
}
