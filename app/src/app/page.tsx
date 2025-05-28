import { Hero } from "@/components/sections/hero";
import { NewestCollectibles } from "@/components/sections/newest-collectibles";
import { FeaturedCollectibles } from "@/components/sections/featured-collectibles";

export default function Home() {
  return (
    <main>
      <Hero />
      <NewestCollectibles />
      <FeaturedCollectibles />
    </main>
  );
}
