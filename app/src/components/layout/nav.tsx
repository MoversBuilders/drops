"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Menu } from "lucide-react";

export function Nav() {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isWalletConnected, setIsWalletConnected] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 0);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const handleWalletConnect = () => {
    // TODO: Implement wallet connection
    setIsWalletConnected(true);
  };

  return (
    <nav
      className={`fixed top-0 w-full backdrop-blur transition-all duration-300 z-50 ${
        isScrolled ? "py-2 bg-midnight/80" : "py-4 bg-transparent"
      }`}
    >
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <Link href="/" className="text-2xl font-bold text-white">
            Drops
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-8">
            <Link
              href="/"
              className="text-white hover:text-cloud transition-colors"
            >
              Home
            </Link>
            <Link
              href="/how-it-works"
              className="text-white hover:text-cloud transition-colors"
            >
              How It Works
            </Link>
            {isWalletConnected ? (
              <Link
                href="/profile"
                className="text-white hover:text-cloud transition-colors"
              >
                Profile
              </Link>
            ) : (
              <Button variant="neon" onClick={handleWalletConnect}>
                Connect Your Wallet
              </Button>
            )}
          </div>

          {/* Mobile Menu Button */}
          <button
            className="md:hidden text-white"
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          >
            <Menu size={24} />
          </button>
        </div>

        {/* Mobile Navigation */}
        {isMobileMenuOpen && (
          <div className="md:hidden pt-4 pb-2">
            <div className="flex flex-col space-y-4">
              <Link
                href="/"
                className="text-white hover:text-[#1DE9B6] transition-colors"
                onClick={() => setIsMobileMenuOpen(false)}
              >
                Home
              </Link>
              <Link
                href="/how-it-works"
                className="text-white hover:text-[#1DE9B6] transition-colors"
                onClick={() => setIsMobileMenuOpen(false)}
              >
                How It Works
              </Link>
              {isWalletConnected ? (
                <Link
                  href="/profile"
                  className="text-white hover:text-[#1DE9B6] transition-colors"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  Profile
                </Link>
              ) : (
                <Button
                  variant="neon"
                  onClick={handleWalletConnect}
                  className="w-full text-ocean bg-deep-ocean"
                >
                  Connect Your Wallet
                </Button>
              )}
            </div>
          </div>
        )}
      </div>
    </nav>
  );
}
