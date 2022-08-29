import { PrismaClient } from "@prisma/client";
import type { NextApiRequest, NextApiResponse } from "next";

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  let prisma;
  try {
    prisma = new PrismaClient();
    console.log("Clearing locations table");
    await prisma.location.deleteMany();

    const claim = {
      test: "This is a test",
    };

    console.log("First time running");
    await prisma.$transaction([
      prisma.$executeRawUnsafe(
        `SET LOCAL request.jwt.claims = '${JSON.stringify(claim)}';`
      ),
      prisma.location.create({
        data: {
          name: "A",
          abbr: "a",
        },
      }),
    ]);

    console.log("Second time running");
    await prisma.$transaction([
      prisma.$executeRawUnsafe(
        `SET LOCAL request.jwt.claims = '${JSON.stringify(claim)}';`
      ),
      prisma.location.create({
        data: {
          name: "A",
          abbr: "b",
        },
      }),
    ]);

    await prisma.$disconnect();
    res.status(200).json({ status: "success" });
  } catch (e) {
    if (prisma) await prisma.$disconnect();
    console.error(e);
    res.status(404).json({ status: "failed" });
  }
}
