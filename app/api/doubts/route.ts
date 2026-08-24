import { NextResponse } from "next/server";
import { readFile, writeFile, mkdir } from "fs/promises";
import { existsSync } from "fs";
import path from "path";

const DATA_DIR = path.join(process.cwd(), "public", "doubts");
const file = (topicId: string) => path.join(DATA_DIR, `${topicId}.json`);

async function readDoubts(topicId: string) {
  try {
    if (!existsSync(file(topicId))) return [];
    return JSON.parse(await readFile(file(topicId), "utf-8"));
  } catch { return []; }
}

export async function GET(req: Request) {
  const topicId = new URL(req.url).searchParams.get("topic") || "general";
  const doubts = await readDoubts(topicId);
  return NextResponse.json({ doubts: doubts.slice(-20).reverse() });
}

export async function POST(req: Request) {
  try {
    const { topicId, name, question } = await req.json();
    if (!question?.trim()) return NextResponse.json({ error: "No question" }, { status: 400 });
    if (!existsSync(DATA_DIR)) await mkdir(DATA_DIR, { recursive: true });
    const doubts = await readDoubts(topicId);
    doubts.push({ name: name || "Anonymous", question, timestamp: new Date().toISOString() });
    await writeFile(file(topicId), JSON.stringify(doubts, null, 2), "utf-8");
    return NextResponse.json({ success: true });
  } catch (e: any) {
    return NextResponse.json({ error: e.message }, { status: 500 });
  }
}
