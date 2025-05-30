export interface Drop {
    id: string;
    collectionId: string;
    sequenceNumber: number;
    mintTimestamp: number;
    randomness: number | null;
    attributes: Record<string, string[]>;
}

export interface Collection {
    id: string;
    name: string;
    description: string;
    image: string;
    attributes: Record<string, string[]>;
    flags: number;
    maxSupply: number;
    mintStartTime: number;
    mintStopTime: number;
}