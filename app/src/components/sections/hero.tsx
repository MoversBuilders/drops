import { Button } from "@/components/ui/button";
import { Globe } from "../magicui/globe";

export function Hero() {
  const fadeInClass = "animate-fade-up";

  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden bg-midnight">
      {/* Globe Canvas */}
      <div className="absolute inset-0 w-full h-full opacity-50">
        <Globe />
      </div>

      {/* Content */}
      <div className="relative z-10 text-center px-4">
        <h1
          className={`text-5xl md:text-7xl font-bold text-white mb-6 ${fadeInClass}`}
          style={{ fontFamily: "Poppins" }}
        >
          Been there, done that.
        </h1>
        <p
          className={`text-xl md:text-2xl text-gray-300 mb-8 ${fadeInClass}`}
          style={{ fontFamily: "Inter" }}
        >
          Discover and mint real-world NFTs around you.
        </p>
        <Button variant="neon" size="lg" className={fadeInClass}>
          Join Now
        </Button>
      </div>
    </section>
  );
}
