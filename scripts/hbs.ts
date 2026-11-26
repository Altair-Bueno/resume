/**
 * Compile Handlebars templates using Deno
 */

import { parseArgs } from "@std/cli/parse-args";
import * as yaml from "@std/yaml";
import Cite from "citation-js";
import escapeLatex from "escape-latex";
import Handlebars from "handlebars";
import isoCountries from "i18n-iso-countries";
import parsePhoneNumber from "libphonenumber-js";

const args = parseArgs(Deno.args);

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

// https://github.com/handlebars-lang/handlebars.js/issues/1301#issuecomment-274614436
const tex = (arg: unknown) =>
  arg instanceof Handlebars.SafeString
    ? arg.toHTML()
    : escapeLatex(String(arg));
Handlebars.Utils.escapeExpression = tex;

// Helpers
Handlebars.registerHelper("isoCountriesGetName", isoCountries.getName);

Handlebars.registerHelper("formatMonth", (locale: string, date) => {
  return Intl.DateTimeFormat(locale, {
    month: "short",
    year: "numeric",
  }).format(new Date(date));
});
Handlebars.registerHelper("formatPhone", (phone) => {
  const phoneNumber = parsePhoneNumber(phone);
  return phoneNumber.formatInternational();
});
Handlebars.registerHelper(
  "link",
  (url, text, options) =>
    new Handlebars.SafeString(
      `\\${options.hash.plain ? "href" : "resumeLink"}{${
        String(url).replaceAll(/[%#&]/g, "\\$&")
      }}{${tex(text)}}`,
    ),
);
Handlebars.registerHelper("join", (sep, ...args) => {
  return args.slice(0, args.length - 1).flat().join(sep);
});
Handlebars.registerHelper("cite", (citation) => {
  return new Cite(citation).format("bibliography", {
    template: "apa",
    format: "text",
  });
});

const data = yaml.parse(await Deno.readTextFile(args.d));

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
