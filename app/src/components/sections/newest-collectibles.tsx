"use client";

import { useRef } from "react";
import Image from "next/image";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ChevronLeft, ChevronRight } from "lucide-react";

// Mock data - replace with real data in production
const collectibles = [
  {
    id: 1,
    title: "Golden Gate Bridge",
    location: "San Francisco, CA",
    image: "/images/golden-gate.jpg",
    mintedAgo: "2 hours",
  },
  {
    id: 2,
    title: "Times Square",
    location: "New York, NY",
    image: "/images/times-square.jpg",
    mintedAgo: "5 hours",
  },
  {
    id: 3,
    title: "Tower Bridge",
    location: "London, UK",
    image: "/images/tower-bridge.jpg",
    mintedAgo: "1 day",
  },
  {
    id: 4,
    title: "Shibuya Crossing",
    location: "Tokyo, Japan",
    image: "/images/shibuya.jpg",
    mintedAgo: "2 days",
  },
];

export function NewestCollectibles() {
  const scrollContainerRef = useRef<HTMLDivElement>(null);

  const scroll = (direction: "left" | "right") => {
    if (scrollContainerRef.current) {
      const scrollAmount = 400;
      const newScrollLeft =
        scrollContainerRef.current.scrollLeft +
        (direction === "left" ? -scrollAmount : scrollAmount);
      scrollContainerRef.current.scrollTo({
        left: newScrollLeft,
        behavior: "smooth",
      });
    }
  };

  return (
    <section className="py-16 bg-midnight/50">
      <div className="container mx-auto px-4">
        <h2 className="text-3xl md:text-4xl font-bold mb-8">
          Newest Collectibles
        </h2>
        <div className="relative">
          {/* Navigation Buttons */}
          <Button
            variant="ghost"
            size="icon"
            className="absolute left-0 top-1/2 -translate-y-1/2 z-10 bg-black/20 hover:bg-black/40"
            onClick={() => scroll("left")}
          >
            <ChevronLeft className="h-6 w-6" />
          </Button>
          <Button
            variant="ghost"
            size="icon"
            className="absolute right-0 top-1/2 -translate-y-1/2 z-10 bg-black/20 hover:bg-black/40"
            onClick={() => scroll("right")}
          >
            <ChevronRight className="h-6 w-6" />
          </Button>

          {/* Carousel */}
          <div
            ref={scrollContainerRef}
            className="flex gap-6 overflow-x-auto scrollbar-hide scroll-smooth pb-4"
            style={{ scrollbarWidth: "none", msOverflowStyle: "none" }}
          >
            {collectibles.map((item) => (
              <Card
                key={item.id}
                className="flex-none w-[300px] bg-black/20 hover:bg-black/30 transition-all duration-300 hover:scale-105 border-0"
              >
                <CardContent className="p-0">
                  <div className="relative h-[200px] w-full">
                    <Image
                      src={item.image}
                      alt={item.title}
                      fill
                      className="object-cover rounded-t-lg"
                    />
                  </div>
                  <div className="p-4">
                    <h3 className="text-lg font-semibold mb-1">{item.title}</h3>
                    <p className="text-sm text-gray-400 mb-2">
                      {item.location}
                    </p>
                    <p className="text-xs text-accent-teal">
                      Minted {item.mintedAgo} ago
                    </p>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
