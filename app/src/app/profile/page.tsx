"use client";

import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export default function ProfilePage() {
  const [isConnected, setIsConnected] = useState(false);

  const connectSlushWallet = async () => {
    // TODO: Implement Slush wallet connection
    setIsConnected(true);
  };

  const mintNFT = async () => {
    // TODO: Implement NFT minting
    console.log("Minting NFT...");
  };

  return (
    <main className="min-h-screen bg-midnight pt-24 pb-12">
      <div className="container mx-auto px-4">
        <h1 className="text-4xl font-bold mb-8">My Profile</h1>

        {!isConnected ? (
          <Card className="bg-black/20 border-white/10">
            <CardHeader>
              <CardTitle>Connect Your Wallet</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="mb-4 text-gray-400">
                Connect your Slush wallet to view your profile and mint NFTs.
              </p>
              <Button variant="neon" onClick={connectSlushWallet}>
                Connect Slush Wallet
              </Button>
            </CardContent>
          </Card>
        ) : (
          <div className="grid gap-6 md:grid-cols-2">
            <Card className="bg-black/20 border-white/10">
              <CardHeader>
                <CardTitle>My NFTs</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid gap-4">
                  {/* NFT list will go here */}
                  <p className="text-gray-400">No NFTs minted yet.</p>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-black/20 border-white/10">
              <CardHeader>
                <CardTitle>Mint New NFT</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="mb-4 text-gray-400">
                  Mint a new NFT for free. Capture your favorite locations and
                  turn them into unique digital collectibles.
                </p>
                <Button variant="neon" onClick={mintNFT}>
                  Mint NFT
                </Button>
              </CardContent>
            </Card>
          </div>
        )}
      </div>
    </main>
  );
}
