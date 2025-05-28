"use client";

import { useEffect, useRef } from "react";
import Image from "next/image";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const featuredCollectibles = [
  {
    id: 1,
    title: "Eiffel Tower Sunset",
    location: "Paris, France",
    artist: "Marie Dubois",
    image: "/images/eiffel-tower.jpg",
  },
  {
    id: 2,
    title: "Taj Mahal Dawn",
    location: "Agra, India",
    artist: "Raj Patel",
    image: "/images/taj-mahal.jpg",
  },
  {
    id: 3,
    title: "Great Wall Autumn",
    location: "Beijing, China",
    artist: "Li Wei",
    image: "/images/great-wall.jpg",
  },
  {
    id: 4,
    title: "Machu Picchu Mist",
    location: "Cusco, Peru",
    artist: "Carlos Rodriguez",
    image: "/images/machu-picchu.jpg",
  },
];

export function FeaturedCollectibles() {
  const cardsRef = useRef<HTMLDivElement[]>([]);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("animate-fade-up", "opacity-100");
            observer.unobserve(entry.target);
          }
        });
      },
      {
        threshold: 0.1,
        rootMargin: "0px 0px -50px 0px",
      }
    );

    cardsRef.current.forEach((card) => {
      if (card) {
        card.classList.add("opacity-0");
        observer.observe(card);
      }
    });

    return () => observer.disconnect();
  }, []);

  return (
    <section className="py-16 bg-gradient-to-b from-midnight to-midnight/80">
      <div className="container mx-auto px-4">
        <h2 className="text-3xl md:text-4xl font-bold mb-8">
          Featured Collectibles
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {featuredCollectibles.map((item, index) => (
            <Card
              key={item.id}
              ref={(el) => {
                if (el) cardsRef.current[index] = el;
              }}
              className="bg-black/20 hover:bg-black/30 transition-all duration-300 border-0"
            >
              <CardContent className="p-0">
                <div className="relative h-[250px] w-full">
                  <Image
                    src={item.image}
                    alt={item.title}
                    fill
                    className="object-cover rounded-t-lg"
                  />
                </div>
                <div className="p-4">
                  <h3 className="text-xl font-semibold mb-2">{item.title}</h3>
                  <p className="text-sm text-gray-400 mb-1">{item.location}</p>
                  <p className="text-sm text-accent-teal mb-4">
                    By {item.artist}
                  </p>
                  <Button variant="default" size="sm" className="w-full">
                    Learn More
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </section>
  );
}
