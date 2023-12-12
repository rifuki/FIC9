import dotenv from "dotenv";

dotenv.config();

function generateToken(): string {
  const xendit_api_key: string = process.env.XENDIT_KEY + ":";
  const base64: string = Buffer.from(xendit_api_key).toString("base64");
  return base64;
}

const xenditHeader = {
  Authorization: `Basic ${generateToken()}`,
  "Content-Type": "application/json",
  // "Cache-Control": "no-cache",
  // "Cookie": ""
};

export default xenditHeader;
