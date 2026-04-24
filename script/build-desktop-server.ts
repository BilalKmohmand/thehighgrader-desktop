import { build as esbuild } from "esbuild";
import { mkdir, readFile } from "fs/promises";

const allowlist = [
  "axios",
  "connect-pg-simple",
  "cors",
  "date-fns",
  "drizzle-orm",
  "drizzle-zod",
  "express",
  "express-rate-limit",
  "express-session",
  "helmet",
  "memorystore",
  "multer",
  "openai",
  "passport",
  "passport-local",
  "pg",
  "ws",
  "zod",
  "zod-validation-error",
];

const forceExternal = [
  "fsevents",
  "lightningcss",
  "pdf-parse",
  "pdf2pic",
  "gm",
  "@babel/preset-typescript",
  "@babel/preset-typescript/package.json",
];

async function main() {
  await mkdir("server/dist", { recursive: true });

  const pkg = JSON.parse(await readFile("package.json", "utf-8"));
  const allDeps = [
    ...Object.keys(pkg.dependencies || {}),
    ...Object.keys(pkg.devDependencies || {}),
  ];

  const externals = [
    ...allDeps.filter((dep) => !allowlist.includes(dep)),
    ...forceExternal,
  ];

  await esbuild({
    entryPoints: ["server/index.ts"],
    platform: "node",
    bundle: true,
    format: "cjs",
    outfile: "server/dist/index.cjs",
    define: {
      "process.env.NODE_ENV": '"production"',
    },
    external: externals,
    logLevel: "info",
  });
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
