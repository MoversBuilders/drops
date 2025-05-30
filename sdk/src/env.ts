import dotenv from "dotenv";
import { z } from "zod";

dotenv.config();

const envSchema = z.object({
  SUI_NETWORK: z.string(),
  DROPS_PACKAGE_ID: z.string(),
  DROPS_PACKAGE_NAME: z.string(),
  COLLECTION_MODULE_NAME: z.string(),
  DROP_MODULE_NAME: z.string(),
});

// Parse and validate the environment variables
const parsedEnv = envSchema.safeParse(process.env);

if (!parsedEnv.success) {
  console.error(
    "❌ Invalid environment variables:",
    JSON.stringify(parsedEnv.error.format(), null, 2)
  );
  process.exit(1); // Exit the process to prevent runtime issues
}

export const ENV = parsedEnv.data;
