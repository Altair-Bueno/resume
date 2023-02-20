/**
 * Compile Handlebars templates using Deno
 *
 */

import Handlebars from "npm:handlebars";
import isoCountries from "npm:i18n-iso-countries";
import { parse } from "https://deno.land/std/flags/mod.ts";
import * as yaml from "https://deno.land/std/encoding/yaml.ts";

const args = parse(Deno.args);

if (args.h || args.help) {
  console.log("USAGE: ./hbs -d DATA [...FILES]");
  console.table({
    "-h, --help": "Print this help",
    "-d DATA": "Input data. Must be valid JSON",
    "-o FILE": "Output file",
    // https://handlebarsjs.com/api-reference/compilation.html#handlebars-compile-template-options
    "--hbs.OPTION=VALUE": "Pass `OPTION` to Handlebars",
    FILES: "List of files to compile with Handlebars",
  });
  Deno.exit(0);
}

const data = yaml.parse(await Deno.readTextFile(args.d));

// Helpers
Handlebars.registerHelper("isoCountriesGetName", isoCountries.getName);
Handlebars.registerHelper("urlEncode", (x) =>
  new URLSearchParams(x).toString()
);
Handlebars.registerHelper(
  "shortFormatDate",
  (locale: string, startDate, endDate) => {
    const from = new Date(startDate);
    const to = new Date(endDate);
    return Intl.DateTimeFormat(locale, {
      month: "short",
      year: "numeric",
    }).formatRange(from, to);
  }
);
Handlebars.registerHelper("formatYear", (locale, date) => {
  return Intl.DateTimeFormat(locale, { year: "numeric" }).format(
    new Date(date)
  );
});
Handlebars.registerHelper("host", (x) => new URL(x).host);
Handlebars.registerHelper(
  "latex",
  (command, ...args) =>
    "\\" +
    String(command) +
    args
      .slice(0, args.length - 1)
      .map((x) => `{${x}}`)
      .join("")
);
Handlebars.registerHelper("join", (sep, ...args) => {
  return args.slice(0, args.length - 1).join(sep);
});
Handlebars.registerHelper("joinArray", (sep, array) => {
  return array.join(sep);
});

// Compile and run
const tasksPromises = args._.map(async (x: string | number) => {
  const templatePath = String(x);
  const template = await Deno.readTextFile(templatePath);
  const compiledTemplate = Handlebars.compile(template, args.hbs);
  const output = compiledTemplate(data);
  return output;
});

const results = await Promise.all(tasksPromises);
if (args.o) {
  const content = results.join("\n");
  await Deno.writeTextFile(args.o, content);
} else {
  console.log(...results);
}
