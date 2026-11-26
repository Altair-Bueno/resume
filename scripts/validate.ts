import * as yaml from "@std/yaml";
import { validate } from "@jsonresume/schema";

let failed = false;
for (const path of Deno.args) {
  const resume = yaml.parse(await Deno.readTextFile(path), { schema: "core" });
  validate(resume, (errors: { stack: string }[] | null) => {
    if (!errors) return;
    failed = true;
    for (const error of errors) console.error(`${path}: ${error.stack}`);
  });
}
if (failed) Deno.exit(1);
