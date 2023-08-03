/**
 * Compile Handlebars templates using Deno
 *
 */

import Handlebars from "npm:handlebars@4.7.7";
import isoCountries from "npm:i18n-iso-countries@7.6.0";
import parsePhoneNumber from "npm:libphonenumber-js";
import { parse } from "https://deno.land/std@0.194.0/flags/mod.ts";
import * as yaml from "https://deno.land/std@0.194.0/yaml/mod.ts";
import Cite from "npm:citation-js@0.6.8";

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

// Modify scape function on Handlebars
// - https://github.com/handlebars-lang/handlebars.js/issues/1301#issuecomment-274614436
// - https://tex.stackexchange.com/a/34586
Handlebars.Utils.escapeExpression = (arg) =>
  String(arg)
    .replaceAll(/([&%$#_{}])/g, "\\$1")
    .replaceAll("~", "\\textasciitilde")
    .replaceAll("^", "\\textasciicircum")
    .replaceAll("\\", "\\textbackslash");

// Helpers
Handlebars.registerHelper("isoCountriesGetName", isoCountries.getName);
Handlebars.registerHelper("urlEncode", (x) =>
  new URLSearchParams(x).toString()
);
Handlebars.registerHelper(
  "formatDateRange",
  (locale: string, startDate, endDate) => {
    const from = new Date(startDate);
    const dateTimeFormat = Intl.DateTimeFormat(locale, {
      month: "short",
      year: "numeric",
    });

    if (endDate) {
      return dateTimeFormat.formatRange(from, new Date(endDate));
    } else {
      const relativeTimeFormat = new Intl.RelativeTimeFormat(locale, {
        numeric: "auto",
      });
      const today = relativeTimeFormat.format(0, "day");
      const todayCapitalized = today[0].toUpperCase() + today.slice(1);
      return `${dateTimeFormat.format(from)} – ${todayCapitalized}`;
    }
  }
);
Handlebars.registerHelper("formatYear", (locale, date) => {
  return Intl.DateTimeFormat(locale, { year: "numeric" }).format(
    new Date(date)
  );
});
Handlebars.registerHelper("formatPhone", (phone) => {
  const phoneNumber = parsePhoneNumber(phone);
  return phoneNumber.formatInternational();
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
