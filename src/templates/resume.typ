#import "/src/lib/resume.typ": resume

#let data = yaml(sys.inputs.at("data", default: "/data/resume.yml"))

#metadata(data.variants.keys()) <variants>

#resume(data, variant: sys.inputs.at("variant", default: "full"))
